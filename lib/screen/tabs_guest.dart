import 'package:chat_app/screen/guest_detail.dart';
import 'package:chat_app/screen/home_page.dart';
import 'package:flutter/material.dart';

class TabGuest extends StatefulWidget {
  const TabGuest({super.key});

  @override
  State<TabGuest> createState() {
    return _TabGuestState();
  }
}

class _TabGuestState extends State<TabGuest> {
  int selectedPageGuest = 0;
  final List<Widget> pagesGuest = [
    const HomePage(),
    const GuestDetail(),
  ];

  final List<String> pageTitles = [
    "Trang Chủ",
    "Tài Khoản",
  ];
  void onSelectedPageGues(int index) {
    setState(() {
      selectedPageGuest = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[selectedPageGuest]),
      ),
      body: pagesGuest[selectedPageGuest],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onSelectedPageGues,
        currentIndex: selectedPageGuest,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tôi',
          ),
        ],
        selectedItemColor: Colors.yellow,
      ),
    );
  }
}
