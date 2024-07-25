import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/viewmodels/FolderViewModel.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/ui/detail_topic/topic_detail_screen.dart';
import 'package:orange_card/ui/libraryPage/topic/components/card_item.dart';
import 'package:orange_card/ui/libraryPage/topic/screens/add_topic_screen.dart';
import 'package:orange_card/ui/skelton/topic.dart';
import 'package:provider/provider.dart';
import '../../../../resources/viewmodels/TopicViewmodel.dart';
import '../../../message/sucess_message.dart';
import '../components/dialog_edit_topic.dart';

class TopicScreen extends StatefulWidget {
  final TopicViewModel topicViewModel;

  const TopicScreen({super.key, required this.topicViewModel});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  late List<Topic> filteredTopics;

  @override
  void initState() {
    super.initState();
  }

  void _filterTopic(String query) async {
    widget.topicViewModel.searchTopic(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // filteredTopics = widget.topicViewModel.topics;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await setdata();
          setState(() {});
        },
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  iconColor: kPrimaryColor,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: kPrimaryColor)),
                ),
                onChanged: _filterTopic,
              ),
            ),
            Expanded(child: _buildTopicList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _navigateToAddTopicScreen(context);
          setState(() {});
          setdata();
        },
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTopicList() {
    Provider.of<TopicViewModel>(context, listen: true);
    return widget.topicViewModel.isLoading
        ? ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return TopicCardSkeleton();
            },
          )
        : widget.topicViewModel.topics.isEmpty
            ? const Center(child: Text('Chưa có chủ đề nào'))
            : ListView.builder(
                itemCount: widget.topicViewModel.topics.length,
                itemBuilder: (context, index) {
                  final topic = widget.topicViewModel.topics[index];
                  return GestureDetector(
                    onTap: () async {
                      await _navigateToTopicDetailScreen(context, topic);
                    },
                    child: TopicCardItem(
                      topic: topic,
                      onDelete: (topic) {
                        _showDeleteConfirmation(topic);
                      },
                    ),
                  );
                },
              );
  }

  Future<void> _navigateToAddTopicScreen(BuildContext context) async {
    await showDialog<List>(
      context: context,
      builder: (_) => const AddTopicScreen(),
    );
  }

  Future<void> _navigateToTopicDetailScreen(
      BuildContext context, Topic topic) async {
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

  void _showDeleteConfirmation(Topic topic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận Xóa"),
          content: const Text("Bạn có chắc muốn xóa chủ đề này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteTopic(topic);
                Navigator.pop(context);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTopic(Topic topic) async {
    widget.topicViewModel.deleteTopic(topic);
    FolderViewModel().removeTopicInFolder(topic);
    MessageUtils.showSuccessMessage(
      context,
      "Đã xóa thành công chủ đề ${topic.title}",
    );
  }

  Future<void> setdata() async {
    await widget.topicViewModel.loadTopics();
  }
}
