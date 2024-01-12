import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/style.dart';
import 'package:chat_app/style2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetail extends StatelessWidget {
  const OrderDetail({super.key, required this.order, required this.orders});
  final String orders;
  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = order['order_at'];
    DateTime dateTime = timestamp.toDate(); // Chuyển Timestamp thành DateTime

    // Định dạng DateTime thành chuỗi ngày giờ theo ý muốn
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    final orderItems = List<Map<String, dynamic>>.from(order['orderItems']);

    return Scaffold(
      appBar: AppBar(
        title: Text(orders),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Style(outputText: 'Họ tên: ${order['order_name']}'),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Địa chỉ: ${order['order_address']}'),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Thành phố: ${order['order_location'] ?? 'null'}'),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Số điện thoại: ${order['order_phone']}'),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Ngày đặt: $formattedDate'),
            const SizedBox(
              height: 10,
            ),
            Style2(
                outputText:
                    'Phương thức thanh toán: ${order['payment_method']}'),
            const SizedBox(
              height: 20,
            ),
            const Style(outputText: 'Danh sách sản phẩm'),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Style(
                  outputText: 'STT',
                ),
                SizedBox(width: 50), // Điều chỉnh khoảng cách nếu cần
                Style(
                  outputText: 'Ảnh',
                ),
                SizedBox(width: 70), // Điều chỉnh khoảng cách nếu cần
                Expanded(
                  child: Style(
                    outputText: 'Sản phẩm',
                  ),
                ),
                Style(
                  outputText: 'Số lượng',
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                child: ListView.builder(
                    itemCount: orderItems.length,
                    itemBuilder: (ctx, index) {
                      final orderItem = orderItems[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Style(outputText: [index + 1].toString()),
                            const SizedBox(
                              width: 20,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                                width: 100,
                                height: 100,
                                child: CachedNetworkImage(
                                  imageUrl: orderItem['image'],
                                  fit: BoxFit.cover,
                                ),
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
                                    outputText: orderItem['name'],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Style2(
                                      outputText:
                                          '${orderItem['kilo'].toString()}g'),
                                ],
                              ),
                            ),
                            Style(
                                outputText:
                                    orderItem['quantity_buy'].toString()),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Style(outputText: 'Tổng Tiền'),
                Style(outputText: order['totalAmount']),
              ],
            ),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
