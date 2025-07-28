import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_apartment.dart';

class ApartmentsList extends StatefulWidget {
  @override
  _ApartmentsListState createState() => _ApartmentsListState();
}

class _ApartmentsListState extends State<ApartmentsList> {
  List<Map<String, dynamic>> _apartments = [];
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

  Future<void> _fetchApartments() async {
    try {
      final response = await _firestore.collection('apartments').orderBy('name').get();
      setState(() {
        _apartments = response.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching apartments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteApartment(String id) async {
    try {
      await _firestore.collection('apartments').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apartment deleted successfully')),
      );
      _fetchApartments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting apartment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _apartments.isEmpty
            ? Center(child: Text('No apartments found'))
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _apartments.length,
                itemBuilder: (context, index) {
                  final apt = _apartments[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(Icons.apartment, size: 40, color: Colors.blue),
                      title: Text(
                        apt['name'] ?? 'No Name',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 , ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('Location: ${apt['location']}'),
                          Text('Price: \$${apt['price']?.toStringAsFixed(2) ?? '0.00'}'),
                          Text('Status: ${apt['status']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditApartment(apartment: apt),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Delete ${apt['name']} permanently?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _deleteApartment(apt['id']);
                                    },
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}