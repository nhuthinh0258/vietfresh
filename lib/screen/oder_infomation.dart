import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/billing_success.dart';
import 'package:chat_app/style.dart';
import 'package:chat_app/style2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

enum PaymentMethod { cashOnDelivery }

class OrderInfor extends StatefulWidget {
  const OrderInfor(
      {super.key, required this.totalAmount, required this.cartItems});
  final List<dynamic> cartItems;
  final String totalAmount;
  @override
  State<OrderInfor> createState() {
    return _OrderInforState();
  }
}

class _OrderInforState extends State<OrderInfor> {
  final orderInforKeyForm = GlobalKey<FormState>();
  var enteredBillingName = '';
  var enteredBillingAdress = '';
  var enteredBillingPhone = 1;
  var selectedOriginId = 'origin-1703218547035';
  var onBillingStatus = 'status-1';
  var _method = PaymentMethod.cashOnDelivery;
  var isSending = false;
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final user = firebase.currentUser!;
    final userData = await firestore.collection('users').doc(user.uid).get();
    final userProfile = userData.data();
    setState(() {
      isLoading = false;
      enteredBillingName = userProfile?['user_name'] ?? enteredBillingName;
      enteredBillingAdress =
          userProfile?['user_address'] ?? enteredBillingAdress;
      enteredBillingPhone = userProfile?['user_phone'] ?? enteredBillingPhone;
      selectedOriginId = userProfile?['user_origin'] ?? selectedOriginId;
    });
  }

  String? validateBillingName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chưa nhập thông tin';
    } else if (value.trim().length < 4 && value.isNotEmpty) {
      return 'Tên người dùng không hợp lệ';
    }
    return null;
  }

  String? validateBillingAdress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chưa nhập thông tin';
    } else if (value.trim().length < 4 && value.isNotEmpty) {
      return 'Địa chỉ không hợp lệ';
    }
    return null;
  }

  String? validateBillingPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại trống';
    } else if (value.trim().length > 10 || value.trim().length < 10) {
      return 'số điện thoại không hợp lệ';
    }
    return null;
  }

  void submitBilling() async {
    if (orderInforKeyForm.currentState!.validate()) {
      orderInforKeyForm.currentState!.save();
      setState(() {
        isSending = true;
      });
      String paymentMethodValue = _method.toString().split('.').last;
      final user = firebase.currentUser!;
      final ordertId = 'order-${DateTime.now().millisecondsSinceEpoch}';
      // final cartItems = List<Map<String, dynamic>>.from(widget.cartItems);
      final vendorId = widget.cartItems.first['vendor_id'];
      final originData =
          await firestore.collection('orgin').doc(selectedOriginId).get();
      final originName = originData.data()!['name'];
      await firestore.collection('order').doc(ordertId).set({
        'user_id': user.uid,
        'vendor_id': vendorId,
        'order_name': enteredBillingName,
        'order_address': enteredBillingAdress,
        'order_phone': enteredBillingPhone,
        'order_origin': selectedOriginId,
        'order_location': originName,
        'orderItems': widget.cartItems,
        'totalAmount': widget.totalAmount,
        'payment_method': paymentMethodValue,
        'status': onBillingStatus,
        'order_at': Timestamp.now(),
      });
      await firestore.collection('cart').doc(user.uid).set({
        'products': [],
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) {
            return const BillingSuccess();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin thanh toán'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const CircularProgressIndicator()
                : Form(
                    key: orderInforKeyForm,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        TextFormField(
                          initialValue: enteredBillingName,
                          decoration: const InputDecoration(
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                            label: Text(
                              'Họ và Tên',
                              style: TextStyle(fontSize: 20),
                            ),
                            helperText: '',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          validator: validateBillingName,
                          onSaved: (value) {
                            enteredBillingName = value!;
                          },
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: enteredBillingAdress,
                                decoration: const InputDecoration(
                                  errorStyle: TextStyle(color: Colors.red),
                                  border: OutlineInputBorder(),
                                  label: Text(
                                    'Địa chỉ',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  helperText: '',
                                ),
                                keyboardType: TextInputType.streetAddress,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                validator: validateBillingAdress,
                                onSaved: (value) {
                                  enteredBillingAdress = value!;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Expanded(
                              flex: 1,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                    canvasColor: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                child: FutureBuilder(
                                    future: firestore.collection('orgin').get(),
                                    builder: (ctx, oriSnapshot) {
                                      if (!oriSnapshot.hasData ||
                                          oriSnapshot.data!.docs.isEmpty) {
                                        return const Center(
                                          child: Text('Không tìm thấy dữ liệu'),
                                        );
                                      }
                                      List<DropdownMenuItem<String>> orginList =
                                          oriSnapshot.data!.docs.map(
                                        (origin) {
                                          return DropdownMenuItem(
                                              value: origin.id,
                                              child: Text(
                                                origin['name'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ));
                                        },
                                      ).toList();

                                      return DropdownButtonFormField(
                                          value: selectedOriginId,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 18),
                                            errorStyle:
                                                TextStyle(color: Colors.red),
                                            border: OutlineInputBorder(),
                                            label: Text('Thành phố',
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                          items: orginList,
                                          onChanged: (value) {
                                            selectedOriginId = value!;
                                          });
                                    }),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        TextFormField(
                          initialValue: enteredBillingPhone.toString(),
                          decoration: const InputDecoration(
                            errorStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                            label: Text(
                              'Số điện thoại',
                              style: TextStyle(fontSize: 20),
                            ),
                            helperText: '',
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          validator: validateBillingPhone,
                          onSaved: (value) {
                            enteredBillingPhone = int.parse(value!);
                          },
                        ),
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Expanded(
                                child:
                                    Style(outputText: 'Phương thức thanh toán'),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Style2(outputText: 'COD'),
                                  Radio(
                                    value: PaymentMethod.cashOnDelivery,
                                    groupValue: _method,
                                    onChanged: (PaymentMethod? value) {
                                      setState(() {
                                        _method = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Style(
                  outputText: 'STT',
                ),
                SizedBox(width: 40), // Điều chỉnh khoảng cách nếu cần
                Style(
                  outputText: 'Ảnh',
                ),
                SizedBox(width: 50), // Điều chỉnh khoảng cách nếu cần
                Expanded(
                  child: Style(
                    outputText: 'Tên sản phẩm',
                  ),
                ),
                Style(
                  outputText: 'Số lượng',
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (ctx, index) {
                final productCart = widget.cartItems[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            imageUrl: productCart['image'],
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
                              outputText: productCart['name'],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Style2(
                                outputText:
                                    '${productCart['kilo'].toString()}g'),
                          ],
                        ),
                      ),
                      Style(outputText: productCart['quantity_buy'].toString()),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng: ${widget.totalAmount}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: submitBilling,
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
      ),
    );
  }
}
