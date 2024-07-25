import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/resources/viewmodels/UserViewModel.dart';
import 'package:orange_card/ui/communityPage/components/mybag.dart';
import 'package:orange_card/ui/communityPage/components/orthers.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicViewModel = Provider.of<TopicViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.getUserById();
    topicViewModel.loadTopicsPublic();
    topicViewModel.loadTopicsSaved();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Others'),
                  Tab(text: 'Your Bag'),
                ],
                indicatorWeight: 4,
                labelColor: Colors.white,
                labelStyle: AppTheme.title_tabbar,
                unselectedLabelColor: kPrimaryColor,
                indicatorColor: kPrimaryColor,
                indicator: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorPadding: const EdgeInsets.only(left: 20, right: 20),
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 5, top: 5),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    Orthers(
                        topicViewModel: topicViewModel,
                        userViewModel: userViewModel),
                    MyBags(
                        topicViewModel: topicViewModel,
                        userViewModel: userViewModel)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
