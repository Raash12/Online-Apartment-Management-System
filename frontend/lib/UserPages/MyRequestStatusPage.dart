import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/UserPages/Rent.dart';

// Import your RentNowPage here
 // Adjust the path as needed

class UserIdentificationRequestsPage extends StatelessWidget {
  const UserIdentificationRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('identifications')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requests submitted yet.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apartment, color: Colors.blue),
                      title: Text(data['apartmentName'] ?? 'Unknown Apartment'),
                      subtitle: Text('Status: ${data['status'] ?? 'N/A'}'),
                      trailing: Text(
                        (data['submittedAt'] != null)
                            ? (data['submittedAt'] as Timestamp)
                                .toDate()
                                .toLocal()
                                .toString()
                                .split('.')[0]
                            : '',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),

                    // Show Rent Now Button only if status is 'approved'
                    if ((data['status'] ?? '').toLowerCase() == 'approved')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RentNowPage(
                                  apartmentId: data['apartmentId'],
                                  apartmentName: data['apartmentName'],
                                ),
                              ),
                            );
                          },
                          child: const Text("Rent Now"),
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
