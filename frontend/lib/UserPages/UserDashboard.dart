import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/UserPages/AvailableApartments.dart';
import 'package:frontend/UserPages/MyRequestStatusPage.dart';
import 'package:frontend/UserPages/Userprofile.dart';
import 'package:frontend/UserPages/my_rented_apartments_page.dart';
import 'package:frontend/UserPages/material_request_page.dart';
import 'package:frontend/UserPages/view_notices_page.dart';
import 'package:frontend/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  bool _isCollapsed = true;
  late PageController _pageController;
  int _currentPage = 0;
  int noticeCount = 0;
  int pendingRequestsCount = 0;
  int rentedApartmentsCount = 0;

  final List<String> imagePaths = [
    'image/p1.jpg',
    'image/p2.jpg',
    'image/p3.jpg',
    'image/p4.jpg',
  ];

  final List<String> titles = [
    'Luxury Retreat',
    'Modern Haven',
    'Eco Smart Living',
    'Family Comfort Space',
  ];

  final List<String> descriptions = [
    'Experience unmatched comfort and elegance',
    'A modern sanctuary with premium finishes',
    'Eco-conscious living with smart design',
    'Spacious, safe, and perfect for your family',
  ];

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;

    // Get notices count
    final notices = await firestore.collection('notices').get();
    
    // Get pending requests count for this user
    final pendingRequests = await firestore
        .collection('identifications')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Pending')
        .get();

    // Get rented apartments count for this user
    final rentedApartments = await firestore
        .collection('rent_now')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      noticeCount = notices.docs.length;
      pendingRequestsCount = pendingRequests.docs.length;
      rentedApartmentsCount = rentedApartments.docs.length;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSidebar() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('image/profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildSidebarItem(
                  Icons.dashboard,
                  'Dashboard',
                  () {
                    setState(() {
                      _currentIndex = 0;
                      _isCollapsed = true;
                    });
                  },
                ),
                _buildSidebarItem(
                  Icons.apartment,
                  'Available Apartments',
                  () {
                    setState(() {
                      _currentIndex = 1;
                      _isCollapsed = true;
                    });
                  },
                ),
                _buildSidebarItem(
                  Icons.home_work,
                  'My Rented Apartments',
                  () {
                    setState(() {
                      _currentIndex = 2;
                      _isCollapsed = true;
                    });
                  },
                ),
                _buildSidebarItem(
                  Icons.assignment,
                  'My Requests',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserIdentificationRequestsPage()),
                    );
                    setState(() {
                      _isCollapsed = true;
                    });
                  },
                ),
                _buildSidebarItem(
                  Icons.send,
                  'Submit Material Request',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MaterialRequestPage()),
                    );
                    setState(() {
                      _isCollapsed = true;
                    });
                  },
                ),
                _buildSidebarItem(
                  Icons.notifications,
                  'View Notices',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ViewNoticesPage()),
                    );
                    setState(() {
                      _isCollapsed = true;
                    });
                  },
                ),
                const Divider(height: 30, thickness: 0.5, indent: 20, endIndent: 20),
                _buildSidebarItem(
                  Icons.logout,
                  'Logout',
                  () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) =>  LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Container(color: Colors.grey[300]),
                    ),
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
                      left: 16,
                      bottom: 40,
                      child: Text(
                        titles[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Text(
                        descriptions[index],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 150, // Fixed height for consistency
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildActionButton(
                Icons.apartment,
                'Available\nApartments',
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AvailableApartmentsPage()),
                ),
              ),
              _buildActionButton(
                Icons.send,
                'Submit\nRequest',
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MaterialRequestPage()),
                ),
              ),
              _buildActionButton(
                Icons.notifications,
                'View\nNotices',
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewNoticesPage()),
                ),
              ),
              _buildActionButton(
                Icons.help_outline,
                'Help &\nSupport',
                Colors.purple,
                () => _showHelpDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 100, // Fixed height for quick action buttons
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For any assistance, please contact our support team at:\n\n'
          'Email: support@apartmentmgmt.com\n'
          'Phone: +1 (123) 456-7890\n\n'
          'We are available 24/7 to help you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return AvailableApartmentsPage();
      case 2:
        return const MyRentedApartmentsPage();
      case 3:
        return const UserProfilePage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'User';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Welcome back, ${userEmail.split('@')[0]}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Manage your apartment rentals easily',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          _buildCarousel(),
          const SizedBox(height: 16),
          // Responsive stat cards section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop layout - horizontal cards
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Pending Requests',
                      pendingRequestsCount.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Rented Apartments',
                      rentedApartmentsCount.toString(),
                      Icons.home_work,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'New Notices',
                      noticeCount.toString(),
                      Icons.notifications,
                      Colors.blue,
                    ),
                  ],
                );
              } else {
                // Mobile layout - vertical cards with scrolling
                return SizedBox(
                  height: 170,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _buildStatCard(
                        'Pending Requests',
                        pendingRequestsCount.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Rented Apartments',
                        rentedApartmentsCount.toString(),
                        Icons.home_work,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'New Notices',
                        noticeCount.toString(),
                        Icons.notifications,
                        Colors.blue,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                _buildActivityItem(
                  Icons.apartment,
                  'Available Apartments',
                  'Browse our latest apartment listings',
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AvailableApartmentsPage()),
                  ),
                ),
                _buildActivityItem(
                  Icons.assignment,
                  'Request Status',
                  'Check your identification requests',
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserIdentificationRequestsPage()),
                  ),
                ),
                _buildActivityItem(
                  Icons.home,
                  'My Rented Apartments',
                  'View your current rentals',
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyRentedApartmentsPage()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildProfilePage() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile_placeholder.jpg'),
          ),
          const SizedBox(height: 20),
          Text(
            user?.email ?? 'User',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _isCollapsed ? const SizedBox.shrink() : _buildSidebar(),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _currentIndex == 0 
                  ? AppBar(
                      title: const Text('Dashboard'),
                      centerTitle: true,
                      elevation: 0,
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      leading: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                          });
                        },
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ViewNoticesPage()),
                            );
                          },
                        ),
                      ],
                    )
                  : null,
              body: _buildCurrentPage(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.deepPurple,
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.apartment),
                    label: 'Apartments',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_work),
                    label: 'My Rentals',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
              floatingActionButton: _currentIndex == 0
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MaterialRequestPage()),
                        );
                      },
                      backgroundColor: Colors.deepPurple,
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}