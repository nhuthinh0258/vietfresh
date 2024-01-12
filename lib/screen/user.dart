import 'package:chat_app/screen/auth.dart';
import 'package:chat_app/screen/tabs_customer.dart';
import 'package:chat_app/screen/tabs_guest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: firebase.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            final user = firebase.currentUser!;
            final userData =
                firestore.collection('users').doc(user.uid).snapshots();
            return StreamBuilder(
              stream: userData,
              builder: (ctx, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (userSnapshot.hasData && userSnapshot.data != null) {
                  final users = userSnapshot.data!.data();
                  if (users != null && users['isDisabled'] == true) {
                    firebase.signOut();
                    return const TabGuest();
                  }
                  return const TabsCustomer();
                }
                return const TabGuest();
              },
            );
          }
          return const TabGuest();
        },
      ),
    );
  }
}
