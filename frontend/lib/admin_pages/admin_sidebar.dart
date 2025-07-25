import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const AdminSidebar({Key? key, required this.selectedMenu, required this.onMenuSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple.shade700,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Center(
                child: Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildMenuItem('Dashboard', Icons.dashboard, 'dashboard'),
            _buildMenuItem('Apartments', Icons.home, 'apartments'),
            _buildMenuItem('Leases', Icons.assignment, 'leases'),
            _buildMenuItem('Feedback', Icons.feedback, 'feedback'),
            _buildMenuItem('Active Users', Icons.people, 'active_users'),
            _buildMenuItem('Logout', Icons.logout, 'logout'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, String menuKey) {
    final bool isSelected = menuKey == selectedMenu;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.deepPurple.shade900 : Colors.transparent,
      onTap: () => onMenuSelected(menuKey),
    );
  }
}
