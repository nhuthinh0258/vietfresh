import 'package:flutter/material.dart';

import '../screen/auth.dart';
import '../screen/cart.dart';

class CartIconWithBadge extends StatelessWidget {
  const CartIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser!;
    return StreamBuilder(
        stream: firestore.collection('cart').doc(user.uid).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData) {
            final cartData = snapshot.data?.data();
            if (cartData != null) {
              List cartItems = cartData['products'];
              int itemCount = cartItems.length;
              return SizedBox(
                width: 40,
                height: 40,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                      return const Cart();
                    }));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        child: Icon(Icons.shopping_cart),
                      ), // Biểu tượng giỏ hàng
                      if (itemCount >
                          0) // Chỉ hiển thị badge nếu có ít nhất một sản phẩm
                        Positioned(
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
          }
          return IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return const Cart();
              }));
            },
          );
        });
  }
}
