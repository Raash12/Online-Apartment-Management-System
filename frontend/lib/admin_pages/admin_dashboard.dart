import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/admin_pages/add_apartment.dart';
import 'package:frontend/admin_pages/apartments_list.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late Widget _currentPage;
  int totalApartments = 0;
  int rentedApartments = 0;
  int availableApartments = 0;
  bool isLoading = true;

  final List<String> imagePaths = [
    'assets/image/apartment1.jpg',
    'assets/image/apartment2.jpg',
    'assets/image/apartment3.jpg',
  ];
  final List<String> titles = [
    'Luxury Living',
    'Modern Design',
    'City Views',
  ];
  final List<String> descriptions = [
    'Experience premium apartment living',
    'Contemporary designs for modern lifestyles',
    'Stunning views in prime locations',
  ];
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    ApartmentsList(),
    Center(child: Text('Analytics Page')),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = _pages[_selectedIndex];
    _fetchApartmentCounts();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchApartmentCounts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('apartments')
          .get();

      final apartments = snapshot.docs.map((doc) => doc.data()).toList();
      final rented = apartments.where((apt) => apt['status'] == 'occupied').length;

      setState(() {
        totalApartments = apartments.length;
        rentedApartments = rented;
        availableApartments = totalApartments - rented;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching apartment counts: $e');
      setState(() => isLoading = false);
    }
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _currentPageIndex = (_currentPageIndex + 1) % imagePaths.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _startAutoPlay();
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text(count,
                style: TextStyle(
                    fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGrid(List<Widget> cards, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: cards,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentPage = _pages[_selectedIndex];
    });
    Navigator.pop(context);
  }

  void _goToAddApartment() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddApartment()),
    ).then((_) {
      if (_selectedIndex == 0) {
        setState(() {
          _pages[0] = ApartmentsList();
          _currentPage = _pages[0];
        });
        _fetchApartmentCounts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [
      _buildStatCard(
        icon: Icons.apartment,
        title: 'Total Apartments',
        count: isLoading ? '...' : totalApartments.toString(),
        color: Colors.blue[800]!,
      ),
      _buildStatCard(
        icon: Icons.assignment_turned_in,
        title: 'Rented Apartments',
        count: isLoading ? '...' : rentedApartments.toString(),
        color: Colors.green[700]!,
      ),
      _buildStatCard(
        icon: Icons.home_work_outlined,
        title: 'Available Apartments',
        count: isLoading ? '...' : availableApartments.toString(),
        color: Colors.orange[700]!,
      ),
      _buildQuickAction(
        icon: Icons.add,
        label: 'Add Apartment',
        color: Colors.blue[800]!,
        onTap: _goToAddApartment,
      ),
      _buildQuickAction(
        icon: Icons.list,
        label: 'View All Apartments',
        color: Colors.purple[700]!,
        onTap: () => _onItemTapped(0),
      ),
      _buildQuickAction(
        icon: Icons.analytics,
        label: 'View Analytics',
        color: Colors.teal[700]!,
        onTap: () => _onItemTapped(1),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.blue[800],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.view_list),
                label: Text('View Apartments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_business),
                label: Text('Add Apartment'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ],
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: imagePaths.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        imagePaths[index],
                                        fit: BoxFit.cover,
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
                                          style: TextStyle(
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
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imagePaths.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPageIndex == index
                                    ? Colors.blue[800]
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildCardGrid(cards, context),
                        _currentPage,
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
