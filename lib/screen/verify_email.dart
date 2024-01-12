import 'dart:async';

import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/vendor_information.dart';
import 'package:chat_app/style.dart';
import 'package:flutter/material.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() {
    return _VerifyEmailState();
  }
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isResend = false;
  Timer? timer;
  var isEmailVerified = firebase.currentUser!.emailVerified;

  @override
  void initState() {
    super.initState();
    if (!isEmailVerified) {
      sendEmailVerify();
    }
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      return checkEmailVerify();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void checkEmailVerify() async {
    await firebase.currentUser!.reload();
    if (mounted) {
      setState(() {
        isEmailVerified = firebase.currentUser!.emailVerified;
      });
    }

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  void sendEmailVerify() async {
    final user = firebase.currentUser!;
    await user.sendEmailVerification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          'Email xác thực đã được gửi. Vui lòng kiểm tra hòm thư của bạn.'),
    ));
    setState(() {
      isResend = false;
    });
    await Future.delayed(const Duration(minutes: 1));
    if (mounted) {
      setState(() {
        isResend = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const VendorInfor()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Xác thực email'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Style(outputText: 'Đã gửi link xác thực đến Email'),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      onPressed: isResend ? sendEmailVerify : null,
                      icon: const Icon(Icons.email),
                      label: const Text('Gửi lại email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
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
