import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/admin_pages/admin_dashboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToImgBB(File imageFile) async {
    const apiKey = '409164d54cc9cb69bc6e0c8910d9f487'; // Replace with your ImgBB API key
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final base64Image = base64Encode(await imageFile.readAsBytes());

    try {
      final response = await http.post(url, body: {
        'image': base64Image,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        return null;
      }
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  Future<void> _addApartmentToFirestore() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final imageUrl = await uploadImageToImgBB(_image!);
        if (imageUrl == null) throw Exception("Image upload failed");

        await FirebaseFirestore.instance.collection('apartments').add({
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'rent': double.parse(_rentController.text.trim()),
          'description': _descriptionController.text.trim(),
          'bedrooms': int.tryParse(_bedroomController.text.trim()) ?? 0,
          'bathrooms': int.tryParse(_bathroomController.text.trim()) ?? 0,
          'size': _sizeController.text.trim(),
          'imageUrl': imageUrl,
          'status': 'available',
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apartment added successfully'), backgroundColor: Colors.green),
        );

        // Navigate to Admin Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  AdminDashboard()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick an image.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Apartment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.camera_alt, size: 50),
                      )
                    : Image.file(_image!, height: 150),
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_locationController, 'Location'),
              _buildTextField(_rentController, 'Rent', isNumber: true),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(_bedroomController, 'Bedrooms', isNumber: true),
              _buildTextField(_bathroomController, 'Bathrooms', isNumber: true),
              _buildTextField(_sizeController, 'Size'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addApartmentToFirestore,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Add Apartment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.trim().isEmpty ? 'Enter $labelText' : null,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
