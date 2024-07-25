import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/repositories/userRepository.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';

class TopicCardCommunityItem extends StatefulWidget {
  final Topic topic;
  final Function(Topic)? onEdit;
  final Function(Topic)? onDelete;
  final bool like;
  final UserViewModel userViewModel;

  const TopicCardCommunityItem({
    super.key,
    required this.topic,
    this.onEdit,
    required this.like,
    this.onDelete,
    required this.userViewModel,
  });

  @override
  __TopicCardCommunityItemState createState() =>
      __TopicCardCommunityItemState();
}

class __TopicCardCommunityItemState extends State<TopicCardCommunityItem> {
  String? _avatarUrl;
  String? _username;
  bool? liked;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    liked = widget.like;
    print(liked);
  }

  Future<void> _fetchUserData() async {
    try {
      UserCurrent? user = await UserRepository().userFromDocumentReference(
          widget.topic.user as DocumentReference<Map<String, dynamic>>?);
      setState(() {
        _avatarUrl = user?.avatar;
        _username = user?.username;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        shadowColor: kPrimaryColorBlur,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      _avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(_avatarUrl!),
                              radius: 30,
                            )
                          : const CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://i.pinimg.com/236x/7f/e0/3e/7fe03e29bf34dca114b4c22f11513a5b.jpg"),
                              radius: 30,
                            ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.topic.title.toString(),
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '$_username',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'word : ${widget.topic.numberOfChildren.toString()}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (liked!) {
                    await widget.userViewModel.removeTopicId(widget.topic.id!);
                  } else {
                    await widget.userViewModel.addTopicId(widget.topic.id!);
                  }
                  setState(() {
                    liked = !liked!;
                  });
                },
                icon: liked!
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
