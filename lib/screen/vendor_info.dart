import 'package:chat_app/style.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class VendorInforUpdate extends StatefulWidget {
  const VendorInforUpdate({super.key, required this.vendorData});

  final Map<String, dynamic> vendorData;
  @override
  State<VendorInforUpdate> createState() {
    return _VendorInforUpdateState();
  }
}

class _VendorInforUpdateState extends State<VendorInforUpdate> {
  final customerInforKeyForm = GlobalKey<FormState>();
  var enteredVendorName = '';
  var enteredVendorAdress = '';
  var enteredVendorPhone = 0;
  var selectedOriginId = 'origin-1703218547035';

  var isUpdating = false;

  @override
  void initState() {
    super.initState();
    enteredVendorName = widget.vendorData['vendor_name'];
    enteredVendorAdress = widget.vendorData['vendor_address'];
    enteredVendorPhone = (widget.vendorData['vendor_phone']);
    selectedOriginId = widget.vendorData['vendor_origin'];
  }

  String? validatVendorName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chưa nhập thông tin';
    } else if (value.trim().length < 4 && value.isNotEmpty) {
      return 'Tên người dùng không hợp lệ';
    }
    return null;
  }

  String? validateVendorAdress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chưa nhập thông tin';
    } else if (value.trim().length < 4 && value.isNotEmpty) {
      return 'Địa chỉ không hợp lệ';
    }
    return null;
  }

  String? validateVendorPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại trống';
    } else if (value.trim().length > 10 || value.trim().length < 10) {
      return 'số điện thoại không hợp lệ';
    }
    return null;
  }

  String? validateVendorDate(String? value) {
    // Thêm logic validation của bạn ở đây
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn ngày sinh';
    }
    return null;
  }

  void submitVendorInfor() async {
    if (customerInforKeyForm.currentState!.validate()) {
      customerInforKeyForm.currentState!.save();
      setState(() {
        isUpdating = true;
      });
      final user = firebase.currentUser!;
      final originData =
          await firestore.collection('orgin').doc(selectedOriginId).get();
      final originName = originData.data()!['name'];
      final userData = firestore.collection('vendor').doc(user.uid);
      await userData.update({
        'vendor_location': originName,
        'vendor_name': enteredVendorName,
        'vendor_address': enteredVendorAdress,
        'vendor_origin': selectedOriginId,
        'vendor_phone': enteredVendorPhone,
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật thông tin thành công'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: customerInforKeyForm,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    initialValue: enteredVendorName,
                    decoration: InputDecoration(
                      prefix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '* ',
                            style: TextStyle(color: Colors.red), // Màu đỏ
                          ),
                          Icon(
                            Icons.store,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      errorStyle: const TextStyle(color: Colors.red),
                      border: const OutlineInputBorder(),
                      label: const Text(
                        'Tên cửa hàng',
                        style: TextStyle(fontSize: 20),
                      ),
                      helperText: '',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    validator: validatVendorName,
                    onSaved: (value) {
                      enteredVendorName = value!;
                    },
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: enteredVendorAdress,
                          decoration: InputDecoration(
                            prefix: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '* ',
                                  style: TextStyle(color: Colors.red), // Màu đỏ
                                ),
                                Icon(
                                  Icons.pin_drop,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            errorStyle: const TextStyle(color: Colors.red),
                            border: const OutlineInputBorder(),
                            label: const Text(
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
                          validator: validateVendorAdress,
                          onSaved: (value) {
                            enteredVendorAdress = value!;
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
                              canvasColor:
                                  Theme.of(context).scaffoldBackgroundColor),
                          child: FutureBuilder(
                              future: firestore.collection('orgin').get(),
                              builder: (ctx, oriSnapshot) {
                                if (oriSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Text('Không tìm thấy dữ liệu'),
                                  );
                                }
                                List<DropdownMenuItem<String>> orginList =
                                    oriSnapshot.data!.docs.map(
                                  (origin) {
                                    final orgin = origin.data();
                                    return DropdownMenuItem(
                                        value: origin.id,
                                        child: Text(
                                          orgin['name'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ));
                                  },
                                ).toList();

                                return DropdownButtonFormField(
                                    value: selectedOriginId,
                                    decoration: InputDecoration(
                                      prefix: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            '* ',
                                            style: TextStyle(
                                                color: Colors.red), // Màu đỏ
                                          ),
                                          Icon(
                                            Icons.location_city,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18),
                                      errorStyle:
                                          const TextStyle(color: Colors.red),
                                      border: const OutlineInputBorder(),
                                      label: const Text('Thành phố',
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
                    initialValue: enteredVendorPhone.toString(),
                    decoration: InputDecoration(
                      prefix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '* ',
                            style: TextStyle(color: Colors.red), // Màu đỏ
                          ),
                          Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      errorStyle: const TextStyle(color: Colors.red),
                      border: const OutlineInputBorder(),
                      label: const Text(
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
                    validator: validateVendorPhone,
                    onSaved: (value) {
                      enteredVendorPhone = int.parse(value!);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: submitVendorInfor,
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
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : const Style(
                                outputText: 'Cập nhật thông tin',
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
