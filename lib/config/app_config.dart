class AppConfig {
  // API配置
  // 使用IP地址而不是域名可能會解決DNS解析問題
  // 您需要找到ismartdemo.com.tw對應的IP地址
  // 可以使用ping命令或在瀏覽器中查詢
  static const String appUrl = 'http://ismartdemo.com.tw/index.php?route=extension/module/api'; // 使用http而不是https
  // 或者嘗試使用IP地址: static const String appUrl = 'http://123.456.789.10/index.php?route=extension/module/api';
  static const String apiKey = 'CNQ4eX5WcbgFQVkBXFKmP9AE2AYUpU2HySz2wFhwCZ3qExG6Tep7ZCSZygwzYfsF';
  
  // API端點
  static const String latestProductsEndpoint = '/gws_appproducts_popular';
  static const String popularProductsEndpoint = '/gws_appproducts_popular';
  static const String homeBannerEndpoint = '/gws_appservice/allHomeBanner';
  
  // 是否使用模擬數據（當網絡連接失敗時）
  static const bool useMockDataOnError = true;
} 