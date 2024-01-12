import 'package:chat_app/style.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class GuestDetail extends StatelessWidget {
  const GuestDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                    const CircleAvatar(
                      radius: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return const AuthScreen();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor),
                      child: const Style(
                        outputText: 'Đăng nhập/ Đăng ký',
                      ),
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
                          title: const Style(outputText: 'Chi tiết tài khoản'),
                          onTap: () {
                            if (firebase.currentUser == null) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const AuthScreen();
                              }));
                            }
                          }),
                      const SizedBox(
                        height: 6,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.sell,
                          color: Color.fromARGB(255, 77, 71, 71),
                        ),
                        title: const Style(outputText: 'Đăng ký bán hàng'),
                        onTap: () {
                          if (firebase.currentUser == null) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const AuthScreen();
                            }));
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
                        onTap: () {
                          if (firebase.currentUser == null) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const AuthScreen();
                            }));
                          }
                        },
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
                        onTap: () {
                          if (firebase.currentUser == null) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const AuthScreen();
                            }));
                          }
                        },
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
                        onTap: () {
                          if (firebase.currentUser == null) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const AuthScreen();
                            }));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
