class Product {
  final String id;
  final String name;
  final String description;
  final String thumb;
  final String price;
  final dynamic special;
  final String href;
  final bool wishlistStatus;
  final String wishlistAdd;
  final String wishlistRemove;
  final String minimum;
  final List<dynamic> options;
  final String basePrice;
  final dynamic baseSpecial;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.thumb,
    required this.price,
    this.special,
    required this.href,
    this.wishlistStatus = false,
    required this.wishlistAdd,
    required this.wishlistRemove,
    this.minimum = '1',
    this.options = const [],
    required this.basePrice,
    this.baseSpecial,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      thumb: json['thumb'] ?? '',
      price: json['price'] ?? '',
      special: json['special'],
      href: json['href'] ?? '',
      wishlistStatus: json['wishlist_status'] ?? false,
      wishlistAdd: json['wishlist_add'] ?? '',
      wishlistRemove: json['wishlist_remove'] ?? '',
      minimum: json['minimum'] ?? '1',
      options: json['options'] ?? [],
      basePrice: json['base_price'] ?? '0',
      baseSpecial: json['base_special'],
      isFavorite: json['wishlist_status'] ?? false,
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
  
  // 獲取基本價格（用於計算）
  double get numericBasePrice {
    try {
      return double.parse(basePrice);
    } catch (e) {
      return 0.0;
    }
  }
  
  // 獲取基本特價（用於計算）
  double get numericBaseSpecial {
    if (baseSpecial == null || baseSpecial == false) return 0.0;
    try {
      return double.parse(baseSpecial.toString());
    } catch (e) {
      return 0.0;
    }
  }
} 