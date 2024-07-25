import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/utils/enum.dart';

class BottomSheetContent extends StatefulWidget {
  final List<Word> words;
  final Function(List<Word>) onFilter;
  final Function(bool) onAuto;
  final Function(List<Word>) onRandom;
  final bool isAuto;

  const BottomSheetContent({
    super.key,
    required this.words,
    required this.onAuto,
    required this.onRandom,
    required this.onFilter,
    required this.isAuto,
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  List<Word> currentWords = [];
  bool isAuto = false;
  @override
  void initState() {
    currentWords = widget.words;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              widget.onAuto(!widget.isAuto);
              setState(() {
                isAuto = !isAuto;
              });
              Navigator.pop(context);
            },
            icon: widget.isAuto ? Icon(Icons.pause) : Icon(Icons.play_arrow),
            label: widget.isAuto ? Text('Pause') : Text('Play'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              currentWords.shuffle(Random());
              widget.onRandom(currentWords);
              // Call the function to start auto advance timer
            },
            icon: const Icon(Icons.tap_and_play_rounded),
            label: const Text('Ramdom'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Filter'),
            trailing: DropdownButton<String>(
              value: 'ALL', // Default value
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    switch (value) {
                      case 'ALL':
                        currentWords = widget.words;
                        break;
                      case 'MARKED':
                        currentWords = widget.words
                            .where((word) => word.userMarked.contains(
                                FirebaseAuth.instance.currentUser!.uid))
                            .toList();
                        break;
                      case 'NOT_MARKED':
                        currentWords = widget.words
                            .where((word) => !word.userMarked.contains(
                                FirebaseAuth.instance.currentUser!.uid))
                            .toList();
                        break;
                      default:
                        break;
                    }
                  });
                  widget.onFilter(currentWords);
                  print(currentWords.length);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'ALL',
                  child: Text('Tất cả'),
                ),
                DropdownMenuItem(
                  value: 'MARKED',
                  child: Text('Đã đánh dấu'),
                ),
                DropdownMenuItem(
                  value: 'NOT_MARKED',
                  child: Text('Chưa đánh dấu'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
