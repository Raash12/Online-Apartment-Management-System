import 'dart:convert';
import 'package:frontend/services/pdf_rental_invoice_service.dart';
import 'package:frontend/utils/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> apartment;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;

  const PaymentPage({
    Key? key,
    required this.apartment,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _submitPayment() async {
    setState(() => _isProcessing = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty || phone.isEmpty || pin.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill in all fields');
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final paymentResponse = await Payment.paymentProcessing(
        phoneNumber: pin,
        amount: widget.totalPrice.toString(),
        referenceId: '${widget.apartment['apartment_id']}-${DateTime.now().millisecondsSinceEpoch}',
        description: 'Rental payment for ${widget.apartment['apartment_name']}',
      );

      if (paymentResponse['success'] == true) {
        // Save to Firestore
        await FirebaseFirestore.instance.collection('apartment_rentals').add({
          'apartment_name': widget.apartment['apartment_name'],
          'location': widget.apartment['location'],
          'start_date': widget.startDate,
          'end_date': widget.endDate,
          'total_price': widget.totalPrice,
          'customer_name': name,
          'customer_phone': phone,
          'payment_account': pin,
          'invoice_ref': paymentResponse['invoiceRef'],
          'timestamp': Timestamp.now(),
        });

        // Generate PDF
        await PdfRentalInvoiceService.generateRentalInvoicePdf({
          'apartmentName': widget.apartment['apartment_name'],
          'totalPrice': widget.totalPrice,
          'days': widget.endDate.difference(widget.startDate).inDays,
          'customerName': name,
          'customerContact': phone,
          'paymentNumber': pin,
          'paymentReference': paymentResponse['invoiceRef'],
          'startDate': widget.startDate,
          'endDate': widget.endDate,
        });

        Fluttertoast.showToast(msg: 'Payment successful! Invoice generated');
      } else {
        Fluttertoast.showToast(
          msg: paymentResponse['message'] ?? 'Payment failed',
          backgroundColor: Colors.red
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}',
        backgroundColor: Colors.red
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Somali Payment Gateway'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Waafi PIN/Account',
                border: OutlineInputBorder(),
                hintText: '25261xxxxxxx',
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'PAY WITH WAAFI',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}