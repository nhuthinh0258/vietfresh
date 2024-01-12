import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/vendor_product_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../style.dart';
import '../style2.dart';
import '../widgets/cart_icon.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  String formatPrice(int price) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    return '${formatCurrency.format(price)}₫';
  }

  void addToCart(Map<String, dynamic> product, BuildContext context) async {
    final user = firebase.currentUser!;
    // Lấy thông tin giỏ hàng hiện tại
    final cartSnapshot = await firestore.collection('cart').doc(user.uid).get();

    //Tạo Danh Sách Sản Phẩm:
    List<dynamic> products = [];

    // Kiểm tra giỏ hàng có tồn tại không và khởi tạo 'products' nếu cần
    if (cartSnapshot.exists && cartSnapshot.data()?['products'] != null) {
      products = List.from(cartSnapshot.data()!['products']);
    }

    // Kiểm tra xem có sản phẩm nào từ nhà cung cấp khác không
    bool differentVendorExists = products.any((pro) {
      return pro['vendor_id'] != product['vendor_id'];
    });

    // Nếu có sản phẩm từ nhà cung cấp khác
    if (differentVendorExists) {
      if (!context.mounted) return;
      // Hiển thị thông báo xác nhận
      final shouldReplace = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Thay đổi nhà cung cấp"),
              content: const Text(
                  "Giỏ hàng hiện tại chứa sản phẩm từ nhà cung cấp khác. Bạn có muốn xóa và thêm sản phẩm mới không?"),
              actions: [
                TextButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                  child: const Text("Không"),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sản phẩm đã được thêm vào giỏ'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                            label: 'Đồng ý',
                            onPressed: () {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).clearSnackBars();
                            }),
                      ),
                    );
                    return Navigator.of(context).pop(true);
                  },
                  child: const Text("Có"),
                ),
              ],
            );
          });

      // Nếu người dùng chọn thay thế sản phẩm
      if (shouldReplace ?? false) {
        products.clear(); // Xóa tất cả sản phẩm hiện có
        final newProduct = Map<String, dynamic>.from(product);
        newProduct.remove('created_at'); // Xóa trường 'create'
        newProduct.remove('update_at'); // Xóa trường 'update'
        newProduct.remove('sort_timestamp'); // Xóa trường 'sort_timestamp'
        newProduct.remove('note'); // Xóa trường 'note'
        newProduct.remove('quantity'); // Xóa trường 'quantity'
        newProduct['quantity_buy'] = 1; // Khởi tạo quantity_buy là 1
        products.add(newProduct);
        // Xóa tất cả sản phẩm và thêm sản phẩm mới
        await firestore.collection('cart').doc(user.uid).update({
          'products': products,
        });
        return;
      }
    } else {
      bool productExists = false;
      //Duyệt Qua Danh Sách Sản Phẩm, cập nhật số lượng mua + 1 nếu sản phẩm đã có trong cart
      for (final pro in products) {
        if (pro['product_id'] == product['product_id']) {
          pro['quantity_buy'] = (pro['quantity_buy'] ?? 0) + 1;
          productExists = true;
          break;
        }
      }
      //Thêm Sản Phẩm Mới Nếu Nó Chưa Tồn Tại
      if (!productExists) {
        final newProduct = Map<String, dynamic>.from(product);
        newProduct.remove('created_at'); // Xóa trường 'create'
        newProduct.remove('update_at'); // Xóa trường 'update'
        newProduct.remove('sort_timestamp'); // Xóa trường 'sort_timestamp'
        newProduct.remove('note'); // Xóa trường 'note'
        newProduct.remove('quantity'); // Xóa trường 'quantity'
        newProduct['quantity_buy'] = 1; // Khởi tạo quantity_buy là 1
        products.add(newProduct);
      }
      //Cập Nhật Firestore:
      await firestore.collection('cart').doc(user.uid).set({
        'products': products,
      });
      // Hiển thị thông báo
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sản phẩm đã được thêm vào giỏ'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
              label: 'Đồng ý',
              onPressed: () {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).clearSnackBars();
              }),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        centerTitle: true,
        actions: [
          if (user != null) const CartIconWithBadge(),
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('favorite').doc(user!.uid).snapshots(),
        builder: (ctx, favoriteSnap) {
          if (favoriteSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!favoriteSnap.hasData ||
              favoriteSnap.data!.data() == null ||
              favoriteSnap.data!.data()?['products'] == null ||
              (favoriteSnap.data!.data()!['products'] as List).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/cactus.png',
                      width: 100,
                      height: 100,
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.75)),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Hiện không có sản phẩm nào',
                    style: TextStyle(
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.75)),
                  )
                ],
              ),
            );
          }
          final favoriteData = favoriteSnap.data!.data();
          final favoriteProducts = favoriteData!['products'] as List;
          return ListView.builder(
              itemCount: favoriteProducts.length,
              itemBuilder: (ctx, index) {
                final favoriteProduct = favoriteProducts[index];
                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return VendorProductDetail(product: favoriteProduct);
                        }));
                      },
                      child: Container(
                        margin:const EdgeInsets.symmetric(horizontal: 5),
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
                                child: favoriteProduct['image'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: favoriteProduct['image'],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Style(
                                    outputText: favoriteProduct['name'],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Style2(
                                      outputText:
                                          '${favoriteProduct['kilo'].toString()}g'),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Style2(
                                    outputText:
                                        formatPrice(favoriteProduct['price']),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red, // Màu nền nhẹ màu đỏ
                                borderRadius:
                                    BorderRadius.circular(8), // Làm tròn góc
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (firebase.currentUser == null) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const AuthScreen();
                                    }));
                                  } else {
                                    addToCart(favoriteProduct, context);
                                  }
                                },
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}
