import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/relation.dart';

class RelationShipService {
  void addRelation(String userID, String relation) {
    FirebaseFirestore.instance.collection('relationship').add(Relation(
            isApproved: false,
            relation: relation,
            userID: userID,
            notification: true,
            from: FirebaseAuth.instance.currentUser!.uid)
        .toMap());
  }

  void removeRelationship(String uid) {
    FirebaseFirestore.instance
        .collection('relationship')
        .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("from", isEqualTo: uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      }
    });

    FirebaseFirestore.instance
        .collection('relationship')
        .where("userID", isEqualTo: uid)
        .where("from", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      }
    });

    FirebaseFirestore.instance.collection('users').doc(uid).update({
      "relatives":
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "relatives": FieldValue.arrayRemove([uid])
    });
  }

  void approved(String relID, Relation relation) {
    FirebaseFirestore.instance
        .collection('relationship')
        .doc(relID)
        .update({"isApproved": true});

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "relatives": FieldValue.arrayUnion([relation.from])
    });
    FirebaseFirestore.instance.collection('relationship').add(Relation(
            isApproved: true,
            relation: relation.relation,
            userID: relation.from,
            notification: true,
            from: FirebaseAuth.instance.currentUser!.uid)
        .toMap());
    FirebaseFirestore.instance.collection('users').doc(relation.from).update({
      "relatives":
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  void disapproved(String relID) {
    FirebaseFirestore.instance.collection('relationship').doc(relID).delete();
  }

  void updateNotification(bool data, String id) {
    FirebaseFirestore.instance
        .collection('relationship')
        .doc(id)
        .update({"notifications": data});
  }

  Future<List<Relation>?> getMyPendingRelationship() async {
    var data = await FirebaseFirestore.instance
        .collection("relationship")
        .where("isApproved", isEqualTo: false)
        .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<Relation> dataTemp = [];
    print(data.docs.length);
    for (var element in data.docs) {
      Relation rel = Relation.fromMap(element.data() as Map<String, dynamic>);
      rel.relID = element.id;
      dataTemp.add(rel);
    }

    return dataTemp;
  }

  Future<Relation?> getMyRelationship(String uid) async {
    var data = await FirebaseFirestore.instance
        .collection("relationship")
        .where("isApproved", isEqualTo: true)
        .where("userID", isEqualTo: uid)
        .where("from", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (data.docs.firstOrNull == null) {
      return null;
    }
    Relation rel =
        Relation.fromMap(data.docs.firstOrNull?.data() as Map<String, dynamic>);
    rel.relID = data.docs.firstOrNull?.id;

    return rel;
  }

  Future<Relation?> getAllMyRelations() async {
    var data = await FirebaseFirestore.instance
        .collection("relationship")
        .where("from", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (data.docs.firstOrNull == null) {
      return null;
    }
    return Relation.fromMap(data.docs.firstOrNull as Map<String, dynamic>);
  }
}
