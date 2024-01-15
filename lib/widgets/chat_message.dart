import 'package:chat_app/screen/auth.dart';

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: firestore.collection('chat').doc(user.uid).snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!chatSnapshot.hasData) {
          return const Center(
            child: Text('Không có tin nhắn'),
          );
        }

        final chatData = chatSnapshot.data!.data();
        if (chatData == null || chatData['chats'] == null) {
          return const Center(
            child: Text('Không có tin nhắn'),
          );
        }

        final chatList = List.from(chatData['chats']);

        chatList.sort((a, b) {
          Timestamp timestampA = a['sort_time'];
          Timestamp timestampB = b['sort_time'];

          // Sử dụng phương thức compareTo của Timestamp để so sánh
          return timestampA.compareTo(timestampB);
        });

        // Reverse mảng để có thứ tự từ mới đến cũ
        final chats = chatList.reversed.toList();
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: chats.length,
          itemBuilder: (ctx, index) {
            final chatMessage = chats[index];
            final currentUserChatId = chats[index]['senderId'];
            final isFirstMessage = index == chats.length - 1 ||
                chats[index + 1]['senderId'] != currentUserChatId;

            return FutureBuilder(
              future: firestore
                  .collection('users')
                  .doc(chatMessage['senderId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.done &&
                    userSnapshot.hasData) {
                  final userData = userSnapshot.data!.data();
                  if (isFirstMessage) {
                    return MessageBubble.first(
                      userImage: userData?['image'],
                      username: userData?['username'],
                      message: chatMessage['message'],
                      isMe: user.uid == currentUserChatId,
                    );
                  } else {
                    return MessageBubble.next(
                      message: chatMessage['message'],
                      isMe: user.uid == currentUserChatId,
                    );
                  }
                }

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: const Text('Loading...'),
                );
              },
            );
          },
        );
      },
    );
  }
}
