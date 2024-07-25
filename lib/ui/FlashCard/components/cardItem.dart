import 'package:flutter/material.dart';
import 'package:orange_card/constants/constants.dart';

class CardItem extends StatelessWidget {
  final String text;
  final bool isStartSelected;
  final VoidCallback onTapSpeak;
  final VoidCallback onTapStar;
  final Color color;

  const CardItem({
    super.key,
    required this.text,
    required this.isStartSelected,
    required this.onTapSpeak,
    required this.onTapStar,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: color,
      shadowColor: color == Colors.white ? kPrimaryColor : color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: color == Colors.white ? kPrimaryColor : color,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onTapSpeak,
              child: Icon(
                Icons.volume_up,
                color: color == Colors.white ? Colors.blue : color,
                size: 30,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: onTapStar,
              child: Icon(
                isStartSelected ? Icons.star : Icons.star_border,
                color: color == Colors.white ? Colors.yellow : color,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
