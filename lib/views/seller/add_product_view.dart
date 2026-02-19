import 'dart:io';
import 'dart:convert'; // Added for utf8.encode
import 'package:crypto/crypto.dart'; // Added for hashing
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  File? _image;
  String _storageType = 'Fridge';
  DateTime _buyingDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _submit() async {
    if (_image == null || _nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and add a photo")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Image to Storage
      String fileName = const Uuid().v4();
      var ref = FirebaseStorage.instance.ref().child('products/$fileName');
      await ref.putFile(_image!);
      String url = await ref.getDownloadURL();

      // 2. Calculate Simple Freshness
      int daysOld = DateTime.now().difference(_buyingDate).inDays;
      int freshness = (100 - (daysOld * 15)).clamp(0, 100);

      // 3. Generate Mock Blockchain Hash (Digital Fingerprint)
      String timestamp = DateTime.now().toIso8601String();
      String sellerId = FirebaseAuth.instance.currentUser!.uid;
      String rawData = "$sellerId-$timestamp-${_nameController.text}";
      String productHash = sha256.convert(utf8.encode(rawData)).toString();

      // 4. Save to Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'sellerId': sellerId,
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantity': _qtyController.text,
        'imageUrl': url,
        'storage': _storageType,
        'freshness': freshness,
        'blockchainHash': productHash, // Added for Stage 8
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List New Surplus")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _qtyController, decoration: const InputDecoration(labelText: "Quantity (e.g. 2kg)", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (\$)", border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text("Storage Condition:", style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _storageType,
            isExpanded: true,
            items: ['Fridge', 'Room', 'Outdoor'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _storageType = v!),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Publish Verified Listing"),
          ),
        ],
      ),
    );
  }
}