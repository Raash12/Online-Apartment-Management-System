import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyRentedApartmentsPage extends StatelessWidget {
  const MyRentedApartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Rented Apartments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rentals')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.', style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have not rented any apartments.', style: TextStyle(color: Colors.white)),
            );
          }

          final rentals = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rentalData = rentals[index].data() as Map<String, dynamic>;

              final apartmentName = rentalData['apartmentName'] ?? 'Unknown Apartment';
              final status = (rentalData['status'] ?? '').toString().toLowerCase();

              final createdAtTimestamp = rentalData['createdAt'];
              final createdAt = createdAtTimestamp is Timestamp
                  ? createdAtTimestamp.toDate()
                  : DateTime.now();

              final startDateTimestamp = rentalData['startDate'];
              final startDate = startDateTimestamp is Timestamp
                  ? startDateTimestamp.toDate()
                  : null;

              final endDateTimestamp = rentalData['endDate'];
              final endDate = endDateTimestamp is Timestamp
                  ? endDateTimestamp.toDate()
                  : null;

              final totalAmount = rentalData['totalAmount'] ?? 0.0;
              final paymentReference = rentalData['paymentReference'] ?? 'N/A';

              Color statusColor;
              if (status == 'active') {
                statusColor = Colors.green;
              } else if (status == 'completed') {
                statusColor = Colors.blue;
              } else if (status == 'cancelled') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.grey;
              }

              return Card(
                color: Colors.deepPurple.shade700,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade200,
                          child: const Icon(Icons.home, color: Colors.white),
                        ),
                        title: Text(
                          apartmentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Rented on: ${DateFormat('MMM d, yyyy').format(createdAt)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Chip(
                          label: Text(
                            status.isNotEmpty
                                ? status[0].toUpperCase() + status.substring(1)
                                : '',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (startDate != null)
                        Text('Start Date: ${DateFormat('MMM d, yyyy').format(startDate)}',
                            style: const TextStyle(color: Colors.white)),
                      if (endDate != null)
                        Text('End Date: ${DateFormat('MMM d, yyyy').format(endDate)}',
                            style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Total Paid: \$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Payment Reference: $paymentReference',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.deepPurple[900],
    );
  }
}
