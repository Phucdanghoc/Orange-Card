class UserCurrent {
  final String username;
  final String avatar;
  List<String>? topicIds;
  final int? quiz_gold;
  final int? typing_gold;
  final int? quiz_point;
  final int? typing_point;
  UserCurrent({
    required this.username,
    required this.avatar,
    required this.topicIds,
    this.quiz_gold,
    this.typing_gold,
    this.quiz_point,
    this.typing_point,
  });

  factory UserCurrent.fromMap(Map<String, dynamic> map) => UserCurrent(
        username: map['displayName'],
        avatar: map['avatarUrl'],
        topicIds: List<String>.from(map['topicIds']),
        quiz_gold: map['quiz_gold'],
        typing_gold: map['typing_gold'],
        quiz_point: map['quiz_point'],
        typing_point: map['typing_point'],
      );

  Map<String, dynamic> toMap() => {
        'displayName': username,
        'avatarUrl': avatar,
        'topicIds': topicIds,
        'quiz_gold': quiz_gold,
        'typing_gold': typing_gold,
        'quiz_point': quiz_point,
        'typing_point': typing_point,
      };
}
