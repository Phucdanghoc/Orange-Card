import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:orange_card/constants/constants.dart';

class NavBarWidget extends StatefulWidget {
  final ValueChanged<int> onIndexChanged; // Define the onTabChange callback

  const NavBarWidget({Key? key, required this.onIndexChanged}) : super(key: key);

  @override
  _NavBarWidgetState createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: GNav(
            hoverColor: Colors.grey[700]!,
            haptic: true,
            tabBorderRadius: 15,
            tabActiveBorder: Border.all(
              color: Colors.white,
              width: 1,
            ),
            tabBorder: Border.all(
              color: Colors.white,
              width: 1,
            ),
            
            // curve: Curves.easeOutExpo,
            duration: const Duration(milliseconds: 200),
            gap: 8,
            color: Colors.white,
            activeColor: Colors.white,
            iconSize: 23,
            tabBackgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.library_books,
                text: 'Library',
              ),
              GButton(
                icon: Icons.public,
                text: 'Community',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              )
            ],
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
              widget.onIndexChanged(index); // Call the onTabChange callback
            },
          ),
        ),
      ),
    );
  }
}
