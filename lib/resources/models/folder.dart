class Folder {
  String? id;
  final String title;
  final int time;
  final String userId;
  List<String> topicIds;

  Folder({
    this.id,
    required this.title,
    required this.time,
    required this.userId,
    required this.topicIds,
  });

  factory Folder.fromMap(Map<String, dynamic> map, String id) => Folder(
        id: id,
        title: map['title'] ?? '',
        time: map['time'] ?? '',
        userId: map['userId'] ?? '',
        topicIds: map['topicIds'] != null
            ? List<String>.from(map['topicIds'])
            : [], // Provide an empty list if topicIds is not present or null
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'time': time,
        'userId': userId,
        'topicIds': topicIds,
      };
}
