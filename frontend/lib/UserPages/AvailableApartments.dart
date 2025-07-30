import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/UserPages/identification_page.dart';

class AvailableApartmentsPage extends StatelessWidget {
  const AvailableApartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Available Apartments'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('apartments') // Fixed typo from 'apartments'
            .where('status', isEqualTo: 'available')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No available apartments 🏠',
                  style: TextStyle(fontSize: 18)),
            );
          }

          final apartments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final doc = apartments[index];
              final apartment = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              // Additional null checks for apartment data
              final name = apartment['name'] ?? 'Unknown Apartment';
              final rent = apartment['rent']?.toString() ?? 'N/A';
              final location = apartment['location'] ?? 'Location not specified';
              final imageUrl = apartment['imageUrl'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 110,
                                    height: 110,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                )
                              : Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.apartment),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text('Rent: \$$rent'),
                              Text('Location: $location'),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => IdentificationPage(
                                        apartmentId: docId,
                                        apartmentName: name,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.lock_open),
                                label: const Text('Rent Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Add additional apartment details if needed
                    if (apartment['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          apartment['description'],
                          style: TextStyle(color: Colors.grey[600]),
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
}