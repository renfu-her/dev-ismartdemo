class Product {
  final String id;
  final String name;
  final String thumb;
  final String price;
  final dynamic special;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.thumb,
    required this.price,
    this.special,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumb: json['thumb'] ?? '',
      price: json['price'] ?? '',
      special: json['special'],
      isFavorite: false,
    );
  }
  
  // 獲取顯示價格
  String get displayPrice {
    return special != null && special != false ? special.toString() : price;
  }
  
  // 獲取原價（如果有特價）
  String get originalPrice {
    return special != null && special != false ? price : '';
  }
  
  // 檢查是否有特價
  bool get hasSpecial {
    return special != null && special != false;
  }
} 