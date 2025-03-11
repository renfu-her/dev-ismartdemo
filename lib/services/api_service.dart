import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/product.dart';
import '../models/banner.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.appUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    // 添加攔截器用於日誌記錄和錯誤處理
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e);
      },
    ));
  }

  // 獲取最新商品
  Future<List<Product>> getLatestProducts({int limit = 8}) async {
    try {
      final response = await _dio.get(
        '${AppConfig.latestProductsEndpoint}&limit=$limit&api_key=${AppConfig.apiKey}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['latest_products'] ?? [];
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load latest products');
      }
    } catch (e) {
      print('Error getting latest products: $e');
      // 在開發階段，返回一些模擬數據以便測試UI
      if (AppConfig.appUrl.contains('example.com')) {
        return _getMockProducts();
      }
      throw Exception('Failed to load latest products: $e');
    }
  }

  // 獲取熱門商品
  Future<List<Product>> getPopularProducts({int limit = 8}) async {
    try {
      final response = await _dio.get(
        '${AppConfig.popularProductsEndpoint}&limit=$limit&api_key=${AppConfig.apiKey}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['latest_products'] ?? [];
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      print('Error getting popular products: $e');
      // 在開發階段，返回一些模擬數據以便測試UI
      if (AppConfig.appUrl.contains('example.com')) {
        return _getMockProducts();
      }
      throw Exception('Failed to load popular products: $e');
    }
  }

  // 獲取首頁橫幅
  Future<List<HomeBanner>> getHomeBanners() async {
    try {
      final response = await _dio.get(
        '${AppConfig.homeBannerEndpoint}&api_key=${AppConfig.apiKey}',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['banners'] ?? [];
        return data.map((item) => HomeBanner.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load home banners');
      }
    } catch (e) {
      print('Error getting home banners: $e');
      // 在開發階段，返回一些模擬數據以便測試UI
      if (AppConfig.appUrl.contains('example.com')) {
        return _getMockBanners();
      }
      throw Exception('Failed to load home banners: $e');
    }
  }
  
  // 模擬產品數據（用於開發測試）
  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: '1個 有團購 測試',
        description: '測試商品描述',
        thumb: 'https://via.placeholder.com/300x200/FFA500/FFFFFF?text=Product+1',
        price: '2000',
        special: null,
        href: 'https://example.com/product/1',
        wishlistAdd: 'https://example.com/wishlist/add/1',
        wishlistRemove: 'https://example.com/wishlist/remove/1',
        basePrice: '2000',
        minimum: '1',
      ),
      Product(
        id: '2',
        name: '2個-有選項(顏色/尺寸)-金額"加"',
        description: '測試商品描述',
        thumb: 'https://via.placeholder.com/300x200/4682B4/FFFFFF?text=Product+2',
        price: '100',
        special: '80',
        href: 'https://example.com/product/2',
        wishlistAdd: 'https://example.com/wishlist/add/2',
        wishlistRemove: 'https://example.com/wishlist/remove/2',
        basePrice: '100',
        baseSpecial: '80',
        minimum: '1',
      ),
      Product(
        id: '3',
        name: '紅色T恤',
        description: '測試商品描述',
        thumb: 'https://via.placeholder.com/300x200/FF0000/FFFFFF?text=Red+Shirt',
        price: '450',
        special: '350',
        href: 'https://example.com/product/3',
        wishlistAdd: 'https://example.com/wishlist/add/3',
        wishlistRemove: 'https://example.com/wishlist/remove/3',
        basePrice: '450',
        baseSpecial: '350',
        minimum: '1',
      ),
      Product(
        id: '4',
        name: '時尚照片',
        description: '測試商品描述',
        thumb: 'https://via.placeholder.com/300x200/000000/FFFFFF?text=Fashion+Photo',
        price: '299',
        special: '199',
        href: 'https://example.com/product/4',
        wishlistAdd: 'https://example.com/wishlist/add/4',
        wishlistRemove: 'https://example.com/wishlist/remove/4',
        basePrice: '299',
        baseSpecial: '199',
        minimum: '1',
      ),
    ];
  }
  
  // 模擬橫幅數據（用於開發測試）
  List<HomeBanner> _getMockBanners() {
    return [
      HomeBanner(
        title: '促銷活動',
        link: 'https://example.com/promo',
        image: 'https://via.placeholder.com/800x400/FF5733/FFFFFF?text=Promotion',
      ),
      HomeBanner(
        title: '新品上市',
        link: 'https://example.com/new',
        image: 'https://via.placeholder.com/800x400/33A8FF/FFFFFF?text=New+Arrivals',
      ),
    ];
  }
} 