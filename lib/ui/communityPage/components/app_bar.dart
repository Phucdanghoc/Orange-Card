import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';

class CommunityPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CommunityPageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Community'),
      backgroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: AppTheme.title_appbar,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
