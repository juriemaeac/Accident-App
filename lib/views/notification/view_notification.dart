// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_interpolation_to_compose_strings
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewNotification extends StatefulWidget {
  final String notificationId;
  const ViewNotification({super.key, required this.notificationId});

  static const route = '/viewNotification';

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String mtoken = "";
  String name = "";
  String title = "";
  String bodyNotif = "";
  String notifId = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          name = documentSnapshot['firstName'] +
              " " +
              documentSnapshot['lastName'];
        });
      } else {}
    });
    getNotifDetails();
  }

  getNotifDetails() {
    final notification = FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('notifications')
        .get();

    notification.then((value) {
      for (var element in value.docs) {
        if (element['notificationId'] == widget.notificationId) {
          setState(() {
            notifId = element.id;
            bodyNotif = element['body'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "New Notification",
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              //display the notification details here
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifId,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      bodyNotif,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
