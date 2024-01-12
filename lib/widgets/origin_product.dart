import 'package:flutter/material.dart';

import '../screen/auth.dart';

class OriginProduct extends StatelessWidget {
  const OriginProduct({super.key, required this.detailData});
  final Map<String, dynamic> detailData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestore
          .collection('orgin')
          .where('origin_id', isEqualTo: detailData['origin'])
          .get(),
      builder: (ctx, oriSnapshot) {
        if (oriSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(
                  width: 23, height: 23, child: CircularProgressIndicator()));
        }
        final originItems = oriSnapshot.data!.docs.first.data();
        return Text(
          'Xuất xứ: ${originItems['name']}',
          style: const TextStyle(color: Colors.black, fontSize: 20),
        );
      },
    );
  }
}
