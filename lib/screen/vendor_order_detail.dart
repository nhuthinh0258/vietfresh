import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../style.dart';
import '../style2.dart';

class VendorOrderDetail extends StatefulWidget {
  const VendorOrderDetail(
      {super.key, required this.order, required this.orders});
  final String orders;
  final Map<String, dynamic> order;

  @override
  State<StatefulWidget> createState() {
    return _VendorOrderDetailState();
  }
}

class _VendorOrderDetailState extends State<VendorOrderDetail> {
  var selectedStatus = 'status-1';
  var isUpdating = false;
  //Điều chỉnh isEnabled dựa trên trạng thái hiện tại và trạng thái của item
  var isEnabled = true;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order['status'];
  }

  // Hàm chuyển đổi mã màu hex thành đối tượng Color
  Color hexColor(String hexColorString) {
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = 'FF$hexColorString'; // Thêm FF cho độ trong suốt
    }
    return Color(int.parse(hexColorString, radix: 16));
  }

  //Nút cập nhật đơn hàng
  void updateOrder() async {
    setState(() {
      isUpdating = true;
    });

    final orderId = widget.orders;
    await firestore.collection('order').doc(orderId).update({
      'status': selectedStatus,
    });

    // Kiểm tra nếu trạng thái là "Thành công"
    if (selectedStatus == 'status-3') {
      // Duyệt qua từng sản phẩm trong đơn hàng
      for (final orderItem in widget.order['orderItems']) {
        // Lấy thông tin sản phẩm hiện tại từ Firestore
        final productRef = await firestore
            .collection('product')
            .doc(orderItem['product_id'])
            .get();
        if (productRef.exists) {
          final productData = productRef.data();
          final currentQuantityBuy =
              productData!['quantity_buy'] ?? 0; // Lấy số lượng đã bán hiện tại
          final newQuantityBuy = currentQuantityBuy +
              orderItem['quantity_buy']; // Cập nhật số lượng đã bán mới

          final currentQuantity =
              productData['quantity'] ?? 0; // Lấy số lượng đã bán hiện tại
          final newQuantity = currentQuantity -
              orderItem['quantity_buy']; // Cập nhật số lượng đã bán mới

          // Cập nhật số lượng đã bán của sản phẩm trong Firestore
          await firestore
              .collection('product')
              .doc(orderItem['product_id'])
              .update(
                  {'quantity_buy': newQuantityBuy, 'quantity': newQuantity});
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cập nhật đơn hàng thành công'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
            label: 'Đồng ý',
            onPressed: () {
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(context).clearSnackBars();
            }),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = widget.order['order_at'];
    // Chuyển Timestamp thành DateTime
    DateTime dateTime = timestamp.toDate();
    // Định dạng DateTime thành chuỗi ngày giờ theo ý muốn
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    final orderItems =
        List<Map<String, dynamic>>.from(widget.order['orderItems']);
    //Biến trạng thái kiểm tra status đơn hàng
    var hidenShowUpdateButton = widget.order['status'] != 'status-3' &&
        widget.order['status'] != 'status-4';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orders),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Style(
                        outputText: 'Họ tên: ${widget.order['order_name']}')),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: FutureBuilder(
                      future: firestore.collection('status').get(),
                      builder: (ctx, staSnapshot) {
                        if (staSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final statusOrders =
                            staSnapshot.data!.docs.map((status) {
                          final color = hexColor(status['color']);
                          // Nếu trạng thái hiện tại là "Xác nhận"
                          if (widget.order['status'] == 'status-1') {
                            // Kích hoạt "Xác nhân" và "Đang giao"
                            isEnabled = status.id == 'status-1' ||
                                status.id == 'status-2';
                          }
                          // Nếu trạng thái hiện tại là "Đang giao"
                          else if (widget.order['status'] == 'status-2') {
                            // Kích hoạt "Đang giao" , "Thành công" và "Hoàn trả"
                            isEnabled = status.id == 'status-2' ||
                                status.id == 'status-3' ||
                                status.id == 'status-4';
                          }
                          // Nếu trạng thái hiện tại là "Thành công"
                          else if (widget.order['status'] == 'status-3') {
                            // Kích hoạt "Thành công"
                            isEnabled = status.id == 'status-3';
                          }
                          // Nếu trạng thái hiện tại là "Hoàn trả"
                          else if (widget.order['status'] == 'status-4') {
                            // Nếu trạng thái hiện tại là "Đang giao"
                            isEnabled = status.id == 'status-4';
                          }
                          return DropdownMenuItem(
                            value: status.id,
                            enabled: isEnabled,
                            child: Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: isEnabled ? color : Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.2), // Màu bóng đổ
                                          spreadRadius: 1, // Phạm vi bóng đổ
                                          blurRadius: 5, // Độ mờ của bóng đổ
                                          offset: const Offset(
                                              0, 3), // Vị trí của bóng đổ
                                        ),
                                      ]),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  status['status_code'],
                                  style: TextStyle(
                                      color: isEnabled
                                          ? Colors.black
                                          : Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                        return DropdownButtonFormField(
                          value: selectedStatus,
                          dropdownColor: Colors.white,
                          items: statusOrders,
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        );
                      }),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Địa chỉ: ${widget.order['order_address']}'),
            const SizedBox(
              height: 10,
            ),
            Style2(
                outputText:
                    'Thành phố: ${widget.order['order_location'] ?? 'null'}'),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Số điện thoại: ${widget.order['order_phone']}'),
            const SizedBox(
              height: 10,
            ),
            Style2(outputText: 'Ngày đặt: $formattedDate'),
            const SizedBox(
              height: 10,
            ),
            Style2(
                outputText:
                    'Phương thức thanh toán: ${widget.order['payment_method']}'),
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
                Style(outputText: widget.order['totalAmount']),
              ],
            ),
            hidenShowUpdateButton
                ? const SizedBox(
                    height: 50,
                  )
                : const SizedBox(
                    height: 100,
                  ),
            if (hidenShowUpdateButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: updateOrder,
                    style: ButtonStyle(
                      //Thay đổi màu nền của button theo màu theme đã khai báo
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColorLight,
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const Style(
                            outputText: 'Cập nhật đơn hàng',
                          ),
                  ),
                ],
              ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
