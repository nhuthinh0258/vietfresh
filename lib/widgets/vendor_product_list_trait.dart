import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';

import 'package:chat_app/screen/vendor_product_detail.dart';
import 'package:chat_app/style.dart';
import 'package:chat_app/style2.dart';
import 'package:intl/intl.dart';

class ProductList extends StatelessWidget {
  const ProductList(
      {super.key,
      required this.products,
      required this.searchQuery,
      required this.addToCart});
  final List<Map<String, dynamic>> products;
  final String searchQuery;
  final void Function(Map<String, dynamic> product) addToCart;

  String formatPrice(int price) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    return '${formatCurrency.format(price)}₫';
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = searchQuery.isEmpty
        ? products
        : products.where((product) {
            return (product['name'].toString())
                .toLowerCase()
                .contains(searchQuery);
          }).toList();

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredProducts.length,
        itemBuilder: (ctx, index) {
          final product = filteredProducts[index];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return VendorProductDetail(product: product);
                  }));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          width: 100,
                          height: 100,
                          child: product['image'] != null
                              ? CachedNetworkImage(
                                  imageUrl: product['image'],
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
                              outputText: product['name'],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Style2(
                                outputText: '${product['kilo'].toString()}g'),
                            const SizedBox(
                              height: 5,
                            ),
                            Style2(
                              outputText: formatPrice(product['price']),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (firebase.currentUser == null) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const AuthScreen();
                              }));
                            } else {
                              addToCart(product);
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
                height: 16,
              ),
            ],
          );
        });
  }
}
