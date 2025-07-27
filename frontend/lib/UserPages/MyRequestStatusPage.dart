import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/UserPages/Rent.dart';

class UserIdentificationRequestsPage extends StatelessWidget {
  const UserIdentificationRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Apartment Requests'),
        backgroundColor: Colors.deepPurple,  // changed here
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('identifications')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple)); // changed color
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
              final status = (data['status'] ?? '').toLowerCase();

              // Use purple tones for statuses
              Color statusColor;
              if (status == 'approved') {
                statusColor = Colors.deepPurple.shade400;
              } else if (status == 'rejected') {
                statusColor = Colors.deepPurple.shade200;
              } else {
                statusColor = Colors.deepPurple.shade100;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,  // changed here
                          child: const Icon(Icons.apartment, color: Colors.deepPurple),  // changed here
                        ),
                        title: Text(
                          data['apartmentName'] ?? 'Unknown Apartment',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,  // changed here
                          ),
                        ),
                        subtitle: Text(
                          'Submitted: ${(data['submittedAt'] != null) ? (data['submittedAt'] as Timestamp).toDate().toLocal().toString().split('.')[0] : 'Unknown'}',
                          style: TextStyle(fontSize: 13, color: Colors.deepPurple.shade300),  // changed here
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

                      if (status == 'approved')
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
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
                            icon: const Icon(Icons.payment),
                            label: const Text("Rent Now"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,  // changed here
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
