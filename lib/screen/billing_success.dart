
import 'package:chat_app/style.dart';
import 'package:flutter/material.dart';

import '../style2.dart';

class BillingSuccess extends StatelessWidget {
  const BillingSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/success-edit.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(
              height: 6,
            ),
            const Style(outputText: 'Thành công!'),
            const SizedBox(
              height: 2,
            ),
            const Style2(outputText: 'Đơn hàng của bạn đang được xác nhận'),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Tiếp tục mua sắm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
