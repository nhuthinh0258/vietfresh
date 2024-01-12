import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/oder_infomation.dart';
import 'package:chat_app/style.dart';
import 'package:chat_app/style2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() {
    return _CartState();
  }
}

class _CartState extends State<Cart> {
  var totalAmount = 0;
  var productUpdated = false;

  String formatPrice(int price) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    return '${formatCurrency.format(price)}₫';
  }

  void updateProductQuantity(String productId, int change) async {
    final user = firebase.currentUser!;
    // Lấy thông tin giỏ hàng hiện tại
    final cartSnapshot = await firestore.collection('cart').doc(user.uid).get();
    if (cartSnapshot.exists && cartSnapshot.data()?['products'] != null) {
      final products = List.from(cartSnapshot.data()!['products']);

      for (var i = 0; i < products.length; i++) {
        if (products[i]['product_id'] == productId) {
          int newQuantity = products[i]['quantity_buy'] + change;
          if (newQuantity > 0) {
            products[i]['quantity_buy'] = newQuantity;
          } else {
            products.removeAt(i); // Xóa sản phẩm nếu số lượng về 0
            if (!mounted) return;
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đã xóa sản phẩm khỏi giỏ'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                    label: 'Đồng ý',
                    onPressed: () {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).clearSnackBars();
                    }),
              ),
            );
          }
          productUpdated = true;
          break;
        }
      }

      // Cập nhật lại toàn bộ mảng sản phẩm trong giỏ hàng
      await firestore.collection('cart').doc(user.uid).set({'products': products});
    }
  }

// Sử dụng hàm này cho nút tăng số lượng
  increaseQuantity(String productId, int currentQuantity) {
    updateProductQuantity(productId, 1);
  }

// Sử dụng hàm này cho nút giảm số lượng
  decreaseQuantity(String productId, int currentQuantity) {
    updateProductQuantity(productId, -1);
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: StreamBuilder(
          stream: firestore.collection('cart').doc(user.uid).snapshots(),
          builder: (ctx, cartSnapshot) {
            if (cartSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!cartSnapshot.hasData ||
                cartSnapshot.data!.data() == null ||
                cartSnapshot.data!.data()?['products'] == null ||
                (cartSnapshot.data!.data()?['products'] as List).isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/cactus.png',
                        width: 100,
                        height: 100,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.75)),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Hiện không có sản phẩm nào, hãy thêm sản phẩm!',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(0.75)),
                    )
                  ],
                ),
              );
            }
            final cartData = cartSnapshot.data!.data();
            final cartItems = cartData!['products'] as List;

            // Tính tổng tiền
            int totalAmount = 0;
            for (final item in cartItems) {
              int quantity =
                  item['quantity_buy'].toInt(); // Chuyển đổi sang int
              int price = item['price'].toInt(); // Chuyển đổi sang int
              totalAmount += quantity * price;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, index) {
                      final cartItem = cartItems[index];
                      return Column(
                        children: [
                          const SizedBox(
                            height: 12,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                    width: 100,
                                    height: 100,
                                    child: cartItem['image'] != null
                                        ? CachedNetworkImage(
                                            imageUrl: cartItem['image'],
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(
                                  width: 50,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Style(
                                        outputText: cartItem['name'],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Style2(
                                          outputText:
                                              '${cartItem['kilo'].toString()}g'),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Style2(
                                        outputText:
                                            formatPrice(cartItem['price']),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red, // Màu nền nhẹ màu đỏ
                                          borderRadius: BorderRadius.circular(
                                              8), // Làm tròn góc
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            decreaseQuantity(
                                                cartItem['product_id'],
                                                cartItem['quantity_buy']);
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                          ),
                                        ),
                                      ),
                                      Style(
                                          outputText: cartItem['quantity_buy']
                                              .toString()),
                                      Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red, // Màu nền nhẹ màu đỏ
                                          borderRadius: BorderRadius.circular(
                                              8), // Làm tròn góc
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            increaseQuantity(
                                                cartItem['product_id'],
                                                cartItem['quantity_buy']);
                                          },
                                          child: const Icon(
                                            Icons.add,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                BottomAppBar(
                  color: Colors.white,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng: ${formatPrice(totalAmount)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (ctx) {
                              return OrderInfor(
                                totalAmount: formatPrice(totalAmount),
                                cartItems: cartItems,
                              );
                            }));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Background color
                          ),
                          child: const Text(
                            'Đặt hàng',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
