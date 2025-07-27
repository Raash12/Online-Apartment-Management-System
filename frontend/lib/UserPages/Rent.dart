import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:frontend/services/pdf_rental_invoice_service.dart';
import 'package:frontend/utils/payment.dart';

class RentNowPage extends StatefulWidget {
  final String apartmentId;
  final String apartmentName;

  const RentNowPage({
    Key? key,
    required this.apartmentId,
    required this.apartmentName,
  }) : super(key: key);

  @override
  State<RentNowPage> createState() => _RentNowPageState();
}

class _RentNowPageState extends State<RentNowPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _evcNumberController = TextEditingController();
  final _paymentAmountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  double? _pricePerDay;
  double? _totalPrice;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchApartmentPrice();
  }

  Future<void> _fetchApartmentPrice() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('apartments')
          .doc(widget.apartmentId)
          .get();

      if (doc.exists && doc.data()!.containsKey('rent')) {
        setState(() {
          _pricePerDay = doc['rent'] is int
              ? (doc['rent'] as int).toDouble()
              : doc['rent'] as double; // Ensure it's a double
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load apartment price')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading price: ${e.toString()}')),
      );
    }
  }

  void _updateTotalPrice() {
    if (_startDate != null && _endDate != null && !_endDate!.isBefore(_startDate!)) {
      final rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      setState(() {
        _totalPrice = (_pricePerDay ?? 0) * rentalDays;
        _paymentAmountController.text = _totalPrice!.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _totalPrice = null;
        _paymentAmountController.clear();
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _updateTotalPrice();
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select valid dates.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final referenceId = "APT-${DateTime.now().millisecondsSinceEpoch}";

      final paymentData = {
        "accountNo": _evcNumberController.text.trim(),
        "referenceId": referenceId,
        "amount": _totalPrice,
        "description": "Rental: ${widget.apartmentName}",
      };

      final paymentResult = await Payment.paymentProcessing(paymentData);

      if (!paymentResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: ${paymentResult['message']}')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('rent_now').add({
        'userId': uid,
        'apartmentId': widget.apartmentId,
        'apartmentName': widget.apartmentName,
        'startDate': _startDate,
        'endDate': _endDate,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'customerName': _fullNameController.text.trim(),
        'customerContact': _phoneNumberController.text.trim(),
        'paymentNumber': _evcNumberController.text.trim(),
        'paymentAmount': _totalPrice,
        'paymentReference': referenceId,
      });

      await FirebaseFirestore.instance.collection('apartments').doc(widget.apartmentId).update({
        'status': 'rented',
        'rentedUntil': _endDate,
      });

      final rentalData = {
        'apartmentId': widget.apartmentId,
        'apartmentName': widget.apartmentName,
        'totalPrice': _totalPrice,
        'startDate': _startDate,
        'endDate': _endDate,
        'paymentReference': referenceId,
        'customerName': _fullNameController.text.trim(),
        'customerContact': _phoneNumberController.text.trim(),
      };

      final pdfBytes = await PdfRentalInvoiceService.generateRentalInvoicePdf(rentalData);
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rented successfully")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rent Apartment"), backgroundColor: Colors.blue.shade800),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Apartment: ${widget.apartmentName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_pricePerDay != null)
                    Text('\$${_pricePerDay!.toStringAsFixed(2)} per day', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _evcNumberController,
                    decoration: const InputDecoration(labelText: 'EVC Plus Number', hintText: 'e.g., 615123456', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) return 'Enter a valid 9-digit number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentAmountController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Amount (USD)', border: OutlineInputBorder()),
                    readOnly: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate == null ? 'Start Date' : DateFormat('MMM d, yyyy').format(_startDate!)),
                          onPressed: () => _pickDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_endDate == null ? 'End Date' : DateFormat('MMM d, yyyy').format(_endDate!)),
                          onPressed: _startDate == null ? null : () => _pickDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_totalPrice != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price:', style: TextStyle(fontSize: 18)),
                          Text('\$${_totalPrice!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('PAY WITH EVC PLUS', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}