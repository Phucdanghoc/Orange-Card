class TopicRank {
  List<Map<String, dynamic>>? users;

  TopicRank({
    this.users,
  });

  factory TopicRank.fromMap(Map<String, dynamic> map) {
    return TopicRank(
      users: List<Map<String, dynamic>>.from(map['users'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'users': users ?? [],
    };
  }
}
