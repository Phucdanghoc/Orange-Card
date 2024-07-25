import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/constants/constants.dart';

class LibraryTabBar extends StatefulWidget {
  const LibraryTabBar({required Key key}) : super(key: key);

  @override
  State<LibraryTabBar> createState() => _TabBarState();
}

class _TabBarState extends State<LibraryTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue, // Set the background color here
      child: const TabBar(
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 4,
        tabs: [
          Tab(
            text: 'Folders',
          ),
          Tab(
            text: 'Topics',
          ),
        ],
        labelColor: Colors.white,
        labelStyle: AppTheme.title_tabbar,
        unselectedLabelColor: Colors.grey,
        indicatorColor: kPrimaryColor,
      ),
    );
  }
}
