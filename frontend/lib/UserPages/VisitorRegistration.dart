import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddVisitorPage extends StatefulWidget {
  @override
  _AddVisitorPageState createState() => _AddVisitorPageState();
}

class _AddVisitorPageState extends State<AddVisitorPage> {
  final _formKey = GlobalKey<FormState>();

  String visitorName = '';
  String visitReason = '';
  String apartmentId = '';
  String apartmentName = '';
  bool isLoading = true;

  String checkIn = '';
  String checkOut = '';

  @override
  void initState() {
    super.initState();
    _fetchUserApartment();
  }

  Future<void> _fetchUserApartment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final rentalsQuery = await FirebaseFirestore.instance
        .collection('rentals')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (rentalsQuery.docs.isNotEmpty) {
      final aptId = rentalsQuery.docs.first['apartmentId'] as String;

      final aptDoc = await FirebaseFirestore.instance
          .collection('apartments')
          .doc(aptId)
          .get();

      setState(() {
        apartmentId = aptId;
        apartmentName = aptDoc.exists ? aptDoc['name'] ?? '' : '';
        isLoading = false;
      });
    } else {
      setState(() {
        apartmentId = '';
        apartmentName = '';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You do not have an active rented apartment.')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Purple theme for time picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.deepPurple, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formatted = pickedTime.format(context);
      setState(() {
        if (isCheckIn) {
          checkIn = formatted;
        } else {
          checkOut = formatted;
        }
      });
    }
  }

  Future<void> _registerVisitor() async {
    if (!_formKey.currentState!.validate()) return;

    if (apartmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apartment info not found')),
      );
      return;
    }

    if (checkIn.isEmpty || checkOut.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both check-in and check-out times')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('visitors').add({
      'visitor_name': visitorName,
      'visit_reason': visitReason,
      'apartment_id': apartmentId,
      'apartment_name': apartmentName,
      'visited_by': user.uid,
      'check_in': checkIn,
      'check_out': checkOut,
      'created_at': Timestamp.now(),
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visitor registered successfully and awaiting approval')),
    );

    _formKey.currentState!.reset();
    setState(() {
      checkIn = '';
      checkOut = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Register Visitor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white), // back button color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : apartmentId.isEmpty
              ? Center(
                  child: Text(
                    'No active apartment assigned to your account.',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text(
                          'Apartment:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          apartmentName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Visitor Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) => visitorName = val,
                          validator: (val) => val!.isEmpty ? 'Visitor Name is required' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Visit Reason',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) => visitReason = val,
                          validator: (val) => val!.isEmpty ? 'Visit Reason is required' : null,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 30),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.deepPurple),
                          ),
                          title: Text(
                            checkIn.isEmpty ? 'Select Check-In Time' : 'Check-In: $checkIn',
                            style: TextStyle(
                              color: checkIn.isEmpty ? Colors.grey : Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          trailing: const Icon(Icons.access_time, color: Colors.deepPurple),
                          onTap: () => _selectTime(context, true),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.deepPurple),
                          ),
                          title: Text(
                            checkOut.isEmpty ? 'Select Check-Out Time' : 'Check-Out: $checkOut',
                            style: TextStyle(
                              color: checkOut.isEmpty ? Colors.grey : Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          trailing: const Icon(Icons.access_time, color: Colors.deepPurple),
                          onTap: () => _selectTime(context, false),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: _registerVisitor,
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
