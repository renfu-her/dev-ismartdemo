import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/banner.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _latestProducts = [];
  List<Product> _popularProducts = [];
  List<HomeBanner> _banners = [];
  bool _isLoadingProducts = true;
  bool _isLoadingBanners = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadBanners();
    _loadProducts();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoadingBanners = true;
      _errorMessage = '';
    });

    try {
      final banners = await _apiService.getHomeBanners();
      setState(() {
        _banners = banners;
        _isLoadingBanners = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBanners = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      print('Error loading banners: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _errorMessage = '';
    });

    try {
      // 並行加載最新和熱門產品
      final latestFuture = _apiService.getLatestProducts();
      final popularFuture = _apiService.getPopularProducts();
      
      final results = await Future.wait([latestFuture, popularFuture]);
      
      setState(() {
        _latestProducts = results[0];
        _popularProducts = results[1];
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      print('Error loading products: $e');
    }
  }

  void _toggleFavorite(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.network(
              'https://via.placeholder.com/40x40/FFA500/FFFFFF?text=iS',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'iSMART',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '內部測試專用站',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('重試'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 廣告橫幅
                    _isLoadingBanners
                        ? Container(
                            margin: const EdgeInsets.all(16),
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: BannerCarousel(
                              banners: _banners,
                              height: 180,
                              onBannerTap: (link) {
                                // 處理橫幅點擊事件，例如打開鏈接
                                print('Banner clicked: $link');
                              },
                            ),
                          ),
                    
                    // 最新商品標題
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '最新商品',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // 最新商品列表
                    _isLoadingProducts
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _latestProducts.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('沒有最新商品'),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                                itemCount: _latestProducts.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                    product: _latestProducts[index],
                                    onFavoriteToggle: () => _toggleFavorite(_latestProducts[index]),
                                    onAddToCart: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('已添加 ${_latestProducts[index].name} 到購物車'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                    
                    // 熱門商品標題
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '熱門商品',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // 熱門商品列表
                    _isLoadingProducts
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _popularProducts.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('沒有熱門商品'),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                                itemCount: _popularProducts.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                    product: _popularProducts[index],
                                    onFavoriteToggle: () => _toggleFavorite(_popularProducts[index]),
                                    onAddToCart: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('已添加 ${_popularProducts[index].name} 到購物車'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
    );
  }
} 