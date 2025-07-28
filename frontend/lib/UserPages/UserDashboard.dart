import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/UserPages/AvailableApartments.dart';
import 'package:frontend/UserPages/MyRequestStatusPage.dart';
import 'package:frontend/UserPages/my_rented_apartments_page.dart';
import 'material_request_page.dart';
import 'view_notices_page.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('User Dashboard'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shadowColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userEmail',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Available Apartments
            _dashboardCard(
              context,
              icon: Icons.apartment,
              label: 'Available Apartments',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AvailableApartmentsPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // My Requests
            _dashboardCard(
              context,
              icon: Icons.assignment_turned_in,
              label: 'My Requests',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserIdentificationRequestsPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // My Rented Apartments
            _dashboardCard(
              context,
              icon: Icons.home_work,
              label: 'My Rented Apartments',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyRentedApartmentsPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Submit Material Request
            _dashboardCard(
              context,
              icon: Icons.send,
              label: 'Submit Material Request',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MaterialRequestPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // View Notices
            _dashboardCard(
              context,
              icon: Icons.notifications,
              label: 'View Notices',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewNoticesPage()),
                );
              },
            ),

            const Spacer(),
  
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.deepPurple.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.deepPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
