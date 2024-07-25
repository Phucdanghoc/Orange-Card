import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';
import 'package:orange_card/ui/communityPage/components/card_community_item.dart';
import 'package:orange_card/ui/detail_topic/topic_detail_screen.dart';
import 'package:orange_card/ui/skelton/topic.dart';
import 'package:provider/provider.dart';

class Orthers extends StatefulWidget {
  const Orthers(
      {super.key, required this.topicViewModel, required this.userViewModel});
  final TopicViewModel topicViewModel;
  final UserViewModel userViewModel;
  @override
  State<Orthers> createState() => _OrthersState();
}

class _OrthersState extends State<Orthers> {
  @override
  void initState() {
    super.initState();
  }

  void _filterTopic(String query) {
    widget.topicViewModel.searchTopicPublics(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TopicViewModel>(context, listen: true);
    Provider.of<UserViewModel>(context, listen: true);
    return Container(
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search...',
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterTopic,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await setdata();
              },
              child: widget.topicViewModel.isLoading
                  ? ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return TopicCardSkeleton();
                      },
                    )
                  : ListView.builder(
                      itemCount: widget.topicViewModel.topicsPublic.length,
                      itemBuilder: (context, index) {
                        final topic = widget.topicViewModel.topicsPublic[index];
                        return GestureDetector(
                          onTap: () async {
                            await _navigateToTopicDetailScreen(context, topic);
                          },
                          child: TopicCardCommunityItem(
                            topic: topic,
                            userViewModel: widget.userViewModel,
                            like: widget.userViewModel.userCurrent!.topicIds!
                                .contains(topic.id),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToTopicDetailScreen(
      BuildContext context, Topic topic) async {
    final TopicViewModel topicViewModel =
        Provider.of<TopicViewModel>(context, listen: false);
    final UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    UserCurrent? owner =
        await userViewModel.getUserByDocumentReference(topic.user);
    topicViewModel.clearTopic();
    topicViewModel.loadDetailTopics(topic.id!);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetail(
            topic: topic, user: owner!, topicViewModel: topicViewModel),
      ),
    );
  }

  Future<void> setdata() async {
    await widget.topicViewModel.loadTopicsPublic();
  }
}
