import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('AlertNotifs')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              var notifications = snapshot.data?.docs ?? [];
              notifications
                  .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var notification =
                      notifications[index].data() as Map<String, dynamic>;

                  int unixTimestamp = int.parse(notification['timestamp']);

                  DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

                  // Format DateTime
                  String formattedTimestamp =
                      DateFormat('hh:mm a').format(dateTime);
                  return ListTile(
                    title: Text(notification['title']),
                    subtitle: Text(notification['body']),
                    trailing: Text(formattedTimestamp),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
