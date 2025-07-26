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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information submitted. Awaiting approval.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting: $e')),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Renting Apartment: ${widget.apartmentName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Responsible Person Name
              TextFormField(
                decoration: const InputDecoration(labelText: 'Responsible Person Full Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsibleName = value ?? '',
              ),

              const SizedBox(height: 16),

              // Responsible Person ID Number
              TextFormField(
                decoration: const InputDecoration(labelText: 'Responsible Person ID Number'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsibleIdNumber = value ?? '',
              ),

              const SizedBox(height: 16),

              // Responsible Person Phone Number
              TextFormField(
                decoration: const InputDecoration(labelText: 'Responsible Person Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsiblePhone = value ?? '',
              ),

              const SizedBox(height: 16),

              // Responsible Person Workplace
              TextFormField(
                decoration: const InputDecoration(labelText: 'Where does the Responsible Person Work?'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _responsibleWorkPlace = value ?? '',
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitIdentification,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
