import 'package:flutter/material.dart';
import 'package:orange_card/ui/communityPage/components/app_bar.dart';
import 'package:orange_card/ui/communityPage/components/community_page.dart';

class CommunityPageScreen extends StatefulWidget {
  const CommunityPageScreen({super.key});

  @override
  _CommunityPageScreenState createState() => _CommunityPageScreenState();
}

class _CommunityPageScreenState extends State<CommunityPageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ();
    return Scaffold(
      appBar: const CommunityPageAppBar(),
      body: CommunityPage(),
    );
  }
}
