import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkDebug {
  // 檢查網絡連接
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }
  
  // 檢查DNS解析
  static Future<String> checkDnsResolution(String host) async {
    try {
      final List<InternetAddress> addresses = await InternetAddress.lookup(host);
      if (addresses.isNotEmpty) {
        return '成功解析 $host 到 ${addresses.map((a) => a.address).join(', ')}';
      } else {
        return '無法解析 $host';
      }
    } on SocketException catch (e) {
      return '解析 $host 時出錯: ${e.message}';
    } catch (e) {
      return '解析 $host 時出現未知錯誤: $e';
    }
  }
  
  // 檢查端口連接
  static Future<String> checkPortConnection(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      socket.destroy();
      return '成功連接到 $host:$port';
    } on SocketException catch (e) {
      return '連接到 $host:$port 時出錯: ${e.message}';
    } catch (e) {
      return '連接到 $host:$port 時出現未知錯誤: $e';
    }
  }
  
  // 顯示網絡診斷對話框
  static Future<void> showNetworkDiagnosticDialog(BuildContext context, String apiHost) async {
    final isConnectedResult = await isConnected();
    final dnsResult = await checkDnsResolution(apiHost);
    final portResult = await checkPortConnection(apiHost, 80);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('網絡診斷'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('網絡連接: ${isConnectedResult ? '已連接' : '未連接'}'),
              const SizedBox(height: 8),
              Text('DNS解析: $dnsResult'),
              const SizedBox(height: 8),
              Text('端口連接: $portResult'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
} 