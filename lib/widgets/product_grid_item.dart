import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/vendor_product_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductGridItem extends StatelessWidget {
  const ProductGridItem({super.key});

  String formatPrice(int price) {
    final formatCurrency = NumberFormat("#,##0", "vi_VN");
    return '${formatCurrency.format(price)}₫';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore
          .collection('product')
          .orderBy('sort_timestamp', descending: true)
          .limit(4)
          .snapshots(),
      builder: (ctx, proSnapshot) {
        if (proSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!proSnapshot.hasData || proSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Hiện không có sản phẩm'),
          );
        }
        if (proSnapshot.hasError) {
          return const Center(
            child: Text('Đã có lỗi xảy ra'),
          );
        }
        final products = proSnapshot.data!.docs;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 2,
            ),
            itemBuilder: (ctx, index) {
              final product = products[index].data();
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) {
                        return VendorProductDetail(product: product);
                      },
                    ),
                  );
                },
                child: Card(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              color: Colors.grey,
                              child: product['image'] != null
                                  ? CachedNetworkImage(
                                      imageUrl: product['image'],
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      '${product['kilo'].toString()}g',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Text(formatPrice(product['price'])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
