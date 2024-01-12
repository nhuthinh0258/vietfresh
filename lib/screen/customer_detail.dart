
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/customer_info.dart';
import 'package:chat_app/screen/tabs_vendor.dart';
import 'package:chat_app/screen/vendor_information.dart';
import 'package:chat_app/screen/verify_email.dart';
import 'package:chat_app/style.dart';
import 'package:chat_app/widgets/user_image.dart';
import 'package:flutter/material.dart';


import '../widgets/cart_icon.dart';

class CustomerDetail extends StatelessWidget {
  const CustomerDetail({
    super.key,
  });

  Future<bool> checkVendorInfoEntered() async {
    final user = firebase.currentUser!;
    // Lấy thông tin cửa hàng từ Firestore
    final vendorInfo = await firestore
        .collection('vendor')
        .where('user_id', isEqualTo: user.uid)
        .get();
    return vendorInfo.docs.isNotEmpty;
  }

  void ensureLoggedIn(BuildContext context, Function action) {
    if (firebase.currentUser == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return const AuthScreen();
          },
        ),
      );
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        centerTitle: true,
        actions: [
          if (user != null) const CartIconWithBadge(),
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('users').doc(user!.uid).snapshots(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final userData = userSnapshot.data!.data();
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const UserImage(),
                        Style(
                          outputText:
                              'Xin chào ${userData!['username']}',
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
                          ListTile(
                            leading: const Icon(
                              Icons.account_circle,
                              color: Color.fromARGB(255, 77, 71, 71),
                            ),
                            title:
                                const Style(outputText: 'Chi tiết tài khoản'),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (ctx) {
                                return CustomerInfor(userData: userData,);
                              }));
                            },
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.sell,
                              color: Color.fromARGB(255, 77, 71, 71),
                            ),
                            title: const Style(outputText: 'Đăng ký bán hàng'),
                            onTap: () async {
                              final user = firebase.currentUser!;
                              if (!user.emailVerified) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                  return const VerifyEmail();
                                }));
                              } else {
                                bool hasEnteredVendorInfo =
                                    await checkVendorInfoEntered();
                                if (hasEnteredVendorInfo) {
                                  // Nếu thông tin cửa hàng đã được nhập, chuyển đến màn hình sản phẩm
                                  if (!context.mounted) return;
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (ctx) {
                                    return const TabsVendor();
                                  }));
                                } else {
                                  // Nếu thông tin cửa hàng chưa được nhập, chuyển đến màn hình nhập thông tin cửa hàng
                                  if (!context.mounted) return;
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (ctx) {
                                    return const VendorInfor();
                                  }));
                                }
                              }
                            },
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.settings,
                              color: Color.fromARGB(255, 77, 71, 71),
                            ),
                            title: const Style(outputText: 'Cài đặt'),
                            onTap: () {},
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.report,
                              color: Color.fromARGB(255, 77, 71, 71),
                            ),
                            title: const Style(outputText: 'Báo cáo'),
                            onTap: () {},
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.help,
                              color: Color.fromARGB(255, 77, 71, 71),
                            ),
                            title: const Style(outputText: 'Trợ giúp'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          firebase.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            )),
                        child: const Style(outputText: 'Đăng xuất'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
