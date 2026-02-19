import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/group_service.dart';

class PantryView extends StatelessWidget {
  const PantryView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final groups = snapshot.data!.docs;

        if (groups.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            var group = groups[index];
            return ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(LucideIcons.users, color: Colors.white)),
              title: Text(group['name']),
              subtitle: Text("Invite Code: ${group['inviteCode']}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Future: Show items specifically for this group
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.users, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No Shared Pantries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Share with neighbors or roommates."),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateDialog(context),
            child: const Text("Create a Group"),
          ),
          TextButton(
            onPressed: () => _showJoinDialog(context),
            child: const Text("Join with Code"),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("New Pantry Group"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Group Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await GroupService().createGroup(controller.text);
              Navigator.pop(c);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Join Pantry"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter 6-digit Code")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              bool success = await GroupService().joinGroup(controller.text);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Code")));
              }
              Navigator.pop(c);
            },
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }
}