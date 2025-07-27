import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/admin_pages/AdminApprovePage.dart';
import 'package:frontend/admin_pages/add_apartment.dart';
import 'package:frontend/admin_pages/admin_apartment_view.dart';
import 'package:frontend/admin_pages/post_notice_page.dart';
import 'package:frontend/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isCollapsed = true;

  final List<String> imagePaths = [
    'image/apartment1.jpg',
    'image/apartment2.jpg',
    'image/apartment3.jpg',
    'image/apartment4.jpg',
  ];

  final List<String> titles = [
    'Luxury Ride',
    'Performance Beast',
    'Eco-Friendly Drive',
    'Spacious Family Home'
  ];

  final List<String> descriptions = [
    'Experience unmatched comfort and class.',
    'Power and speed blended with style.',
    'Go green without compromising performance.',
    'Perfect for modern family living.'
  ];

  late final PageController _pageController;
  int _currentPage = 0;

  int apartmentCount = 0;
  int requestCount = 0;
  int rentedCount = 0;
  int materialPendingCount = 0;
  int materialApprovedCount = 0;
  int identificationApprovedCount = 0;
  int identificationPendingCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoPlay();
    _fetchCounts();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_currentPage < imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
      _startAutoPlay();
    });
  }

  Future<void> _fetchCounts() async {
    final firestore = FirebaseFirestore.instance;

    final apartments = await firestore.collection('apartments').get();
    final identifications = await firestore.collection('identifications').get();
    final rentNow = await firestore.collection('rent_now').get();

    final materialPending = await firestore
        .collection('material_requests')
        .where('status', isEqualTo: 'pending')
        .get();

    final materialApproved = await firestore
        .collection('material_requests')
        .where('status', isEqualTo: 'approved')
        .get();

    final identificationApproved = await firestore
        .collection('identifications')
        .where('status', isEqualTo: 'Approved')
        .get();

    final identificationPending = await firestore
        .collection('identifications')
        .where('status', isEqualTo: 'Pending')
        .get();

    setState(() {
      apartmentCount = apartments.docs.length;
      requestCount = identifications.docs.length;
      rentedCount = rentNow.docs.length;
      materialPendingCount = materialPending.docs.length;
      materialApprovedCount = materialApproved.docs.length;
      identificationApprovedCount = identificationApproved.docs.length;
      identificationPendingCount = identificationPending.docs.length;
    });
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, {Color? textColor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth / 3 - 24;
        return SizedBox(
          width: cardWidth,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      count,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: cards,
        );
      },
    );
  }

  Widget _buildIdentificationStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Identification Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        _buildStatsGrid([
          _buildStatCard(
            'Approved',
            identificationApprovedCount.toString(),
            Icons.verified,
            Colors.green,
          ),
          _buildStatCard(
            'Pending',
            identificationPendingCount.toString(),
            Icons.pending,
            Colors.orange,
          ),
          _buildStatCard(
            'Total',
            requestCount.toString(),
            Icons.assignment,
            Colors.deepPurple,
          ),
        ]),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        _buildStatsGrid([
          _buildStatCard(
            'Apartments', 
            apartmentCount.toString(),
            Icons.apartment, 
            Colors.indigo
          ),
          _buildStatCard(
            'Rented', 
            rentedCount.toString(),
            Icons.car_rental, 
            Colors.teal
          ),
          _buildStatCard(
            'Pending Material', 
            materialPendingCount.toString(),
            Icons.pending_actions, 
            Colors.amber
          ),
          _buildStatCard(
            'Approved Material', 
            materialApprovedCount.toString(),
            Icons.check_circle_outline, 
            Colors.lightGreen
          ),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
        ]),
      ],
    );
  }

  Widget _buildSidebar() {
    if (_isCollapsed) return const SizedBox.shrink();
    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 100,
            color: Colors.deepPurple,
            child: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _buildSidebarItem(Icons.add_circle_outline, 'Add Apartment', const AddApartmentPage()),
          _buildSidebarItem(Icons.houseboat_rounded, 'Apartments list', const AdminApartmentViewPage()),
          _buildSidebarItem(Icons.perm_identity, 'Identication', const AdminIdentificationApprovalPage()),
          _buildSidebarItem(Icons.notifications_active, 'Send Notice', const PostNoticePage()),
          const Spacer(),
          _buildSidebarItem(Icons.logout, 'Logout', LoginScreen(), isLogout: true),
        ],
      ),
    );
  }

  Widget _buildAppBarActions() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            _fetchCounts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data refreshed')),
            );
            break;
          case 'settings':
            // Add your settings navigation here
            break;
          case 'help':
            // Add your help navigation here
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'refresh',
          child: Text('Refresh Data'),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Settings'),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: Text('Help & Support'),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Row(
      children: [
        IconButton(
          icon: Icon(_isCollapsed ? Icons.menu : Icons.close, color: Colors.deepPurple),
          onPressed: () {
            setState(() {
              _isCollapsed = !_isCollapsed;
            });
          },
        ),
        const Spacer(),
        _buildAppBarActions(),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, Widget targetPage, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetPage),
        );
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imagePaths.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Transform.scale(scale: value, child: child);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(imagePaths[index], fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 30,
                      child: Text(
                        titles[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      right: 12,
                      child: Text(
                        descriptions[index],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildToggleButton(),
                          const SizedBox(height: 10),
                          _buildCarousel(),
                          _buildStatsCards(),
                          _buildIdentificationStats(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}