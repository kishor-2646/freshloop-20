import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  Future<void> _saveRole(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'role': role,
        'trustScore': 100,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Navigation to Dashboard will happen automatically via the Auth Stream
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("How will you use FreshLoop?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _roleCard(context, "Buyer", "I want to buy surplus food", LucideIcons.shoppingCart, "buyer"),
            const SizedBox(height: 16),
            _roleCard(context, "Seller", "I have surplus food to sell", LucideIcons.store, "seller"),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, String title, String sub, IconData icon, String role) {
    return InkWell(
      onTap: () => _saveRole(context, role),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(sub, style: const TextStyle(color: Colors.grey)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}