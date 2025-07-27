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
    final themeColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Identification Approvals"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white, 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('identifications')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeColor.shade700, themeColor.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🏢 Apartment: ${data['apartmentName']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("👤 Responsible: ${data['responsibleName']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("🆔 ID Number: ${data['responsibleIdNumber']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("📞 Phone: ${data['responsiblePhone']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("🏢 Workplace: ${data['responsibleWorkPlace']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("📌 Status: ${data['status']}",
                          style: const TextStyle(
                              color: Colors.white70, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => updateStatus(docId, "Approved"),
                            icon: const Icon(Icons.check),
                            label: const Text("Approve"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => updateStatus(docId, "Rejected"),
                            icon: const Icon(Icons.close),
                            label: const Text("Reject"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
