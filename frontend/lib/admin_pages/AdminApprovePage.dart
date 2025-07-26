import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminIdentificationApprovalPage extends StatelessWidget {
  const AdminIdentificationApprovalPage({super.key});

  void updateStatus(String docId, String status) {
    FirebaseFirestore.instance
        .collection('identifications')
        .doc(docId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Approvals"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('identifications')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Card(
                child: ListTile(
                  title: Text("Apartment: ${data['apartmentName']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Responsible: ${data['responsibleName']}"),
                      Text("ID Number: ${data['responsibleIdNumber']}"),
                      Text("Phone: ${data['responsiblePhone']}"),
                      Text("Workplace: ${data['responsibleWorkPlace']}"),
                      Text("Status: ${data['status']}"),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => updateStatus(docId, "Approved"),
                            child: const Text("Approve"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => updateStatus(docId, "Rejected"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
