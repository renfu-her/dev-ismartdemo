class AppConfig {
  // API配置
  // 使用IP地址而不是域名可能會解決DNS解析問題
  // 您需要找到ismartdemo.com.tw對應的IP地址
  // 可以使用ping命令或在瀏覽器中查詢
  
  // 嘗試以下幾種URL配置，取消註釋您想要使用的一個：
  
  // 1. 原始域名（HTTP）
  static const String appUrl = 'http://ismartdemo.com.tw/index.php?route=extension/module/api';
  
  // 2. 使用IP地址（如果您知道服務器IP）
  // static const String appUrl = 'http://123.456.789.10/index.php?route=extension/module/api';
  
  // 3. 使用10.0.2.2（Android模擬器中指向主機的特殊IP）
  // static const String appUrl = 'http://10.0.2.2/index.php?route=extension/module/api';
  
  // 4. 使用本地測試服務器
  // static const String appUrl = 'http://localhost:8000/index.php?route=extension/module/api';
  
  static const String apiKey = 'CNQ4eX5WcbgFQVkBXFKmP9AE2AYUpU2HySz2wFhwCZ3qExG6Tep7ZCSZygwzYfsF';
  
  // 代理設置（用於雷電模擬器）
  // 如果需要使用代理，將useProxy設置為true，並設置代理地址和端口
  static const bool useProxy = false;
  static const String proxyAddress = '10.0.2.2'; // 通常是主機的地址
  static const int proxyPort = 8888;
  
  // API端點
  static const String latestProductsEndpoint = '/gws_appproducts_popular';
  static const String popularProductsEndpoint = '/gws_appproducts_popular';
  static const String homeBannerEndpoint = '/gws_appservice/allHomeBanner';
  
  // 是否使用模擬數據（當網絡連接失敗時）
  static const bool useMockDataOnError = true;
  
  // 強制使用模擬數據（無論網絡連接是否成功）
  // 在開發階段或網絡問題無法解決時使用
  static const bool forceMockData = true;
} 