import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首頁',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: '商品分類',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '搜尋',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '購物車',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '會員中心',
        ),
      ],
    );
  }
} 