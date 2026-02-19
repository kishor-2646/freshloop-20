import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'buyer/marketplace_view.dart';
import 'home/pantry_view.dart'; // Added for Stage 7
import 'seller/add_product_view.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isSeller = widget.userData['role'] == 'seller';

    // List of pages for the bottom navigation
    final List<Widget> pages = [
      const MarketplaceView(), // Tab 0: Public Marketplace
      const PantryView(),      // Tab 1: Shared Pantry / Groups
      _buildProfileTab(),      // Tab 2: User Profile & Settings
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FreshLoop",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications coming soon!")),
              );
            },
            icon: const Icon(LucideIcons.bell),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // FAB only shows for Sellers to quickly list new items
      floatingActionButton: isSeller
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AddProductView()),
        ),
        label: const Text("List Surplus"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: "Pantry",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green.shade100,
              child: const Icon(LucideIcons.user, size: 50, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text(
              widget.userData['displayName'] ?? "User",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Role: ${widget.userData['role'].toString().toUpperCase()}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(LucideIcons.logOut, color: Colors.red),
              title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
              onTap: () => AuthService().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}