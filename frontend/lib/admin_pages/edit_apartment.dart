import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditApartment extends StatefulWidget {
  final Map<String, dynamic> apartment;

  EditApartment({required this.apartment});

  @override
  _EditApartmentState createState() => _EditApartmentState();
}

class _EditApartmentState extends State<EditApartment> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _detailsController;
  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.apartment['name']);
    _locationController = TextEditingController(text: widget.apartment['location']);
    _priceController = TextEditingController(text: widget.apartment['price']?.toString());
    _detailsController = TextEditingController(text: widget.apartment['details']);
    _status = widget.apartment['status'] ?? 'available';
  }

  Future<void> _updateApartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('apartments')
          .doc(widget.apartment['id']) // Ensure `id` is document ID
          .update({
        'name': _nameController.text,
        'location': _locationController.text,
        'price': double.parse(_priceController.text),
        'details': _detailsController.text,
        'status': _status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apartment updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating apartment: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Apartment'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isSubmitting ? null : _updateApartment,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: ['available', 'occupied', 'maintenance']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updateApartment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[800],
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('UPDATE APARTMENT', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
