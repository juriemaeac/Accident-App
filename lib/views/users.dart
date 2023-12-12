import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relation.dart';
import '../models/userData.dart';
import '../services/relationshipService.dart';
import '../viewmodels/userViewModel.dart';

class Users extends StatefulWidget {
  Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: (context.watch<UserData>().relatives != null ||
                  context.watch<UserData>().forApproval != null)
              ? [
                  ...?context
                      .watch<UserViewModel>()
                      .relatives
                      ?.map((e) => UserRow(e))
                      .toList(),
                  ...?context
                      .watch<UserViewModel>()
                      .forApproval
                      ?.map((e) => ForApproval(rel: e))
                      .toList()
                ]
              : []),
    );
  }
}

class UserRow extends StatefulWidget {
  late final UserData user;
  UserRow(UserData userData) {
    user = userData;
  }

  @override
  State<UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<UserRow> {
  RelationShipService relService = RelationShipService();
  String? relation = null;
  bool notif = false;
  String? relId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Relation? rel = await relService
          .getMyRelationship(widget.user?.uid as String) as Relation?;
      setState(() {
        relId = rel?.relID;
        relation = rel?.relation;
        notif = rel?.notification != null ? rel?.notification as bool : false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Container(
            height: 50,
            width: 50,
            child: Image.asset("assets/avatars/${widget.user.userAvatar}"),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(200))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(widget.user.nickname), Text(relation ?? "")],
            ),
          ),
          Expanded(child: Container()),
          GestureDetector(
              onTap: () {
                UserViewModel userViewModel =
                    Provider.of<UserViewModel>(context, listen: false);
                showDialog<void>(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: const Text('Notice'),
                      content: Text(
                          "Are you sure you want to remove this user from relatives?"),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text("Cancel")),
                        ElevatedButton(
                            onPressed: () {
                              userViewModel.removeRelative(widget.user);
                              Navigator.of(ctx).pop();
                            },
                            child: Text("Proceed"))
                      ],
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text("Delete"),
              )),
          Switch(
              value: notif,
              onChanged: (data) {
                relService.updateNotification(data, relId as String);
                setState(() {
                  notif = data;
                });
              })
        ],
      ),
    );
  }
}

class ForApproval extends StatefulWidget {
  Relation rel;
  ForApproval({Key? key, required this.rel}) : super(key: key);

  @override
  State<ForApproval> createState() => _ForApprovalState();
}

class _ForApprovalState extends State<ForApproval> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("User id: ${widget.rel.from}"),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 56, 56, 56),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          Provider.of<UserViewModel>(context, listen: false)
                              .approved(widget.rel);
                        },
                        child: Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ))),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 56, 56, 56),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          Provider.of<UserViewModel>(context, listen: false)
                              .reject(widget.rel.relID as String, widget.rel);
                        },
                        child: Text(
                          "Reject",
                          style: TextStyle(color: Colors.white),
                        )))
              ],
            )
          ]),
    );
  }
}
