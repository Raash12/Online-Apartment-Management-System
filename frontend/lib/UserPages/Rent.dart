import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentNowPage extends StatefulWidget {
  final String apartmentId;
  final String apartmentName;

  const RentNowPage({
    super.key,
    required this.apartmentId,
    required this.apartmentName,
  });

  @override
  State<RentNowPage> createState() => _RentNowPageState();
}

class _RentNowPageState extends State<RentNowPage> {
  DateTime? startDate;
  DateTime? endDate;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Apartment'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Apartment: ${widget.apartmentName}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => startDate = picked);
              },
              child: Text(startDate == null ? "Pick Start Date" : "Start: ${startDate!.toLocal()}".split(' ')[0]),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: startDate ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => endDate = picked);
              },
              child: Text(endDate == null ? "Pick End Date" : "End: ${endDate!.toLocal()}".split(' ')[0]),
            ),

            const SizedBox(height: 30),

            isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (startDate == null || endDate == null) return;

                      setState(() => isSubmitting = true);

                      // Check apartment status before proceeding
                      DocumentSnapshot apartmentDoc = await FirebaseFirestore.instance
                          .collection('apartments')
                          .doc(widget.apartmentId)
                          .get();

                      if (apartmentDoc.exists && apartmentDoc['status'] == 'available') {
                        final uid = FirebaseAuth.instance.currentUser!.uid;

                        await FirebaseFirestore.instance.collection('rent_now').add({
                          'userId': uid,
                          'apartmentId': widget.apartmentId,
                          'apartmentName': widget.apartmentName,
                          'startDate': startDate,
                          'endDate': endDate,
                          'status': 'active', // Or 'pending' if you want admin approval
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Update the apartment status to 'rented'
                        await FirebaseFirestore.instance.collection('apartments').doc(widget.apartmentId).update({
                          'status': 'rented',
                          'rentedUntil': endDate,
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rented successfully")));
                          Navigator.pop(context);
                        }
                      } else {
                        // Show a message if the apartment is no longer available
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Apartment is no longer available.")));
                        }
                      }

                      setState(() => isSubmitting = false);
                    },
                    child: const Text("Confirm Rent"),
                  ),
          ],
        ),
      ),
    );
  }
}