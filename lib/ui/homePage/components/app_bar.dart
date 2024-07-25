import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('HomePage'),
      backgroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: AppTheme.title_appbar,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
