import 'package:enum_to_string/enum_to_string.dart';
import 'package:orange_card/resources/utils/enum.dart';

class Word {
  String? id;
  String? english;
  String vietnamese;
  int createdAt;
  int updatedAt;
  String? imageUrl;
  STATUS learnt;
  STATUS? marked;
  List<String> userMarked;

  Word({
    this.id,
    this.english,
    required this.vietnamese,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    required this.learnt,
    required this.userMarked,
    required this.marked,
  });

  factory Word.fromMap(Map<String, dynamic> map, String id) => Word(
        id: id,
        english: map['english'],
        vietnamese: map['vietnamese'],
        createdAt: map['createdAt'],
        updatedAt: map['updatedAt'],
        imageUrl: map['imageUrl'],
        learnt: EnumToString.fromString(STATUS.values, map['learnt']) ??
            STATUS.NOT_LEARN,
        marked: EnumToString.fromString(STATUS.values, map['marked']),
        userMarked: List<String>.from(map['userMarked']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'english': english,
        'vietnamese': vietnamese,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'imageUrl': imageUrl,
        'learnt': EnumToString.convertToString(learnt),
        'marked': EnumToString.convertToString(marked),
        'userMarked': userMarked,
      };

  Word copyWith({
    String? id,
    String? english,
    String? vietnamese,
    int? createdAt,
    int? updatedAt,
    String? imageUrl,
    STATUS? learnt,
    STATUS? marked,
    List<String>? userMarked,
  }) =>
      Word(
        id: id ?? this.id,
        english: english ?? this.english,
        vietnamese: vietnamese ?? this.vietnamese,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        imageUrl: imageUrl ?? this.imageUrl,
        learnt: learnt ?? this.learnt,
        marked: marked ?? this.marked,
        userMarked: userMarked ?? this.userMarked,
      );
}
