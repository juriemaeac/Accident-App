import 'package:accidentapp/services/userDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/transaction.dart' as client;
import '../models/userData.dart';

class TransactionService {
  UserDataService userDataService = UserDataService();

  Future<AggregateQuerySnapshot> getAccidentsCount(
      List<String?> relativesID) async {
    return await FirebaseFirestore.instance
        .collection('transactions')
        .where("userID",
            whereIn: relativesID == null || relativesID.isEmpty
                ? [FirebaseAuth.instance.currentUser!.uid]
                : [...relativesID, FirebaseAuth.instance.currentUser!.uid])
        .where('IsFalseAlarm', isEqualTo: false)
        .count()
        .get();
  }

  Future<void> falseAlarmed(client.Transaction trans) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(trans.transID)
        .update({'IsFalseAlarm': true});
  }

  Future<List<client.Transaction>?> getMyRelativeTransactions(
      List<String?> relatives) async {
    var data = await FirebaseFirestore.instance
        .collection("transactions")
        .where('userID',
            whereIn: relatives == null || relatives.isEmpty
                ? [FirebaseAuth.instance.currentUser!.uid]
                : [...relatives, FirebaseAuth.instance.currentUser!.uid])
        .limit(10)
        .get();

    if (data.docs.length == 0) {
      return null;
    }

    List<client.Transaction> trans = [];
    for (var element in data.docs) {
      client.Transaction transTemp = client.Transaction.fromMap(element.data());
      transTemp.transID = element.id;
      transTemp.userData = await userDataService
          .getUserDataByUIDWithoutErrorHandler(element.data()['userID']);
      trans.add(transTemp);
    }
    return trans;
  }
}
