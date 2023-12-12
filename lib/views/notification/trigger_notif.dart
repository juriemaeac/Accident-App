import 'package:accidentapp/services/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TriggerNotifTest extends StatefulWidget {
  const TriggerNotifTest({super.key});

  @override
  State<TriggerNotifTest> createState() => _TriggerNotifTestState();
}

class _TriggerNotifTestState extends State<TriggerNotifTest> {
  String titleNotif = "Notification Title";
  String bodyNotif = "Notification Body Notif";
  //use uuid to create notif id
  String notifId =
      "${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().year.toString()}${const Uuid().v1().replaceAll(RegExp(r'-'), '').substring(0, 10)}";
  String mtoken = "";
  List<String> destinationTokens = [];
  void initState() {
    super.initState();
  }

  void getsendToTokens() {
    FirebaseFirestore.instance
        .collection('userTokens')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          mtoken = doc["token"];
          destinationTokens.add(mtoken);
          titleNotif = "Notif Alert";
          bodyNotif = "Notif Body";
          print("destinationTokens: $destinationTokens");
        });

        print("send notiffff");
      }
    });
  }

  //iterate the list of users and add their tokens to userTokens collection
  // void addUserTokens() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) async {
  //       String userToken = doc["userToken"];
  //       FirebaseApi().addUserTokens(userToken, doc.id);
  //       print("doc id: ${doc.id}");
  //       print("userToken: $userToken");
  //       print("add user tokens");
  //     });
  //   });
  // }

  //check if the isfalseAlarm field in the transaction is false then send notif
  void checkFalseAlarm() {
    FirebaseFirestore.instance
        .collection('transactions')
        .where("IsFalseAlarm", isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["IsFalseAlarm"] == false) {
          setState(() {
            titleNotif = "Accident Alert";
            bodyNotif = "An accident has been detected";
          });
          handleButtonPressed();
        } else {
          print("false alarm");
        }
      }
    });
  }

  Future<void> handleButtonPressed() async {
    getsendToTokens();
    //check destinationTokens list remove duplicates
    destinationTokens = destinationTokens.toSet().toList();
    print("destinationTokens: $destinationTokens");
    for (var destination in destinationTokens) {
      FirebaseApi()
          .sendPushMessage(destination, titleNotif, bodyNotif, notifId);
    }

    FirebaseApi().addNotification(titleNotif, bodyNotif, notifId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigger Notification Test'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                //elevated button
                ElevatedButton(
                  onPressed: () {
                    handleButtonPressed();
                  },
                  child: const Text('Trigger Notification'),
                ),
                SizedBox(
                  height: 20,
                ),
                //elevated button
                ElevatedButton(
                  onPressed: () {
                    checkFalseAlarm();
                  },
                  child: const Text('Add userTokens'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
