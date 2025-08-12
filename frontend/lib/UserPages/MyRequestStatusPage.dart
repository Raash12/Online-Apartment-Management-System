import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserIdentificationRequestsPage extends StatelessWidget {
  const UserIdentificationRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Enables back arrow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context), // ✅ Go back
        ),
        title: const Text('My Identification Requests'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('identifications') // ✅ Use identifications
            .where('userId', isEqualTo: currentUserId) // ✅ Current user’s requests
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have no identification requests.'),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData =
                  requests[index].data() as Map<String, dynamic>;

              final apartmentName =
                  requestData['apartmentName'] ?? 'Unknown Apartment';
              final status =
                  (requestData['status'] ?? 'Pending').toString().toLowerCase();

              final submittedAtTimestamp = requestData['submittedAt'];
              final submittedAt = submittedAtTimestamp is Timestamp
                  ? submittedAtTimestamp.toDate()
                  : DateTime.now();

              // ✅ Status color mapping
              Color statusColor;
              if (status == 'approved') {
                statusColor = Colors.green;
              } else if (status == 'rejected') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.orange; // pending
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
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
                          backgroundColor: Colors.deepPurple.shade50,
                          child: const Icon(Icons.assignment,
                              color: Colors.deepPurple),
                        ),
                        title: Text(
                          apartmentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: Text(
                          'Submitted on: ${DateFormat('MMM d, yyyy').format(submittedAt)}',
                          style: TextStyle(color: Colors.deepPurple.shade300),
                        ),
                        trailing: Chip(
                          label: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Responsible: ${requestData['responsibleName'] ?? 'N/A'}"),
                      Text("ID Number: ${requestData['responsibleIdNumber'] ?? 'N/A'}"),
                      Text("Phone: ${requestData['responsiblePhone'] ?? 'N/A'}"),
                      Text("Workplace: ${requestData['responsibleWorkPlace'] ?? 'N/A'}"),
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
