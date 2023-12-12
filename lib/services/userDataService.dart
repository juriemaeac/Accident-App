import 'package:accidentapp/models/relation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/userData.dart';
import 'relationshipService.dart';

class UserDataService {
  Future<UserData?> getUserDataByUID(String? uid) async {
    var data =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (data.data() == null) {
      return null;
    }
    return UserData.fromMap(data.data() as Map<String, dynamic>);
  }

  Future<UserData?> getUserDataByUIDWithoutErrorHandler(String? uid) async {
    var data =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return UserData.fromMap(data.data() as Map<String, dynamic>);
  }

  Future<UserData?> getMyData() async {
    RelationShipService relService = RelationShipService();

    try {
      String? apnsToken = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"userToken": apnsToken});

      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      Map<String, dynamic>? userDataTemp = data.data();

      if (userDataTemp == null) {
        return null;
      }

      UserData userData = UserData.fromMap(userDataTemp);

      List<Relation>? list = await relService.getMyPendingRelationship();

      userData.forApproval = list;
      if (userDataTemp["relatives"] == null ||
          userDataTemp["relatives"] == "null") {
        return userData;
      }

      List<UserData> relatives = [];

      for (var element in (userDataTemp['relatives'] as List).map((e) {
        return e;
      }).toList()) {
        var relativeData = await FirebaseFirestore.instance
            .collection('users')
            .doc(element)
            .get();
        if (relativeData.data() != null) {
          UserData rel =
              UserData.fromMap(relativeData.data() as Map<String, dynamic>);
          rel.uid = element;
          relatives.add(rel);
        }
      }

      userData.relatives = relatives;

      return userData;
    } catch (e) {
      print(e);
    }
  }
}
