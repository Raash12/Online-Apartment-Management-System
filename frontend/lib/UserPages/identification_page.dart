import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IdentificationPage extends StatefulWidget {
  final String apartmentId;
  final String apartmentName;

  const IdentificationPage({
    Key? key,
    required this.apartmentId,
    required this.apartmentName,
  }) : super(key: key);

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  final _formKey = GlobalKey<FormState>();

  String _responsibleName = '';
  String _responsibleIdNumber = '';
  String _responsiblePhone = '';
  String _responsibleWorkPlace = '';

  bool _isSubmitting = false;

  Future<void> _submitIdentification() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all fields', Icons.error, Colors.red);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('User not logged in', Icons.error, Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('identifications').add({
        'userId': user.uid,
        'apartmentId': widget.apartmentId,
        'apartmentName': widget.apartmentName,
        'responsibleName': _responsibleName,
        'responsibleIdNumber': _responsibleIdNumber,
        'responsiblePhone': _responsiblePhone,
        'responsibleWorkPlace': _responsibleWorkPlace,
        'status': 'Pending',
        'submittedAt': Timestamp.now(),
      });

      _showSnackBar(
        'Information submitted successfully! Awaiting approval.',
        Icons.check_circle,
        Colors.green,
      );

      _formKey.currentState!.reset();
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error submitting: ${e.toString()}', Icons.error, Colors.red);
    }

    setState(() => _isSubmitting = false);
  }

  void _showSnackBar(String message, IconData icon, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Identification'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Apartment Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.apartmentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Responsible Person Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide details of the person responsible for this rental',
                style: TextStyle(color: Colors.grey),
              ),
              const Divider(height: 40, thickness: 1),

              // Full Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsibleName = value ?? '',
              ),
              const SizedBox(height: 16),

              // ID Number
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'ID Number',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsibleIdNumber = value ?? '',
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsiblePhone = value ?? '',
              ),
              const SizedBox(height: 16),

              // Workplace
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Workplace',
                  prefixIcon: const Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsibleWorkPlace = value ?? '',
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitIdentification,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Information',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
