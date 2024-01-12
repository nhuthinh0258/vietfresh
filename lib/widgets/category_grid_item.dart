import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/vendor_category.dart';
import 'package:flutter/material.dart';

class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem({super.key});



  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore.collection('category').limit(8).snapshots(),
      builder: (ctx, cateSnapshot) {
        if (!cateSnapshot.hasData) {
          return const CircularProgressIndicator();
        }
        
        final categories = cateSnapshot.data!.docs;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: GridView.builder(
              //Đặt kích thước của GridView chỉ chiếm đủ nội dung bên trong
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Number of columns
                childAspectRatio: 1,
              ),
              itemBuilder: (ctx, index) {
                final category = categories[index].data();
                return GestureDetector(
                  onTap: () {
                    // fetchVendorsByCategory(category, context);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return VendorListHome(category: category);
                    }));
                  },
                  child: Card(
                    child: Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                color: Colors.grey,
                                child: category['image'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: category['image'],
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Text(category['name']),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }
}
