import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/relation.dart';
import '../models/userData.dart';
import '../services/relationshipService.dart';
import '../services/userDataService.dart';

class UserViewModel extends ChangeNotifier {
  bool isLoading = false;
  String selected = "";
  String uid = "";
  List<UserData>? relatives = [];
  List<Relation>? forApproval = [];
  RelationShipService relatioNService = RelationShipService();
  UserDataService userDataService = UserDataService();

  void addRelative(UserData relative) {}

  void addRelativeClient() async {
    UserData userData = await userDataService
        .getUserDataByUIDWithoutErrorHandler(uid) as UserData;

    relatioNService.addRelation(userData.uid as String, selected);
  }

  void approved(Relation id) async {
    UserData userData = await userDataService
        .getUserDataByUIDWithoutErrorHandler(id.from) as UserData;

    relatioNService.approved(id.relID as String, id);
    relatives?.add(userData);
    forApproval!.remove(id);
    notifyListeners();
  }

  void removeRelative(UserData rel) {
    relatioNService.removeRelationship(rel.uid as String);
    relatives!.remove(rel);
    notifyListeners();
  }

  void reject(String id, Relation rel) {
    relatioNService.disapproved(id);
    forApproval!.remove(rel);
    notifyListeners();
  }
}
