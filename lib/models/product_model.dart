class Product {
  final String id;
  final String sellerId;
  final String name;
  final double quantity;
  final String unit; // kg, pieces, etc.
  final DateTime buyingDate;
  final String storageType; // Fridge, Room, Outdoor
  final String imageUrl;
  final double initialPrice;
  final int freshnessScore;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.buyingDate,
    required this.storageType,
    required this.imageUrl,
    required this.initialPrice,
    required this.freshnessScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'buyingDate': buyingDate.toIso8601String(),
      'storageType': storageType,
      'imageUrl': imageUrl,
      'initialPrice': initialPrice,
      'freshnessScore': freshnessScore,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}