import 'package:flutter/material.dart';
import 'package:orange_card/ui/personalPage/components/app_bar.dart';
import 'package:orange_card/ui/personalPage/components/profile.dart';

class PersionalPageScreen extends StatelessWidget {
  const PersionalPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersionalPageAppBar(),
      body: ProfileScreen(),
    );
  }
}
