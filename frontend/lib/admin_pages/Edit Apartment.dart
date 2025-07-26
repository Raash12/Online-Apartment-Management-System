import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditApartmentPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> apartmentData;

  const EditApartmentPage({super.key, required this.docId, required this.apartmentData});

  @override
  State<EditApartmentPage> createState() => _EditApartmentPageState();
}

class _EditApartmentPageState extends State<EditApartmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _rentController;
  late TextEditingController _descriptionController;
  late TextEditingController _bedroomController;
  late TextEditingController _bathroomController;
  late TextEditingController _sizeController;

  @override
  void initState() {
    super.initState();
    final data = widget.apartmentData;
    _nameController = TextEditingController(text: data['name']);
    _locationController = TextEditingController(text: data['location']);
    _rentController = TextEditingController(text: data['rent'].toString());
    _descriptionController = TextEditingController(text: data['description']);
    _bedroomController = TextEditingController(text: data['bedrooms'].toString());
    _bathroomController = TextEditingController(text: data['bathrooms'].toString());
    _sizeController = TextEditingController(text: data['size']);
  }

  Future<void> _updateApartment() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('apartments').doc(widget.docId).update({
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'rent': double.parse(_rentController.text.trim()),
          'description': _descriptionController.text.trim(),
          'bedrooms': int.tryParse(_bedroomController.text.trim()) ?? 0,
          'bathrooms': int.tryParse(_bathroomController.text.trim()) ?? 0,
          'size': _sizeController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apartment updated successfully'), backgroundColor: Colors.green),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? 'Enter $labelText' : null,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Apartment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_locationController, 'Location'),
              _buildTextField(_rentController, 'Rent', isNumber: true),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(_bedroomController, 'Bedrooms', isNumber: true),
              _buildTextField(_bathroomController, 'Bathrooms', isNumber: true),
              _buildTextField(_sizeController, 'Size'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateApartment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Update Apartment'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
