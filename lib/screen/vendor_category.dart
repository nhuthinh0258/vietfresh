import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/vendor_product_list.dart';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class VendorListHome extends StatelessWidget {
  const VendorListHome({super.key, required this.category});
  final Map<String, dynamic> category;

  Stream getVendorStreamOnProducts(String categoryId) {
    final productStream = firestore
        .collection('product')
        .where('category', isEqualTo: categoryId)
        .snapshots();
    return productStream.asyncMap(
      (productSnapshot) async {
        Set<String> vendorIds = {};
        for (final doc in productSnapshot.docs) {
          String? vendorId = doc.data()['vendor_id'];
          vendorIds.add(vendorId!);
        }
        List<Map<String, dynamic>> vendorList = [];
        for (final vendorId in vendorIds) {
          final vendorData =
              await firestore.collection('vendor').doc(vendorId).get();
          vendorList.add(vendorData.data()!);
        }
        return vendorList;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream vendorStream = getVendorStreamOnProducts(category['category_id']);
    return Scaffold(
      appBar: AppBar(
        title: Text(category['name'],),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: vendorStream,
          builder: (ctx, venSnapshot) {
            if (venSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!venSnapshot.hasData || venSnapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/cactus.png',
                        width: 100,
                        height: 100,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.75)),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Hiện không có nhà cung cấp nào',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(0.75)),
                    )
                  ],
                ),
              );
            }
            List<Map<String, dynamic>> vendorList = venSnapshot.data!;
            return ListView.builder(
                itemCount: vendorList.length,
                itemBuilder: (ctx, index) {
                  ImageProvider<Object> imageProvider;
                  final vendor = vendorList[index];
                  final imageVendor = vendor['image'];
                  if (imageVendor != null) {
                    imageProvider = CachedNetworkImageProvider(imageVendor);
                  } else {
                    imageProvider =
                        const AssetImage('assets/images/VietFresh.png');
                  }
                  return Card(
                    color: Theme.of(context).primaryColorLight,
                    shape: RoundedRectangleBorder(
                        //thuộc tính shape được sử dụng để xác định hình dạng của một widget,
                        borderRadius: BorderRadius.circular(
                            8) //với RoundedRectangleBorder, nó tạo ra một đường viền hình chữ nhật với các góc được bo tròn.
                        ),
                    clipBehavior: Clip
                        .hardEdge, //sử dụng để xác định cách widget xử lý việc cắt bớt nội dung khi vượt quá ranh giới của nó,Giá trị Clip.hardEdge được sử dụng để cắt bớt nội dung một cách cứng nhắc, không làm mờ hay làm mịn các góc cạnh.
                    margin: const EdgeInsets.all(8),
                    elevation:
                        2, //xác định độ nổi của một widget trong giao diện, giá trị càng lớn độ nổi càng cao
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return VendorProductList(
                              vendor: vendor, imageProvider: imageProvider,category: category,);
                        }));
                      },
                      child: Stack(
                        //sử dụng để xếp chồng các widget lên nhau. Nó cho phép định vị các widget con theo tọa độ tương đối hoặc tuyệt đối và hiển thị chúng lên màn hình
                        children: [
                          FadeInImage(
                            //hiển thị một hình ảnh trong quá trình nạp dữ liệu.
                            placeholder: MemoryImage(
                                kTransparentImage), // Hình ảnh tạm thời, ở đây là một hình ảnh trong suốt

                            image:
                                imageProvider, // Đường dẫn đến hình ảnh chính
                            fit: BoxFit
                                .cover, //xác định cách hiển thị nội dung của một widget trong một không gian giới hạn, ở đây sẽ được tự động co dãn mà vẫn giữ ti lệ gốc
                            width: double
                                .infinity, //Ảnh sẽ chiếm hết không gian theo chiều ngang nhiều nhất có thể
                            height: 200,
                          ),
                          Positioned(
                            bottom: 0, //Vị trí dưới cùng
                            left: 0, //lấp đầy bên trái
                            right: 0, //lấp đầy bên phải
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 44,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    vendor['vendor_name'],
                                    maxLines: 2, // hiển thị tối đa 2 dòng
                                    textAlign: TextAlign.center,
                                    softWrap:
                                        true, //văn bản sẽ tự động wrap xuống dòng khi nó vượt quá kích thước của widget
                                    overflow: TextOverflow
                                        .ellipsis, //nếu văn bản vượt quá kích thước của widget, các ký tự cuối cùng sẽ được thay thế bằng dấu chấm ba (...)
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
