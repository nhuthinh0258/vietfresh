import 'package:chat_app/screen/auth.dart';

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: firestore
            .collection('chat')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Không có tin nhắn'),
            );
          }
          final loadMessage = chatSnapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadMessage.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadMessage[index].data();
              final currentUserChatId = chatMessage['userid'];

              // Xác định xem tin nhắn có phải là tin nhắn đầu tiên từ người dùng hay không
              final isFirstMessage = index == loadMessage.length - 1 ||
                  loadMessage[index + 1].data()['userid'] != currentUserChatId;

              return FutureBuilder(
                future:
                    firestore.collection('users').doc(currentUserChatId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.hasData) {
                    final userData =
                        userSnapshot.data!.data();
                    // Sử dụng thông tin người dùng để hiển thị tin nhắn
                    if (isFirstMessage) {
                      return MessageBubble.first(
                        userImage: userData?['image'], // Ảnh đại diện mới nhất
                        username: userData?['username'],
                        message: chatMessage['text'],
                        isMe: user.uid == currentUserChatId,
                      );
                    } else {
                      return MessageBubble.next(
                        message: chatMessage['text'],
                        isMe: user.uid == currentUserChatId,
                      );
                    }
                  }
                  // Trong khi đợi, có thể hiển thị placeholder hoặc không hiển thị gì
                  return Container(
                    padding:const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    child:const Text('Loading...'),
                  );
                },
              );
            },
          );
        });
  }
}
