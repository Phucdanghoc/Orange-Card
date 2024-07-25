class UserInTopic {
  int? lastUse;
  String? id;
  int? score;
  int? time;

  UserInTopic({
    this.lastUse,
    this.id,
    this.score,
    this.time,
  });

  UserInTopic copyWith({
    int? lastUse,
    String? id,
    int? score,
    int? time,
  }) {
    return UserInTopic(
      lastUse: lastUse ?? this.lastUse,
      id: id ?? this.id,
      score: score ?? this.score,
      time: time ?? this.time,
    );
  }

  factory UserInTopic.fromMap(Map<String, dynamic> map, String id) {
    return UserInTopic(
      lastUse: map['lastUse'],
      id: id,
      score: map['score'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastUse': lastUse,
      'id': id,
      'score': score,
      'time': time,
    };
  }
}
