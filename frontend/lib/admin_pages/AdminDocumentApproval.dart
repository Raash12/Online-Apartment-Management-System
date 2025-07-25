import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDocumentApprovalPage extends StatefulWidget {
  const AdminDocumentApprovalPage({super.key});

  @override
  State<AdminDocumentApprovalPage> createState() => _AdminDocumentApprovalPageState();
}

class _AdminDocumentApprovalPageState extends State<AdminDocumentApprovalPage> {
  final CollectionReference documentsRef = FirebaseFirestore.instance.collection('documents');

  Future<void> _updateStatus(String docId, String newStatus) async {
    await documentsRef.doc(docId).update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Approvals'), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<QuerySnapshot>(
        stream: documentsRef.where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending documents'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(data['documentUrl'], width: 80, fit: BoxFit.cover),
                  title: Text('User ID: ${data['userId']}'),
                  subtitle: Text('Status: ${data['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateStatus(doc.id, 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateStatus(doc.id, 'denied'),
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
