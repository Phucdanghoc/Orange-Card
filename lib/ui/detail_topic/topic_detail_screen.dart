import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/core/exception.dart';
import 'package:orange_card/resources/models/folder.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/models/topicRank.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/repositories/userRepository.dart';
import 'package:orange_card/resources/services/CSVService.dart';
import 'package:orange_card/resources/viewmodels/FolderViewModel.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';
import 'package:orange_card/ui/FlashCard/flashcard.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/ui/Quiz/game_quiz_setting_page.dart';
import 'package:orange_card/ui/Typing/game_typing_setting_page.dart';
import 'package:orange_card/ui/detail_topic/components/word_item.dart';
import 'package:orange_card/ui/libraryPage/folder/components/dialog_folder.dart';
import 'package:orange_card/ui/libraryPage/topic/screens/edit_topic.dart';
import 'package:orange_card/ui/message/sucess_message.dart';
import 'package:orange_card/ui/skelton/detailTopic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class TopicDetail extends StatefulWidget {
  final UserCurrent user;
  final Topic topic;
  final TopicViewModel topicViewModel;
  const TopicDetail({
    super.key,
    required this.topic,
    required this.user,
    required this.topicViewModel,
  });

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail> {
  // Future<void> setData() async {
  //   topicViewModel = Provider.of<TopicViewModel>(context);
  //   topicViewModel.loadDetailTopics(widget.topic.id!);
  // }
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _topicRanks = "topicRanks";
  // UserRepository _userRepository = new UserRepository();

  List<Map<String, dynamic>> users = [];
  // late UserCurrent? currentUser;
  bool haveUser = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getUser(widget.topic.id.toString());
    // this.currentUser = await _userRepository.getUserById(uid);
    setState(() {});
  }

  Future<void> getUser(String topicId) async {
    try {
      // Lấy tài liệu topicRank theo topicId
      DocumentReference topicDocRef = _db.collection(_topicRanks).doc(topicId);
      DocumentSnapshot topicDocSnapshot = await topicDocRef.get();

      if (topicDocSnapshot.exists) {
        TopicRank topicRank =
            TopicRank.fromMap(topicDocSnapshot.data() as Map<String, dynamic>);
        users = topicRank.users ?? [];
        setState(() {
          users.sort(
              (a, b) => (b['maxPoint'] ?? 0).compareTo(a['maxPoint'] ?? 0));
        });
      } else {
        setState(() {
          users = [];
        });
      }
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (this.currentUser == null) {
    //   return Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    final topicViewModel = Provider.of<TopicViewModel>(context);
    print(topicViewModel.isLoading);
    final userViewModel = UserViewModel();
    bool auth = userViewModel.checkCurrentUser(widget.topic.user);
    for (var user in users) {
      // logger.f(user["userId"]);
      // logger.f(this.uid);
      if (user["userId"].toString() == this.uid.toString()) {
        this.haveUser = true;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Topic Detail",
          style: AppTheme.title_appbar2,
        ),
        backgroundColor: kPrimaryColor,
        titleTextStyle: const TextStyle(color: Colors.white),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_outlined),
            onPressed: () {
              _showBottomSheet(context, topicViewModel, auth);
            },
          ),
        ],
      ),
      body: widget.topicViewModel.isLoading
          ? const DetailTopicSkeletonLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Card(
                    elevation: 5,
                    shadowColor: kPrimaryColorBlur,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(widget.user.avatar),
                              radius: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.topicViewModel.topic.title!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.user.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                users.isEmpty
                    ? Container(
                        height: 20,
                      )
                    : Container(
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 15, top: 15),
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user =
                                index < users.length || users.length != 0
                                    ? users[index]
                                    : null;

                            if (index != users.length && users.length != 0)
                              return Card(
                                elevation: 4,
                                color: kPrimaryColorBlur,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user!["avatar"]),
                                        radius: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${user["username"]}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 3,
                                      ),
                                      Text(
                                        'Top ${index + 1}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${user["maxPoint"]} points',
                                        style: AppTheme.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            // else if (!this.haveUser)
                            //   return Card(
                            //     margin: const EdgeInsets.only(left: 20),
                            //     elevation: 1,
                            //     color: AppTheme.chipBackground,
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Column(
                            //         children: [
                            //           CircleAvatar(
                            //             backgroundImage:
                            //                 NetworkImage(this.currentUser!.avatar),
                            //             radius: 30,
                            //           ),
                            //           const SizedBox(height: 5),
                            //           Text(
                            //             'YOU',
                            //             style: TextStyle(
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //             maxLines: 3,
                            //           ),
                            //           Text(
                            //             '${0} points',
                            //             style: AppTheme.caption,
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   );

                            else
                              return null;
                          },
                        ),
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FlashCard(
                                    topic: widget.topic,
                                    topicViewModel: topicViewModel,
                                    words: topicViewModel.words)),
                          );
                        },
                        child: const Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.analytics,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Flashcard",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          logger.d(widget.topic.numberOfChildren);
                          if (widget.topic.numberOfChildren! < 4) {
                            MessageUtils.showWarningMessage(context,
                                "Chủ đề này cần phải có 4 từ vựng mới tham gia Quiz ");
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameQuizSettingsPage(
                                      topicViewModel: topicViewModel,
                                      topic: widget.topic)),
                            );
                          }
                        },
                        child: const Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.purpleAccent,
                              child: Icon(
                                Icons.quiz,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Quiz",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameTypingSettingsPage(
                                      topic: widget.topic,
                                      topicViewModel: topicViewModel,
                                    )),
                          );
                        },
                        child: const Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blueAccent,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Typing",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                  child: const SizedBox(
                    child: Text(
                      "List of word ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.topicViewModel.words.length,
                          itemBuilder: (context, index) {
                            final word = widget.topicViewModel.words[index];
                            return WordItem(
                              Auth: auth,
                              word: word,
                              backgroundColor: index % 2 == 0
                                  ? const Color.fromARGB(197, 255, 213, 150)
                                  : const Color.fromARGB(255, 255, 239, 224),
                              TopicId: widget.topic.id!,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showBottomSheet(
      BuildContext context, TopicViewModel topicViewModel, bool auth) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildActionIconWithText(
                icon: Icons.save,
                text: 'Download',
                onPressed: () async {
                  String? filename = await CSVService().makeFile(context,
                      widget.topicViewModel.words, widget.topic.title!);
                  if (filename != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Download File Complete'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('File name : $filename'),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await OpenFile.open(filename);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Open File'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Exit'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    MessageUtils.showFailureMessage(
                        context, "Error Download file");
                  }
                },
              ),
              auth
                  ? _buildActionIconWithText(
                      icon: Icons.edit,
                      text: 'Edit',
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditTopic(
                                    topic: widget.topicViewModel.topic,
                                    words: widget.topicViewModel.words,
                                    topicViewModel: topicViewModel,
                                  )),
                        );
                        setState(() {});
                      },
                    )
                  : const SizedBox(),
              auth
                  ? _buildActionIconWithText(
                      icon: Icons.create_new_folder,
                      text: 'Add into Topic',
                      onPressed: () async {
                        final folderViewModel = Provider.of<FolderViewModel>(
                            context,
                            listen: false);
                        await showDialog<Folder>(
                          context: context,
                          builder: (_) => FolderDialog(
                            folders: folderViewModel.folders,
                            topicId: widget.topic.id!,
                            folderViewModel: folderViewModel,
                          ),
                        );
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionIconWithText({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            color: kPrimaryColor,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: kPrimaryColor),
          ),
        ],
      ),
    );
  }
}

class UserCard {
  final String avatarUrl;
  final int rank;
  UserCard({required this.avatarUrl, required this.rank});
}
