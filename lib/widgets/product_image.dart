import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImage extends StatefulWidget {
  const ProductImage(
      {super.key,
      required this.onSelectedProductImage,
      required this.initialImageUrl});

  final void Function(File image) onSelectedProductImage;
  final String? initialImageUrl;
  @override
  State<ProductImage> createState() {
    return _ProductImageState();
  }
}

class _ProductImageState extends State<ProductImage> {
  File? selectedImage;
  var isLoadImage = true;

  void pickCategoryImage() async {
    final pickedCategoryImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery);
    if (pickedCategoryImage == null) {
      return;
    }
    setState(() {
      selectedImage = File(pickedCategoryImage.path);
      isLoadImage = false;
    });
    widget.onSelectedProductImage(selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (selectedImage != null) {
      content = Image.file(
        selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (widget.initialImageUrl != null) {
      // Nếu không có ảnh đã chọn nhưng có ảnh ban đầu, hiển thị ảnh ban đầu
      content = InkWell(
        onTap: pickCategoryImage,
        child: CachedNetworkImage (
          imageUrl:widget.initialImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      // Nếu không có ảnh nào, hiển thị nút cho phép chọn ảnh
      content = TextButton.icon(
        onPressed: pickCategoryImage,
        icon: const Icon(Icons.camera),
        label: const Text('Chọn ảnh'),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
      ),
      width: double.infinity,
      height: 250,
      alignment: Alignment.center,
      child: content,
    );
  }
}
