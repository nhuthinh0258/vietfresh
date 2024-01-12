import 'package:chat_app/provider/bottom_navigation_provider.dart';
import 'package:chat_app/screen/chat.dart';
import 'package:chat_app/screen/customer_detail.dart';
import 'package:chat_app/screen/favorite.dart';
import 'package:chat_app/screen/home_page.dart';
import 'package:chat_app/screen/order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final firebase = FirebaseAuth.instance;

class TabsCustomer extends ConsumerStatefulWidget {
  const TabsCustomer({super.key});
  @override
  ConsumerState<TabsCustomer> createState() {
    return _TabsCustomerState();
  }
}

class _TabsCustomerState extends ConsumerState<TabsCustomer>{
  int selectedPageIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const Order(),
    const Favorite(),
    const ChatScreen(),
    const CustomerDetail(),
  ];


  void selectedPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = ref.watch(bottomNavigationProvider);
    return Scaffold(
      body: pages[selectedPageIndex],
      bottomNavigationBar: selectedPageIndex == 3
          ? isKeyboardVisible
              ? BottomNavigationBar(
                  onTap: selectedPage,
                  currentIndex: selectedPageIndex,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                        ),
                        label: 'Trang chủ'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.receipt,
                        ),
                        label: 'Đơn hàng'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.favorite,
                        ),
                        label: 'Yêu Thích'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.people,
                        ),
                        label: 'Cộng đồng'),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person,
                        ),
                        label: 'Tôi'),
                  ],
                  // selectedItemColor: Colors.yellow,
                )
              : null
          : BottomNavigationBar(
              onTap: selectedPage,
              currentIndex: selectedPageIndex,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                    ),
                    label: 'Trang chủ'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.receipt,
                    ),
                    label: 'Đơn hàng'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite,
                    ),
                    label: 'Yêu Thích'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.people,
                    ),
                    label: 'Cộng đồng'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                    ),
                    label: 'Tôi'),
              ],
              // selectedItemColor: Colors.yellow,
            ),
    );
  }
}
