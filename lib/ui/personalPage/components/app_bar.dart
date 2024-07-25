import 'package:flutter/material.dart';
import 'package:orange_card/constants/constants.dart';

class PersionalPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PersionalPageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Persional'),
      backgroundColor: kPrimaryColor,
      titleTextStyle: TextStyle(
        // h5 -> headline
        fontFamily: "WorkSans",
        fontWeight: FontWeight.bold,
        fontSize: 20,
        letterSpacing: 0.30,
        color: Colors.white,
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
