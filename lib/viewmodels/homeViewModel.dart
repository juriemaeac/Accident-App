import 'package:accidentapp/services/userDataService.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/transaction.dart';
import '../models/userData.dart';
import '../services/transactionService.dart';
import 'package:http/http.dart' as http;

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<Transaction> allActivities = [];
  TransactionService transactionService = TransactionService();
  UserDataService userDataService = UserDataService();
  int accidentCount = 0;
  void setup(UserData currentUser) async {
    List<String?> myRelatives = [];
    if (!currentUser.relatives!.isEmpty) {
      myRelatives = currentUser.relatives!.map((e) {
        return e.uid;
      }).toList();
    }

    var data = await transactionService.getMyRelativeTransactions(myRelatives);
    if (data == null) {
      return;
    }

    allActivities = data as List<Transaction>;
    transactionService.getAccidentsCount(myRelatives).then((value) {
      accidentCount = value.count;
      notifyListeners();
    });
    notifyListeners();
  }

  void taggedAsFalseAlarm(Transaction trans) async {
    Transaction? _trans =
        allActivities.firstWhereOrNull((element) => element == trans);
    if (_trans != null) {
      await transactionService.falseAlarmed(trans);

      _trans.isFalseAlarm = true;
      accidentCount -= 1;
      notifyListeners();
    }
  }

  void getAccidentsCount(List<UserData> relatives) async {
    List<String?> relativesID = relatives.map((d) => d.uid).toList();
    await transactionService
        .getAccidentsCount(relativesID as List<String>)
        .then((value) {
      accidentCount = value.count;
      notifyListeners();
    });
  }

  void addActivity(Transaction trans) {
    Transaction? transTemp =
        allActivities.firstWhereOrNull((e) => e.transID == trans.transID);
    if (transTemp != null) {
      return;
    }
    accidentCount++;
    allActivities = [trans, ...?allActivities];
    notifyListeners();
  }
}
