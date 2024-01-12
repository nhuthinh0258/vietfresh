import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final firebaseStorage = FirebaseStorage.instance;

class VendorImage extends StatefulWidget {
  const VendorImage({super.key, required this.vendorId});

  final String? vendorId;
  @override
  State<VendorImage> createState() {
    return _VendorImageState();
  }
}

class _VendorImageState extends State<VendorImage> {
  File? pickerVendor;
  bool isLoadingImage = false;
  late ImageProvider<Object> imageProvider;
  //Hàm đẩy ảnh lên
  void vendorUpload(File image) async {
    setState(() {
      isLoadingImage = true;
    });
    //Lấy thông tin người dùng hiện tại từ Firebase Authentication
    // final user = firebase.currentUser!;
    //tạo tham chiếu đến storage
    final storageRef = firebaseStorage
        .ref()
        .child('vendor_image')
        .child('${widget.vendorId}.jpg');
    await storageRef.putFile(image);
    final vendorUrl = await storageRef.getDownloadURL();
    await firestore.collection('vendor').doc(widget.vendorId).update({
      'image': vendorUrl,
    });
    setState(() {
      isLoadingImage = false;
    });
  }

  //Hàm chọn ảnh
  void onPickedVendorImage() async {
    final pickedVendorImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    //Nếu ko có ảnh được chọn, kết thúc hàm
    if (pickedVendorImage == null) {
      return;
    }

    setState(() {
      pickerVendor = File(pickedVendorImage.path);
    });
    vendorUpload(pickerVendor!);
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser!;
    return StreamBuilder(
        stream: firestore
            .collection('vendor')
            .where('user_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (ctx, venSnapshot) {
          if (venSnapshot.connectionState == ConnectionState.waiting ||
              isLoadingImage) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 32,
                ),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (!venSnapshot.hasData || venSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Không tìm thấy dữ liệu'),
            );
          }
          final vendorData = venSnapshot.data!.docs.first.data();
          final vendorImage = vendorData['image'];
          if (vendorImage != null) {
            imageProvider = CachedNetworkImageProvider(vendorImage);
          } else {
            imageProvider = const AssetImage('assets/images/VietFresh.png');
          }
          return GestureDetector(
            onTap: onPickedVendorImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              backgroundImage: imageProvider,
            ),
          );
        });
  }
}
