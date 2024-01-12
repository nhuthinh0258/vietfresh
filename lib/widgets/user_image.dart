import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final firebaseStorage = FirebaseStorage.instance;

class UserImage extends StatefulWidget {
  const UserImage({super.key});

  @override
  State<UserImage> createState() {
    return _UserImage();
  }
}

class _UserImage extends State<UserImage> {
  File? pickerImage;
  bool isLoadingImage = false;
  late ImageProvider<Object> imageProvider;

  //Hàm tải ảnh lên firestorage
  void imageUpload(File image) async {
    setState(() {
      isLoadingImage = true;
    });
    //Lấy thông tin người dùng hiện tại từ Firebase Authentication
    final user = firebase.currentUser!;

    //Tạo một tham chiếu đến Firebase Storage
    final storageRef =
        firebaseStorage.ref().child('user_image').child('${user.uid}.jpg');
    // Tải file ảnh lên Firebase Storage
    await storageRef.putFile(image);
    //Lấy URL của ảnh sau khi tải lên
    final imageUrl = await storageRef.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': imageUrl,
    });
    setState(() {
      isLoadingImage = false;
    });
  }

  //Hàm chọn ảnh
  void onPickImage() async {
    final pickImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    if (pickImage == null) {
      return;
    }

    setState(() {
      pickerImage = File(pickImage.path);
    });

    imageUpload(pickerImage!);
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser!;
    return FutureBuilder(
      future: firestore.collection('users').doc(user.uid).get(),
      builder: ((ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting ||
            isLoadingImage) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 32,
              horizontal: 30,
            ),
            child: CircularProgressIndicator(),
          ));
        }
        if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
          return GestureDetector(
            onTap: onPickImage,
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.camera_alt, size: 25), // Placeholder icon
            ),
          );
        }
        final userData = userSnapshot.data!.data();
        final imageUser = userData?['image']; // Sử dụng toán tử an toàn

        if (imageUser != null) {
          imageProvider = CachedNetworkImageProvider(imageUser);
        } else {
          imageProvider = const AssetImage('assets/images/VietFresh.png');
        }
        return GestureDetector(
          onTap: onPickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: imageProvider,
          ),
        );
      }),
    );
  }
}
