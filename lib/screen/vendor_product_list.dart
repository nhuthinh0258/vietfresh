import 'package:chat_app/screen/auth.dart';

import 'package:chat_app/style.dart';

import 'package:chat_app/widgets/cart_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/vendor_product_list_trait.dart';

class VendorProductList extends StatefulWidget {
  const VendorProductList(
      {super.key,
      required this.vendor,
      required this.imageProvider,
      required this.category});
  final Map<String, dynamic> vendor;
  final ImageProvider<Object> imageProvider;
  final Map<String, dynamic> category;

  @override
  State<VendorProductList> createState() {
    return _VendorProductList();
  }
}

class _VendorProductList extends State<VendorProductList> {
  String searchQuery = '';
  late Query<Map<String, dynamic>> streamProduct;
  var isFilter = false;

  @override
  void initState() {
    super.initState();
    streamProduct = firestore
        .collection('product')
        .where('vendor_id', isEqualTo: widget.vendor['user_id'])
        .where('category', isEqualTo: widget.category['category_id']);
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  String formatPrice(int price) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    return '${formatCurrency.format(price)}₫';
  }

void addToCart(Map<String, dynamic> product) async {
    final user = firebase.currentUser!;
    // Lấy thông tin giỏ hàng hiện tại
    final cartSnapshot = await firestore.collection('cart').doc(user.uid).get();

    //Tạo Danh Sách Sản Phẩm:
    List<dynamic> products = [];

    // Kiểm tra giỏ hàng có tồn tại không và khởi tạo 'products' nếu cần
    if (cartSnapshot.exists && cartSnapshot.data()!['products'] != null) {
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
      var productExists = false;
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.vendor['vendor_name']),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8), // Điều chỉnh padding nếu cần
                decoration: BoxDecoration(
                  color: Colors.white, // Đặt màu nền cho TextField
                  borderRadius:
                      BorderRadius.circular(20), // Làm tròn góc nếu muốn
                ),
                child: TextFormField(
                  onChanged: updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: "Tìm kiếm sản phẩm...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Colors
                            .grey), // Điều chỉnh màu sắc hint text nếu cần
                  ),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14), // Điều chỉnh màu sắc text
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (user != null) const CartIconWithBadge(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration:
                  BoxDecoration(color: Theme.of(context).primaryColorLight),
              width: double.infinity,
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: Image(
                      image: widget.imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Style(
                              outputText: widget.vendor['vendor_location'],
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (!isFilter) {
                                streamProduct = firestore
                                    .collection('product')
                                    .where('vendor_id',
                                        isEqualTo: widget.vendor['user_id']);
                              } else {
                                streamProduct = firestore
                                    .collection('product')
                                    .where('vendor_id',
                                        isEqualTo: widget.vendor['user_id'])
                                    .where('category',
                                        isEqualTo:
                                            widget.category['category_id']);
                              }
                              isFilter = !isFilter;
                            });
                          },
                          child: Icon(isFilter
                              ? Icons.filter_alt
                              : Icons.filter_alt_off),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Style(
                              outputText:
                                  widget.vendor['vendor_phone'].toString(),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            StreamBuilder(
              stream: streamProduct.snapshots(),
              builder: (ctx, proSnapshot) {
                if (proSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final productList = proSnapshot.data!.docs.map((doc) {
                  return doc.data();
                }).toList();

                return ProductList(
                    products: productList,
                    searchQuery: searchQuery,
                    addToCart: addToCart);
              },
            ),
          ],
        ),
      ),
    );
  }
}
