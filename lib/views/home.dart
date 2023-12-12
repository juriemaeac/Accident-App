import 'dart:async';

import 'package:accidentapp/views/notification/trigger_notif.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../authlayout.dart';
import '../models/userData.dart';
import '../services/userDataService.dart';
import '../viewmodels/homeViewModel.dart';
import '../viewmodels/userViewModel.dart';
import '../models/transaction.dart' as trans;
import 'accident.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserDataService userDataService = UserDataService();
  StreamSubscription? streamSub;

  @override
  void initState() {
    super.initState();

    UserData user = context.read<UserData>();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<HomeViewModel>(context, listen: false).setup(user);
    });

    if (user.relatives != null && user.relatives!.isNotEmpty) {
      List<String?> stringList =
          (user.relatives as List<UserData>).map((e) => e.uid).toList();
      streamSub = FirebaseFirestore.instance
          .collection("transactions")
          .where("userID",
              whereIn: [...stringList, FirebaseAuth.instance.currentUser!.uid])
          .snapshots()
          .listen((event) async {
            if (event.docChanges.isNotEmpty) {
              if (user.relatives != null && user.relatives!.isEmpty) {
                return;
              }
              Map<String, dynamic>? data = event.docChanges.first.doc.data();
              UserData? userData = user.relatives?.firstWhereOrNull(
                  (element) => element.uid == data!['userID']);
              if (userData == null) {
                return;
              }

              trans.Transaction transTemp = trans.Transaction.fromMap(data!);
              transTemp.transID = event.docChanges.first.doc.id;
              transTemp.userData = userData;

              Provider.of<HomeViewModel>(context, listen: false)
                  .addActivity(transTemp);
            }
          });
    }
  }

  void dispose() {
    super.dispose();
    streamSub?.cancel();
  }

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: MediaQuery.of(ctx).size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Text("Accidents",
                            style:
                                TextStyle(color: Colors.white, fontSize: 24)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            ctx.watch<HomeViewModel>().accidentCount.toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color.fromARGB(255, 56, 56, 56),
            ),
          ),
          Visibility(
              visible: ctx.read<UserData>()?.userType == "Rider",
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  child: Row(children: [
                    Text("Click start if you're driving:"),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 56, 56, 56),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            showDialog<void>(
                              barrierDismissible: true,
                              context: ctx,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: const Text('Pairing'),
                                    content: Text(
                                        "Searching for bluetooth devices"));
                              },
                            );
                          },
                          child: Text(
                            "Start",
                            style: TextStyle(color: Colors.white),
                          )),
                    ))
                  ]),
                ),
              )),
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (context) => TriggerNotifTest()),
                );
              },
              child: Text(
                "Activity",
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 241, 81, 6),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                  scrollDirection: Axis.vertical,
                  children: ctx
                      .watch<HomeViewModel>()
                      .allActivities
                      .map((e) => GestureDetector(
                            onTap: () {
                              if (e.isFalseAlarm != null &&
                                  e.isFalseAlarm == true) {
                                return;
                              }
                              Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                    builder: (context) => Accident(
                                        trans: e, originalContext: ctx)),
                              );
                            },
                            child: Text(
                              e.isFalseAlarm != null && e.isFalseAlarm == true
                                  ? "The user marked the alarm as false"
                                  : "The system detected that ${e.userData?.nickname} was caught in an accident",
                              textAlign: TextAlign.center,
                            ),
                          ))
                      .toList()),
            ),
          )
        ],
      ),
    );
  }
}
