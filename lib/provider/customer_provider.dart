import 'package:chat_app/screen/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/customer.dart';

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    //Gọi hàm user ngay khi khởi tạo
    user();
  }

  void user() {
    //Lắng nghe sự thay đổi trạng thái đăng nhập của người dùng
    firebase.authStateChanges().listen((user) async {
      //Kiểm tra nếu không có thông tin người dùng (người dùng đăng xuất)
      if (user == null) {
        //Kết thúc hàm nếu không có người dùng đăng nhập
        return;
      }
      //lấy dữ liệu từ Firestore thông qua get()
      final userData = await firestore.collection('users').doc(user.uid).get();
      final userName = userData.data()!['username'];

      //Cập nhật trạng thái với email của người dùng nếu họ đăng nhập
      state = UserState(
        userName: userName,
      );
    });
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
