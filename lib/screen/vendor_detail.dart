import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/vendor_info.dart';
import 'package:chat_app/screen/vendor_information.dart';

import 'package:chat_app/style.dart';

import 'package:chat_app/widgets/vendor_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorDetail extends ConsumerWidget {
  const VendorDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = firebase.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa Hàng'),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: firestore.collection('vendor').doc(user.uid).snapshots(),
          builder: (ctx, venSnapshot) {
            if (venSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!venSnapshot.hasData || venSnapshot.data!.data()!.isEmpty) {
              return const Center(
                child: Text('Không tìm thấy dữ liệu'),
              );
            }
            final vendorData = venSnapshot.data!.data();

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          VendorImage(
                            vendorId: vendorData!['user_id'],
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Style(
                            outputText: vendorData['vendor_name'],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color.fromARGB(255, 232, 223, 223),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.account_circle,
                                  color: Color.fromARGB(255, 77, 71, 71),
                                ),
                                title: const Style(
                                    outputText: 'Chi tiết tài khoản'),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (ctx) {
                                    return VendorInforUpdate(
                                        vendorData: vendorData);
                                  }));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.report,
                                  color: Color.fromARGB(255, 77, 71, 71),
                                ),
                                title: const Style(outputText: 'Báo cáo'),
                                onTap: () {},
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.help,
                                  color: Color.fromARGB(255, 77, 71, 71),
                                ),
                                title: const Style(outputText: 'Trợ giúp'),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
