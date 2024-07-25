import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/ui/auth/Screens/Login/login_screen.dart';
import 'package:orange_card/ui/main/components/nav_bar.dart';
import 'package:orange_card/ui/communityPage/community_screen.dart';
import 'package:orange_card/ui/homePage/home_screen.dart';
import 'package:orange_card/ui/libraryPage/library_srceen.dart';
import 'package:orange_card/ui/personalPage/persional_srceen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    logger.d("sihjv8fuvbiosdfvb ${FirebaseAuth.instance.currentUser!.email}");
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBarWidget(
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomePageScreen();
      case 1:
        return const LibraryPageScreen();
      case 2:
        return const CommunityPageScreen();
      case 3:
        return const PersionalPageScreen();
      default:
        return const SizedBox(); // Return a default widget or an empty container
    }
  }
}
