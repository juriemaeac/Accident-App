import 'dart:convert';

import 'package:accidentapp/models/userData.dart';
import 'package:flutter/foundation.dart';

class Transaction {
  String? transID;
  final DateTime dateHappened;
  final List<double> location;
  bool? isFalseAlarm;
  UserData? userData;

  Transaction(
      {this.transID,
      required this.dateHappened,
      required this.location,
      this.userData,
      this.isFalseAlarm});

  Transaction copyWith({
    DateTime? dateHappened,
    List<double>? location,
    UserData? userData,
  }) {
    return Transaction(
      dateHappened: dateHappened ?? this.dateHappened,
      location: location ?? this.location,
      userData: userData ?? this.userData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateHappened': dateHappened,
      'location': location,
      'userData': userData,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    var location = map['location'];

    if (map['IsFalseAlarm'] != null) {
      return Transaction(
          dateHappened: map['dateHappened'].toDate(),
          location: [location.latitude, location.longitude],
          userData:
              map['userData'] == null ? null : map['userData'] as UserData,
          isFalseAlarm: map['IsFalseAlarm']);
    }
    return Transaction(
      dateHappened: map['dateHappened'].toDate(),
      location: [location.latitude, location.longitude],
      userData: map['userData'] == null ? null : map['userData'] as UserData,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Transactions(dateHappened: $dateHappened, location: $location, userData: $userData)';

  @override
  bool operator ==(covariant Transaction other) {
    if (identical(this, other)) return true;

    return other.dateHappened == dateHappened &&
        listEquals(other.location, location) &&
        other.userData == userData;
  }

  @override
  int get hashCode =>
      dateHappened.hashCode ^ location.hashCode ^ userData.hashCode;
}
