import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Added for Stage 8

class ProductDetailsView extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    int freshness = product['freshness'] ?? 0;
    Color statusColor = freshness > 70 ? Colors.green : (freshness > 30 ? Colors.orange : Colors.red);
    String hash = product['blockchainHash'] ?? "verification-pending";

    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product['imageUrl'],
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(height: 300, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50)),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product['name'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text("\$${product['price']}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.leaf, color: statusColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Freshness Score: $freshness%", style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                              const Text("Safe to consume based on storage logic."),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Item Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  _detailRow(LucideIcons.package, "Quantity", "${product['quantity']}"),
                  _detailRow(LucideIcons.thermometer, "Storage", "${product['storage']}"),

                  const SizedBox(height: 24),

                  // --- STAGE 8: PROVENANCE SECTION ---
                  const Text("Provenance & Trust", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        QrImageView(
                          data: hash,
                          version: QrVersions.auto,
                          size: 80.0,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Digital ID Verified", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              Text(
                                "Hash: ${hash.substring(0, 16)}...",
                                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.blueGrey),
                              ),
                              const Text("Recorded on FreshLoop ledger.", style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Purchase request sent!")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Buy Now", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}