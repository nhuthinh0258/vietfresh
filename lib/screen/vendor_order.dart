import 'package:chat_app/screen/vendor_order_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../style.dart';
import '../style2.dart';
import 'auth.dart';

class OrderVendor extends StatefulWidget {
  const OrderVendor({super.key});

  @override
  State<OrderVendor> createState() {
    return _OrderVendoState();
  }
}

class _OrderVendoState extends State<OrderVendor>
    with TickerProviderStateMixin {
  Future getStatusList() async {
    // Lấy danh sách trạng thái từ Firestore
    final statusCollection = await firestore.collection('status').get();

    return statusCollection.docs.map((doc) {
      return doc.data();
    }).toList();
  }

  void onDeleteReceipt(String receipt) async {
    await firestore.collection('order').doc(receipt).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đơn hàng đã được xóa'),
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

  // Hàm chuyển đổi mã màu hex thành đối tượng Color
  Color hexColor(String hexColorString) {
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = 'FF$hexColorString'; // Thêm FF cho độ trong suốt
    }
    return Color(int.parse(hexColorString, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser;
    return FutureBuilder(
      future: getStatusList(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List statusList = snapshot.data!;
        final tabController =
            TabController(vsync: this, length: statusList.length);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Đơn Hàng'),
            centerTitle: true,
            bottom: TabBar(
                labelColor: Colors.yellow,
                unselectedLabelColor: Colors.white,
                controller: tabController,
                tabs: statusList.map((status) {
                  return Tab(
                    text: status['status_code'],
                  );
                }).toList()),
          ),
          body: TabBarView(
            controller: tabController,
            children: statusList.map((status) {
              return StreamBuilder(
                stream: firestore
                    .collection('order')
                    .where('status', isEqualTo: status['status_id'])
                    .where('vendor_id', isEqualTo: user!.uid)
                    .orderBy('order_at', descending: true)
                    .snapshots(),
                builder: (ctx, orderSnapshot) {
                  if (orderSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!orderSnapshot.hasData ||
                      orderSnapshot.data!.docs.isEmpty) {
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
                            'Hiện không có đơn hàng nào',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.75)),
                          )
                        ],
                      ),
                    );
                  }
                  final orders = orderSnapshot.data!.docs;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (ctx, index) {
                      final order = orders[index].data();
                      bool isConfirm = order['status'] == 'status-1';
                      Timestamp timestamp = order['order_at'];
                      DateTime dateTime =
                          timestamp.toDate(); // Chuyển Timestamp thành DateTime

                      // Định dạng DateTime thành chuỗi ngày giờ theo ý muốn
                      String formattedDate =
                          DateFormat('dd-MM-yyyy - kk:mm').format(dateTime);
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                            return VendorOrderDetail(order: order, orders: orders[index].id);
                          }));
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          color: Theme.of(context).primaryColorLight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/images/recipe.png'),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Style(outputText: orders[index].id),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Expanded(
                                        child: Style2(
                                          outputText: formattedDate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  FutureBuilder(
                                    future: firestore
                                        .collection('status')
                                        .where('status_id',
                                            isEqualTo: order['status'])
                                        .get(),
                                    builder: (ctx, statusSnashot) {
                                      if (statusSnashot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Style2(
                                            outputText: 'Đang xử lý:...');
                                      }
                                      final statusData =
                                          statusSnashot.data!.docs;
                                      final status = statusData.first.data();
                                      final color = hexColor(status['color']);
                                      return Row(
                                        children: [
                                          Container(
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(
                                                            0.2), // Màu bóng đổ
                                                    spreadRadius:
                                                        1, // Phạm vi bóng đổ
                                                    blurRadius:
                                                        5, // Độ mờ của bóng đổ
                                                    offset: const Offset(0,
                                                        3), // Vị trí của bóng đổ
                                                  ),
                                                ]),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Style2(
                                              outputText:
                                                  status['status_code']),
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                              trailing: isConfirm
                                  ? IconButton(
                                      onPressed: () {
                                        onDeleteReceipt(orders[index].id);
                                      },
                                      icon: const Icon(Icons.delete))
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
