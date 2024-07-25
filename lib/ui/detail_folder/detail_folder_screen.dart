import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/resources/models/folder.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/viewmodels/FolderViewModel.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';
import 'package:orange_card/ui/detail_folder/topicitem.dart';
import 'package:orange_card/ui/detail_topic/topic_detail_screen.dart';
import 'package:orange_card/ui/message/sucess_message.dart';
import 'package:orange_card/ui/skelton/topic.dart';
import 'package:provider/provider.dart';
import '../../../../resources/viewmodels/TopicViewmodel.dart';

class DetailFolder extends StatefulWidget {
  final Folder folder;
  final FolderViewModel folderViewModel;

  const DetailFolder(
      {super.key, required this.folderViewModel, required this.folder});

  @override
  State<DetailFolder> createState() => _DetailFolderState();
}

class _DetailFolderState extends State<DetailFolder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thư mục : ${widget.folder.title}"),
        titleTextStyle: AppTheme.title_appbar,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await setdata();
        },
        child: _buildTopicList(),
      ),
    );
  }

  Widget _buildTopicList() {
    final folderViewMolde = Provider.of<FolderViewModel>(context);
    return folderViewMolde.isLoading
        ? ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return TopicCardSkeleton();
            },
          )
        : folderViewMolde.topics.isEmpty
            ? const Center(child: Text('Chưa có chủ đề nào'))
            : ListView.builder(
                itemCount: widget.folderViewModel.topics.length,
                itemBuilder: (context, index) {
                  final topic = widget.folderViewModel.topics[index];
                  return GestureDetector(
                    onTap: () async {
                      final currentUser = UserCurrent(
                        username:
                            FirebaseAuth.instance.currentUser!.email.toString(),
                        avatar: "",
                        topicIds: [],
                      );
                      await _navigateToTopicDetailScreen(
                          context, topic, currentUser);
                    },
                    child: TopicItemInFolder(
                      topic: topic,
                      onRemove: (topic) async {
                        await widget.folderViewModel.removeTopicInFolder(topic);
                        MessageUtils.showSuccessMessage(
                            context, "Topic is removed");
                      },
                    ),
                  );
                },
              );
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

  Future<void> setdata() async {
    await widget.folderViewModel.getTopicInModel(widget.folder.topicIds);
  }
}
