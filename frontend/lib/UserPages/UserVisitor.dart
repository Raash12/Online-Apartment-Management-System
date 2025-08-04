import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserVisitorsPage extends StatelessWidget {
  const UserVisitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Visitors'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('visitors')
            .where('visited_by', isEqualTo: currentUserId)
           
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No visitors registered yet.'));
          }

          final visitors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              final data = visitors[index].data() as Map<String, dynamic>;

              final status = (data['status'] ?? '').toLowerCase();

              Color statusColor;
              if (status == 'approved') {
                statusColor = Colors.green;
              } else if (status == 'rejected') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.grey;
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
                          backgroundColor: Colors.deepPurple.shade50,
                          child: const Icon(Icons.person, color: Colors.deepPurple),
                        ),
                        title: Text(
                          data['visitor_name'] ?? 'Unknown Visitor',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apartment: ${data['apartment_name'] ?? 'Unknown'}',
                              style: TextStyle(fontSize: 13, color: Colors.deepPurple.shade300),
                            ),
                            Text(
                              'Visit Reason: ${data['visit_reason'] ?? ''}',
                              style: TextStyle(fontSize: 13, color: Colors.deepPurple.shade300),
                            ),
                            Text(
                              'Check-In: ${data['check_in'] ?? '-'}  |  Check-Out: ${data['check_out'] ?? '-'}',
                              style: TextStyle(fontSize: 13, color: Colors.deepPurple.shade300),
                            ),
                            Text(
                              'Submitted: ${(data['created_at'] != null) ? (data['created_at'] as Timestamp).toDate().toLocal().toString().split('.')[0] : 'Unknown'}',
                              style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade200),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            status.isNotEmpty
                                ? status[0].toUpperCase() + status.substring(1)
                                : 'Pending',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: statusColor,
                        ),
                      ),

                      // You can add action buttons here if needed
                      // For example, to show details or delete visitor

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
