import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyRentedApartmentsPage extends StatelessWidget {
  const MyRentedApartmentsPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchMyRentals() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final rentalQuery = await FirebaseFirestore.instance
        .collection('rent_now')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    List<Map<String, dynamic>> detailedRentals = [];

    for (var doc in rentalQuery.docs) {
      final rentalData = doc.data();
      final apartmentId = rentalData['apartmentId'];

      final apartmentDoc = await FirebaseFirestore.instance
          .collection('apartments')
          .doc(apartmentId)
          .get();

      if (apartmentDoc.exists) {
        final apartmentData = apartmentDoc.data();
        detailedRentals.add({
          'id': doc.id,
          'rental': rentalData,
          'apartment': apartmentData,
        });
      }
    }

    return detailedRentals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Rented Apartments",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMyRentals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work, size: 64, color: Colors.deepPurple[300]),
                  const SizedBox(height: 20),
                  const Text("No rentals found",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("You haven't rented any apartments yet",
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final rentals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rental = rentals[index]['rental'];
              final apartment = rentals[index]['apartment'];
              final rentalId = rentals[index]['id'];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.deepPurple.shade100, width: 1),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (apartment['imageUrl'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          apartment['imageUrl'],
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(
                              height: 180,
                              color: Colors.deepPurple.shade50,
                              child: Icon(Icons.home, size: 64, color: Colors.deepPurple.shade200),
                            ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  apartment['name'] ?? 'Apartment',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[800],
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  rental['status'].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: rental['status'] == 'active'
                                    ? Colors.green
                                    : Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.location_on, 
                              apartment['location'] ?? 'Unknown location'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.description, 
                              apartment['description'] ?? 'No description available'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.attach_money, 
                              "\$${(apartment['rent'] ?? 0).toString()} per day"),
                          const Divider(height: 24, thickness: 1),
                          _buildRentalInfo("Start Date", 
                              DateFormat('MMM d, yyyy').format(rental['startDate'].toDate())),
                          _buildRentalInfo("End Date", 
                              DateFormat('MMM d, yyyy').format(rental['endDate'].toDate())),
                          _buildRentalInfo("Total Paid", 
                              "\$${rental['paymentAmount'].toStringAsFixed(2)}"),
                          const SizedBox(height: 16),
                          _buildReferenceInfo("Payment Reference", rental['paymentReference']),
                          _buildReferenceInfo("Transaction ID", rentalId),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildRentalInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple[700],
          )),
          Text(value, style: const TextStyle(
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _buildReferenceInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label:", style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple[600],
          )),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple[800],
          )),
        ],
      ),
    );
  }
}