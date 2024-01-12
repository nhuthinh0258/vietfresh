import 'package:flutter/material.dart';

import '../screen/auth.dart';

class FavoriteProduct extends StatefulWidget {
  const FavoriteProduct({super.key, required this.product});
  final Map<String, dynamic> product;
  @override
  State<FavoriteProduct> createState() {
    return _FavoriteProductState();
  }
}

class _FavoriteProductState extends State<FavoriteProduct> {
  var isFavorited = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorited();
  }

  void checkIfFavorited() async {
    final user = firebase.currentUser;
    if (user != null) {
      final favoriteSnapshot =
          await firestore.collection('favorite').doc(user.uid).get();

      if (favoriteSnapshot.exists &&
          favoriteSnapshot.data()?['products'] != null) {
        List<dynamic> favoriteProducts =
            List.from(favoriteSnapshot.data()!['products']);
        setState(() {
          isFavorited = favoriteProducts.any((product) {
            return product['product_id'] == widget.product['product_id'];
          });
        });
      }
    }
  }

  //Hàm thêm sản phẩm vào danh sách yêu thích
  void addToFavorite(String productId) async {
    final user = firebase.currentUser!;
    //lấy thông tin danh sách sản phẩm hiện tại
    final favoriteSnapshot =
        await firestore.collection('favorite').doc(user.uid).get();
    //Tạo danh sách yêu thích
    List<dynamic> favoriteProducts = [];
    //Kiểm tra danh sách có sản phẩm ko, nếu ko thì khởi tạo
    if (favoriteSnapshot.exists &&
        favoriteSnapshot.data()?['products'] != null) {
      favoriteProducts = List.from(favoriteSnapshot.data()!['products']);
    }
    if (!favoriteProducts.any((product) {
      return product['product_id'] == productId;
    })) {
      final newProduct = Map<String, dynamic>.from(widget.product);
      newProduct.remove('created_at'); // Xóa trường 'create'
      newProduct.remove('update_at'); // Xóa trường 'update'
      newProduct.remove('sort_timestamp'); // Xóa trường 'sort_timestamp'
      newProduct.remove('note'); // Xóa trường 'note'
      newProduct.remove('quantity'); // Xóa trường 'quantity'
      newProduct.remove('origin'); // Xóa trường 'quantity'
      newProduct.remove('user'); // Xóa trường 'quantity'
      newProduct.remove('vendor_id'); // Xóa trường 'quantity'
      favoriteProducts.add(newProduct);

      await firestore.collection('favorite').doc(user.uid).set({
        'products': favoriteProducts,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã thêm vào danh sách yêu thích'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
              label: 'Đồng ý',
              onPressed: () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).clearSnackBars();
              }),
        ),
      );
    }
  }

  //Hàm xóa sản phẩm khỏi danh sách yêu thích
  void removeFavorite(String productId) async {
    final user = firebase.currentUser!;
    //lấy thông tin danh sách sản phẩm hiện tại
    final favoriteSnapshot =
        await firestore.collection('favorite').doc(user.uid).get();
    if (favoriteSnapshot.exists &&
        favoriteSnapshot.data()?['products'] != null) {
      final favoriteProducts = List.from(favoriteSnapshot.data()!['products']);

      favoriteProducts.removeWhere((product) {
        return product['product_id'] == productId;
      });

      await firestore.collection('favorite').doc(user.uid).set({
        'products': favoriteProducts,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa khỏi danh sách yêu thích'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Đồng ý',
            onPressed: () {
              if (!mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 226, 218, 218),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
        color: Colors.pink,
        onPressed: () {
          if (firebase.currentUser == null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const AuthScreen();
            }));
          } else {
            setState(() {
              if (!isFavorited) {
                addToFavorite(widget.product['product_id']);
              } else {
                removeFavorite(widget.product['product_id']);
              }
              isFavorited = !isFavorited;
            });
          }
        },
      ),
    );
  }
}
