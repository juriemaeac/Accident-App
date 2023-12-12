import 'dart:convert';

class Relation {
  String? relID;
  final String relation;
  final String userID;
  final String from;
  bool? notification;
  bool? isApproved;
  Relation(
      {this.relID,
      this.isApproved,
      required this.relation,
      required this.userID,
      this.notification,
      required this.from});

  Relation copyWith({String? relation, String? userID, String? relID}) {
    return Relation(
      relID: relID ?? this.relID,
      from: from ?? this.from,
      relation: relation ?? this.relation,
      userID: userID ?? this.userID,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isApproved': isApproved,
      'notifications': notification,
      'relation': relation,
      'userID': userID,
      'from': from
    };
  }

  factory Relation.fromMap(Map<String, dynamic> map) {
    return Relation(
        notification: map['notifications'] as bool,
        relation: map['relation'] as String,
        userID: map['userID'] as String,
        from: map['from'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Relation.fromJson(String source) =>
      Relation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Relation(relation: $relation, userID: $userID)';

  @override
  bool operator ==(covariant Relation other) {
    if (identical(this, other)) return true;

    return other.relation == relation && other.userID == userID;
  }

  @override
  int get hashCode => relation.hashCode ^ userID.hashCode;
}
