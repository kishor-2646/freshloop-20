import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'role_selection_view.dart';
import '../home_screen.dart'; // Import the new Home Screen

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthService().userStatus,
        builder: (context, authSnapshot) {
          // 1. Check if we are still waiting for the Auth state
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. If the user is authenticated, check their Firestore profile
          if (authSnapshot.hasData && authSnapshot.data != null) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(authSnapshot.data!.uid)
                  .snapshots(),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If the profile document doesn't exist yet, go to Role Selection
                if (!firestoreSnapshot.hasData || !firestoreSnapshot.data!.exists) {
                  return const RoleSelectionView();
                }

                // Profile found! Pass the data and navigate to the Home Screen
                final data = firestoreSnapshot.data!.data() as Map<String, dynamic>;
                return HomeScreen(userData: data);
              },
            );
          }

          // 3. User is not logged in - show the Login UI
          return _buildLoginUI(context);
        },
      ),
    );
  }

  Widget _buildLoginUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.recycling, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "FreshLoop",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text("Save food, Save money."),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await AuthService().signInWithGoogle();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Login Failed: $e")),
                  );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text("Continue with Google"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}