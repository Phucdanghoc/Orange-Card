import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/resources/repositories/userRepository.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';
import 'package:orange_card/ui/FlashCard/flashcard.dart';
import 'package:orange_card/ui/Quiz/game_quiz_setting_page.dart';
import 'package:orange_card/ui/Typing/game_typing_setting_page.dart';
import 'package:orange_card/ui/detail_topic/topic_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/repositories/topicRepository.dart';
import 'package:orange_card/resources/repositories/wordRepository.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  late TopicRepository _topicRepository = TopicRepository();
  late WordRepository _wordRepository = WordRepository();
  late UserRepository _userRepository = UserRepository();
  late ValueNotifier<Word?> word = ValueNotifier<Word?>(null);
  late Future<void> _initDataFuture;

  late List<Topic> topicByUser = [];
  late List<Topic> topicFromCommunity = [];
  late List<List<Word>> eveWord = [];
  late List<UserCurrent> listUser = [];

  @override
  void initState() {
    super.initState();
    this._initDataFuture = initializeData();
  }

  // Hàm để cập nhật từ mới
  Future<void> updateWord() async {
    this.word.value = getRandomEverydayWord(); // Lấy từ mới ngẫu nhiên
  }

  Future<void> initializeData() async {
    try {
      await getTopicByUser();
      await getTopicFromCommunity();
      await getWord();
      await updateWord();
      this.listUser = await _userRepository.getRankedUsers();
      // for (var user in this.listUser) {
      //   logger.f(user.username);
      //   logger.f(user.quiz_point);
      //   logger.f(user.typing_point);
      //   logger.f(user.quiz_gold);
      //   logger.f(user.typing_gold);
      // }
    } catch (e) {
      // Xử lý nếu có lỗi xảy ra
      print('Error initializing data: $e');
    }
  }

  Future<void> getTopicByUser() async {
    try {
      this.topicByUser = await _topicRepository
          .getAllTopicsByUserId(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  Future<void> getTopicFromCommunity() async {
    try {
      this.topicFromCommunity = await _topicRepository.getTopicsPublic();
      setState(() {}); // Trigger a rebuild after data is loaded
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  Future<void> getWord() async {
    List<List<Word>> allWords = [];
    try {
      for (var i = 0; i < this.topicByUser.length; i++) {
        List<Word> wordsInTopic =
            await _wordRepository.getAllWords(this.topicByUser[i].id!);
        allWords.add(wordsInTopic);
      }

      // Lọc ra id các chủ đề chưa có trong topicByUser
      List<String> topicIds = topicFromCommunity
          .where((topic) =>
              !topicByUser.any((existingTopic) => existingTopic.id == topic.id))
          .map((filteredTopic) => filteredTopic.id!)
          .toList();

      for (var id in topicIds) {
        List<Word> wordsInTopic = await _wordRepository.getAllWords(id);
        allWords.add(wordsInTopic);
      }

      this.eveWord = allWords;
    } catch (e) {
      print('Error getting words: $e');
    }
  }

  List<Topic> getRandomListTopic() {
    List<Topic> allListTopic = [];

    List<Topic> topicIds = topicFromCommunity
        .where((topic) =>
            !topicByUser.any((existingTopic) => existingTopic.id == topic.id))
        .toList();

    allListTopic.addAll(topicByUser);
    allListTopic.addAll(topicIds);
    allListTopic.shuffle();
    return allListTopic.length > 7 ? allListTopic.sublist(0, 7) : allListTopic;
  }

  Future<void> _navigateToRandomTopic(BuildContext context, int which) async {
    Topic topic = getRandomTopic();
    final TopicViewModel topicViewModel =
        Provider.of<TopicViewModel>(context, listen: false);

    topicViewModel.clearTopic();
    await topicViewModel.loadDetailTopics(topic.id!);

    if (which == 1) {
      //quiz
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GameQuizSettingsPage(
                  topic: topic,
                  topicViewModel: topicViewModel,
                )),
      );
    } else if (which == 2) {
      //typing
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GameTypingSettingsPage(
                  topicViewModel: topicViewModel,
                  topic: topic,
                )),
      );
    } else {
      //flashcard
      // logger.i(topicViewModel.topic.title);
      // logger.d(topicViewModel.isLoading);
      // logger.f("topic : ${topic.title}");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FlashCard(
                topic: topic,
                topicViewModel: topicViewModel,
                words: topicViewModel.words)),
      );
    }
  }

  Future<void> _navigateToTopicDetailScreen(
      BuildContext context, Topic topic, UserCurrent user) async {
    final TopicViewModel topicViewModel =
        Provider.of<TopicViewModel>(context, listen: false);
    final UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    UserCurrent? userCurrent =
        await userViewModel.getUserByDocumentReference(topic.user);
    topicViewModel.clearTopic();
    topicViewModel.loadDetailTopics(topic.id!);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetail(
            topic: topic, user: userCurrent!, topicViewModel: topicViewModel),
      ),
    );
  }

  Topic getRandomTopic() {
    List<Topic> allListTopic = [];

    List<Topic> topicIds = topicFromCommunity
        .where((topic) =>
            !topicByUser.any((existingTopic) => existingTopic.id == topic.id))
        .toList();

    allListTopic.addAll(this.topicByUser);
    allListTopic.addAll(topicIds);
    int indexRandom = Random().nextInt(allListTopic.length);

    return allListTopic[indexRandom];
  }

  Word getRandomEverydayWord() {
    int indexRandom = Random().nextInt(this.eveWord.length);
    List<Word> listWord = this.eveWord[indexRandom];
    indexRandom = Random().nextInt(listWord.length);
    return listWord[indexRandom];
  }

  Future<void> _refreshData(BuildContext context) async {

    // Set state để rebuild giao diện
      await initializeData();
    setState(() {
    });

    // Hoàn thành refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refresh completed!')),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () => _refreshData(context),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Study With Random Topic",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        listMenu(context),
                        const Text(
                          "Recommended For You",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        topics(),
                        const Text(
                          "Every Day A New Word",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: this.word,
                            builder: (context, value, _) {
                              return newWord(value!);
                            }),
                        const Text(
                          "Leaderboard",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            ranks(),
                            myRanks(),
                            const SizedBox(height: 20),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Container ranks() {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 350,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(20.0),
            //   border: Border.all(color: Colors.black, width: 2.0), // Đổi màu và độ dày viền tùy ý
            // ),
            child: ClipRRect(
              child: SvgPicture.asset(
                "./assets/icons/leaderboard_box.svg",
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Các widget sẽ căn giữa và đều nhau
            crossAxisAlignment:
                CrossAxisAlignment.start, // Canh chỉnh theo chiều dọc
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Canh chỉnh theo chiều dọc
                  children: [
                    const SizedBox(height: 30), // Điều chỉnh khoảng cách top
                    _buildAvatarCircle(listUser[1].username, listUser[1].avatar,
                        listUser[1].quiz_point! + listUser[1].typing_point!),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Canh chỉnh theo chiều dọc
                  children: [
                    _buildAvatarCircle(listUser[0].username, listUser[0].avatar,
                        listUser[0].quiz_point! + listUser[0].typing_point!),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Canh chỉnh theo chiều dọc
                  children: [
                    const SizedBox(height: 60), // Điều chỉnh khoảng cách top
                    _buildAvatarCircle(listUser[2].username, listUser[2].avatar,
                        listUser[2].quiz_point! + listUser[2].typing_point!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(String name, String imageUrl, int point) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40, // Đường kính hình tròn
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${point} point",
          style: AppTheme.caption,
        ),
      ],
    );
  }

  Widget myRanks() {
    // Bỏ qua 3 phần tử đầu và lấy 6 phần tử tiếp theo
    List<UserCurrent> topUsers = this.listUser.skip(3).take(6).toList();
    return ListView.builder(
      shrinkWrap: true, // Đảm bảo ListView không chiếm toàn bộ không gian
      physics: NeverScrollableScrollPhysics(), // Không cuộn bên trong ListView
      itemCount: topUsers.length,
      itemBuilder: (context, index) {
        UserCurrent user = topUsers[index];
        // logger.i(user.username);
        return Column(
          children: [
            _buildRankCard(user.username, user.avatar,
                (user.quiz_point ?? 0) + (user.typing_point ?? 0), index),
            const SizedBox(height: 10), // Khoảng cách giữa các card
          ],
        );
      },
    );
  }

  Widget _buildRankCard(String name, String imageUrl, int point, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.8), //
              Colors.greenAccent.withOpacity(1), // Start color
            ],
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar và Text name
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? ClipOval(
                        child: Image.asset(
                          "assets/images/default_avatar.jpg",
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8), // Khoảng cách giữa avatar và text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Canh chỉnh giữa nguyên
                  children: [
                    Text(
                      name.isEmpty ? "(No Name)" : name,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Khoảng cách giữa 2 Text widget
                    Text(
                      "${point} point",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  width: 8), // Khoảng cách giữa text và circle avatar
              // Circle Avatar với index+4 ở giữa theo chiều dọc
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue,
                child: Text(
                  "${index + 4}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container newWord(Word word) {
    String eng = word.english!;
    String vie = word.vietnamese;
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 15),
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 123, 123, 123),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ListTile(
                    onTap: () {},
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 251, 104, 64),
                      child: Icon(
                        Icons.edit_note,
                      ),
                    ),
                    title: Text(
                      eng,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(vie),
                  ),
                  Positioned(
                    top: 8,
                    bottom: 8,
                    right: 8,
                    width: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: ElevatedButton(
                        onPressed: () {
                          updateWord(); // Gọi hàm cập nhật từ mới khi nhấn nút "New Word"
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.kPrimaryColor, // Màu nền của nút
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Kích thước của Row phụ thuộc vào nội dung
                          children: [
                            Icon(Icons.refresh, size: 22), // Icon refresh
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container topics() {
    List<Topic> randomTopics = getRandomListTopic();
    late UserViewModel _userViewModel = UserViewModel();

    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 15),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: randomTopics.length,
        itemBuilder: (context, index) {
          Topic topic = randomTopics[index];
          return FutureBuilder<UserCurrent?>(
            future: _userViewModel.getUserByDocumentReference(topic.user),
            builder:
                (BuildContext context, AsyncSnapshot<UserCurrent?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Hiển thị indicator khi đang tải dữ liệu
              } else {
                UserCurrent? user = snapshot.data;
                return InkWell(
                  onTap: () async {
                    await _navigateToTopicDetailScreen(context, topic, user);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Container(
                        height: 80,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),

                          color: Colors.black.withOpacity(0.9),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.greenAccent.withOpacity(1), // Start color
                              Colors.blue.withOpacity(0.8), // End color
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Text(
                                topic.title!, // Hiển thị tên chủ đề
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${topic.numberOfChildren} words', // Số lượng từ trong chủ đề
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      user!.avatar != "" &&
                                              user.avatar.isNotEmpty
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(user.avatar),
                                              radius: 20,
                                            )
                                          : Icon(
                                              Icons.account_circle,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                      SizedBox(width: 10),
                                      Text(
                                        user.username, // Tên người tạo
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Container listMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 35, right: 35, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              _navigateToRandomTopic(context, 0);
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
              _navigateToRandomTopic(context, 1);
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
              _navigateToRandomTopic(context, 2);
            },
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
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
    );
  }
}
