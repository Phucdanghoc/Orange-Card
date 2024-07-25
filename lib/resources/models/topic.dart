import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:orange_card/resources/utils/enum.dart';

class Topic {
  String? id;
  String? title;
  int? creationTime;
  int? numberOfChildren;
  int? learnedWords;
  STATUS? status;
  int? updateTime;
  DocumentReference? user;
  int? views;

  Topic({
    this.id,
    this.title,
    this.creationTime,
    this.numberOfChildren,
    this.learnedWords,
    this.status,
    this.updateTime,
    this.user,
    this.views,
  });

  factory Topic.fromMap(Map<String, dynamic> map, String id) {
    return Topic(
      id: id,
      title: map['title'] ?? '',
      creationTime: map['creationTime'] ?? 0,
      numberOfChildren: map['numberOfChildren'] ?? 0,
      learnedWords: map['learnedWords'] ?? 0,
      status: map['status'] != null
          ? EnumToString.fromString(STATUS.values, map['status'])
          : null,
      updateTime: map['updateTime'] ?? 0,
      user: map['user'] as DocumentReference?,
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title ?? '',
      'creationTime': creationTime ?? 0,
      'numberOfChildren': numberOfChildren ?? 0,
      'learnedWords': learnedWords ?? 0,
      'status': status != null ? EnumToString.convertToString(status) : null,
      'updateTime': updateTime ?? 0,
      'user': user,
      'views': views ?? 0,
    };
  }
}
