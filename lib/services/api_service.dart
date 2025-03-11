import 'package:dio/dio.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';
import '../models/product.dart';
import '../models/banner.dart';
import 'package:dio/io.dart'; // 添加這個導入以使用IOHttpClientAdapter

class ApiService {
  late Dio _dio;
  final int _maxRetries = 3;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.appUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // 添加以下設置以解決雷電模擬器的網絡問題
      validateStatus: (status) {
        return status != null && status < 500;
      },
      // 禁用HTTPS證書驗證（僅用於開發環境）
      // 在生產環境中應該移除此設置
      followRedirects: true,
      maxRedirects: 5,
    ));
    
    // 設置代理（如果啟用）
    if (AppConfig.useProxy) {
      _dio.httpClientAdapter = IOHttpClientAdapter()
        ..onHttpClientCreate = (client) {
          client.findProxy = (uri) {
            return 'PROXY ${AppConfig.proxyAddress}:${AppConfig.proxyPort}';
          };
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
    }
    
    // 添加攔截器用於日誌記錄和錯誤處理
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 檢查網絡連接
        if (!await _checkConnectivity()) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: '沒有網絡連接',
              type: DioExceptionType.connectionError,
            ),
          );
        }
        
        // 添加額外的請求頭
        options.headers['User-Agent'] = 'Flutter/1.0';
        options.headers['Accept'] = 'application/json';
        
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        print('REQUEST HEADERS: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        print('ERROR DETAILS: ${e.message}');
        print('ERROR TYPE: ${e.type}');
        if (e.error is SocketException) {
          print('SOCKET ERROR: ${(e.error as SocketException).message}');
        }
        return handler.next(e);
      },
    ));
  }

  // 處理API錯誤
  String _handleApiError(dynamic error) {
    if (error is SocketException) {
      return '網絡連接錯誤: 請檢查您的網絡連接';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '連接超時: 伺服器響應時間過長';
        case DioExceptionType.sendTimeout:
          return '發送超時: 請檢查您的網絡連接';
        case DioExceptionType.receiveTimeout:
          return '接收超時: 請檢查您的網絡連接';
        case DioExceptionType.badResponse:
          return '伺服器錯誤: ${error.response?.statusCode} ${error.response?.statusMessage}';
        case DioExceptionType.cancel:
          return '請求已取消';
        default:
          return '網絡錯誤: ${error.message}';
      }
    }
    return '未知錯誤: $error';
  }
  
  // 帶重試功能的請求方法
  Future<Response> _requestWithRetry(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    int retryCount = 0,
  }) async {
    try {
      final options = Options(method: method);
      final response = await _dio.request(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
      return response;
    } catch (e) {
      if (retryCount < _maxRetries && _shouldRetry(e)) {
        print('Retry attempt ${retryCount + 1} for $path');
        // 延遲重試，每次重試增加延遲時間
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _requestWithRetry(
          path,
          method: method,
          queryParameters: queryParameters,
          data: data,
          retryCount: retryCount + 1,
        );
      }
      rethrow;
    }
  }
  
  // 判斷是否應該重試
  bool _shouldRetry(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          (error.error is SocketException);
    }
    return false;
  }

  // 獲取最新商品
  Future<List<Product>> getLatestProducts({int limit = 8}) async {
    // 如果強制使用模擬數據，直接返回模擬數據
    if (AppConfig.forceMockData == true) {
      print('使用強制模擬數據');
      return _getMockProducts();
    }
    
    try {
      final response = await _requestWithRetry(
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
      // 在開發階段或配置為使用模擬數據時，返回模擬數據
      if (AppConfig.useMockDataOnError || AppConfig.appUrl.contains('example.com')) {
        return _getMockProducts();
      }
      throw Exception(_handleApiError(e));
    }
  }

  // 獲取熱門商品
  Future<List<Product>> getPopularProducts({int limit = 8}) async {
    // 如果強制使用模擬數據，直接返回模擬數據
    if (AppConfig.forceMockData == true) {
      print('使用強制模擬數據');
      return _getMockProducts();
    }
    
    try {
      final response = await _requestWithRetry(
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
      // 在開發階段或配置為使用模擬數據時，返回模擬數據
      if (AppConfig.useMockDataOnError || AppConfig.appUrl.contains('example.com')) {
        return _getMockProducts();
      }
      throw Exception(_handleApiError(e));
    }
  }

  // 獲取首頁橫幅
  Future<List<HomeBanner>> getHomeBanners() async {
    // 如果強制使用模擬數據，直接返回模擬數據
    if (AppConfig.forceMockData == true) {
      print('使用強制模擬數據');
      return _getMockBanners();
    }
    
    try {
      final response = await _requestWithRetry(
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
      // 在開發階段或配置為使用模擬數據時，返回模擬數據
      if (AppConfig.useMockDataOnError || AppConfig.appUrl.contains('example.com')) {
        return _getMockBanners();
      }
      throw Exception(_handleApiError(e));
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

  // 檢查網絡連接
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return true; // 如果無法檢查，假設有連接
    }
  }
} 