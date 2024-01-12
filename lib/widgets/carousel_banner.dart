import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screen/auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() {
    return _CarouselBannerState();
  }
}

class _CarouselBannerState extends State<CarouselBanner> {
  Future<List<String>> fetchBannerImages() async {
    final bannerData = await firestore.collection('banner').get();
    List<String> imageUrls = [];
    for (final doc in bannerData.docs) {
      imageUrls.add(doc['image']);
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchBannerImages(), // Lấy ảnh từ Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Hiển thị loading khi đang chờ
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
              "Ko tìm thấy banner."); // Hiển thị thông báo nếu không có ảnh
        }

        List banners = snapshot.data!; // Lấy danh sách ảnh từ snapshot

        List<Widget> imageSliders = banners.map((imageUrl) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          );
        }).toList();

        return CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
          ),
          items: imageSliders,
        );
      },
    );
  }
}
