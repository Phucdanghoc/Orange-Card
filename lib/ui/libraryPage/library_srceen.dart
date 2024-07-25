import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/resources/viewmodels/FolderViewModel.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/ui/libraryPage/components/app_bar.dart';
import 'package:orange_card/ui/libraryPage/folder/srceens/folder_screen.dart';
import 'package:orange_card/ui/libraryPage/topic/screens/topic_screen.dart';
import 'package:provider/provider.dart';

class LibraryPageScreen extends StatefulWidget {
  const LibraryPageScreen({Key? key});

  @override
  _LibraryPageScreenState createState() => _LibraryPageScreenState();
}

class _LibraryPageScreenState extends State<LibraryPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _listTab = [
    const Tab(
      text: 'Topics',
    ),
    const Tab(
      text: 'Folders',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<TopicViewModel>(context, listen: false);
    Provider.of<FolderViewModel>(context, listen: false);
    _tabController =
        TabController(length: _listTab.length, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    final topicViewModel = Provider.of<TopicViewModel>(context);
    final folderViewModel = Provider.of<FolderViewModel>(context);
    return Scaffold(
      appBar: const LibraryPageAppBar(),
      body: Container(
        color: Colors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                tabs: _listTab,
                controller: _tabController,
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
                onTap: (index) {
                  setState(() {
                    _tabController.index = index;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TopicScreen(
                    key: null,
                    topicViewModel: topicViewModel,
                  ),
                  FolderScreen(key: null, folderViewModel: folderViewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
