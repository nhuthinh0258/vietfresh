import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/tabs_vendor.dart';
import 'package:flutter/material.dart';

class VendorInfor extends StatefulWidget {
  const VendorInfor({super.key});
  @override
  State<VendorInfor> createState() {
    return _VendorInforState();
  }
}

class _VendorInforState extends State<VendorInfor> {
  final vendorInfoKeyForm = GlobalKey<FormState>();
  var enteredVendorName = '';
  var enteredVendorAdress = '';
  var enteredVendorPhone = 1;
  var selectedOriginId = 'origin-1703218547035';
  var isSending = false;

  String? validatVendorName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chưa nhập thông tin';
    } else if (value.trim().length < 4 && value.isNotEmpty) {
      return 'Tên người dùng không hợp lệ';
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

  String? validateVendorAdress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chưa nhập thông tin';
    } else if (value.trim().length < 4 && value.isNotEmpty) {
      return 'Địa chỉ không hợp lệ';
    }
    return null;
  }

  void submitInfor() async {
    if (vendorInfoKeyForm.currentState!.validate()) {
      vendorInfoKeyForm.currentState!.save();
      setState(() {
        isSending = true;
      });
      final user = firebase.currentUser!;
      final originData =
          await firestore.collection('orgin').doc(selectedOriginId).get();
      final originName = originData.data()!['name'];
      await firestore.collection('vendor').doc(user.uid).set({
        'user_id': user.uid,
        'vendor_name': enteredVendorName,
        'vendor_address': enteredVendorAdress,
        'vendor_origin': selectedOriginId,
        'vendor_location': originName,
        'vendor_email': user.email,
        'vendor_phone': enteredVendorPhone
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) {
            return const TabsVendor();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cửa hàng'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: vendorInfoKeyForm,
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.store),
                    errorStyle: TextStyle(color: Colors.red),
                    border: OutlineInputBorder(),
                    label: Text(
                      'Tên cửa hàng',
                      style: TextStyle(fontSize: 20),
                    ),
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
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.pin_drop),
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(),
                          label: Text(
                            'Địa chỉ',
                            style: TextStyle(fontSize: 20),
                          ),
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
                                            fontWeight: FontWeight.w500),
                                      ));
                                },
                              ).toList();

                              return DropdownButtonFormField(
                                  value: selectedOriginId,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.location_city),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 18),
                                    errorStyle: TextStyle(color: Colors.red),
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
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    errorStyle: TextStyle(color: Colors.red),
                    border: OutlineInputBorder(),
                    label: Text(
                      'Số điện thoại',
                      style: TextStyle(fontSize: 20),
                    ),
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
                      onPressed: submitInfor,
                      style: ButtonStyle(
                        //Thay đổi màu nền của button theo màu theme đã khai báo
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColorLight,
                        ),
                      ),
                      child: const Text('Xác nhận'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
