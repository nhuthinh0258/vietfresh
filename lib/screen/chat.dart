import 'package:chat_app/widgets/chat_message.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/cart_icon.dart';

final firebase = FirebaseAuth.instance;

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user= firebase.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trò chuyện'),
        centerTitle: true,
        actions: [
          if (user != null) const CartIconWithBadge(),
        ],
      ),
      body: Column(
        children: const [
          Expanded(child: ChatMessage()),
          NewMessage(),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}
