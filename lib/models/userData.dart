import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'relation.dart';

class UserData {
  String? uid;
  final int accidentsInvolvement;
  final List<double>? lastknownLocation;
  final String nickname;
  List<UserData>? relatives;
  List<Relation>? forApproval;
  final bool notifications;
  String? contactNumber;
  String? userType;
  String userAvatar;
  String? relationship;
  String? userToken;
  UserData(
      {required this.uid,
      required this.accidentsInvolvement,
      required this.lastknownLocation,
      required this.nickname,
      this.userToken,
      this.userType,
      this.relatives,
      this.contactNumber,
      this.relationship,
      required this.userAvatar,
      required this.notifications});

  UserData copyWith(
      {String? uid,
      int? accidentsInvolvement,
      List<double>? lastknownLocation,
      String? nickname,
      List<UserData>? relatives,
      bool? notifications}) {
    return UserData(
        uid: uid ?? this.uid,
        userAvatar: userAvatar ?? this.userAvatar,
        accidentsInvolvement: accidentsInvolvement ?? this.accidentsInvolvement,
        lastknownLocation: lastknownLocation ?? this.lastknownLocation,
        nickname: nickname ?? this.nickname,
        relatives: relatives ?? this.relatives,
        notifications: notifications ?? this.notifications);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'accidentsInvolvement': accidentsInvolvement,
      'lastknownLocation': lastknownLocation,
      'nickname': nickname,
      'relatives': relatives,
      'contactNumber': contactNumber,
      'userType': userType,
      'notifications': notifications,
      'userAvatar': userAvatar,
      'userToken': userToken
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    var location = map['lastknownLocation'];

    return UserData(
        uid: map['uid'] ?? null,
        accidentsInvolvement: map['accidentsInvolvement'].toInt() as int ?? 0,
        lastknownLocation:
            location != null ? [location.latitude, location.longitude] : null,
        nickname: map['nickname'] as String ?? "",
        relatives: null,
        contactNumber: map['contactNumber'] as String ?? "",
        userType: map['userType'] ?? "",
        userAvatar: map['userAvatar'] ?? "",
        userToken: map['userToken'] ?? "",
        notifications: map['notifications'] == null
            ? false
            : map['notifications'] as bool);
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserData(accidentsInvolvement: $accidentsInvolvement, lastknownLocation: $lastknownLocation, nickname: $nickname, relatives: $relatives)';
  }

  @override
  bool operator ==(covariant UserData other) {
    if (identical(this, other)) return true;

    return other.accidentsInvolvement == accidentsInvolvement &&
        listEquals(other.lastknownLocation, lastknownLocation) &&
        other.nickname == nickname &&
        listEquals(other.relatives, relatives);
  }

  @override
  int get hashCode {
    return accidentsInvolvement.hashCode ^
        lastknownLocation.hashCode ^
        nickname.hashCode ^
        relatives.hashCode;
  }
}
