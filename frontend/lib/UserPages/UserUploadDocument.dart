import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UserUploadDocumentPage extends StatefulWidget {
  final String userId; // Pass userId when navigating here

  const UserUploadDocumentPage({super.key, required this.userId});

  @override
  State<UserUploadDocumentPage> createState() => _UserUploadDocumentPageState();
}

class _UserUploadDocumentPageState extends State<UserUploadDocumentPage> {
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      } else {
        // User canceled picking
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> uploadDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a unique storage path e.g. userDocs/{userId}/{timestamp}_{filename}
      String storagePath =
          'userDocs/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_$_fileName';

      // Upload file to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(_selectedFile!);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();

      // Save file info in Firestore
      await FirebaseFirestore.instance.collection('user_documents').add({
        'userId': widget.userId,
        'fileName': _fileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );

      setState(() {
        _selectedFile = null;
        _fileName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Select Document (pdf, doc, docx, txt)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              onPressed: pickDocument,
            ),
            const SizedBox(height: 20),
            if (_fileName != null)
              Text(
                'Selected File: $_fileName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const Spacer(),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Upload Document',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
