import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/hot_product.dart';
import 'package:chat_app/widgets/carousel_banner.dart';
import 'package:chat_app/widgets/category_grid_item.dart';
import 'package:chat_app/widgets/list_product_home.dart';
import 'package:chat_app/widgets/product_grid_item.dart';
import 'package:flutter/material.dart';

import '../widgets/cart_icon.dart';
import 'newest_product.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser;
    return Scaffold(
      appBar: user == null
          ? null
          : AppBar(
              title: const Text('Trang chủ'),
              centerTitle: true,
              actions: const [
                CartIconWithBadge(),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Slide Banner
            const SizedBox(
              height: 8,
            ),
            const CarouselBanner(),
            const SizedBox(
              height: 8,
            ),
            // 2. Categories Selection
            const CategoryGridItem(),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sản phẩm mới',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (ctx) {
                            return const NewestProduct();
                          });
                    },
                    child: const Text(
                      'Xem thêm >',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const ProductGridItem(),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hot',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (ctx) {
                            return const HotProduct();
                          });
                    },
                    child: const Text(
                      'Xem thêm >',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            // 3. List of All Products
            const ListProductHome(),
          ],
        ),
      ),
    );
  }
}
