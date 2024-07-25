import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/services/TTSService.dart';
import 'package:orange_card/resources/viewmodels/WordViewModel.dart';

class WordItem extends StatefulWidget {
  final Word word;
  final bool Auth;
  final Color backgroundColor;
  final String TopicId;
  const WordItem({
    Key? key,
    required this.word,
    required this.backgroundColor,
    required this.Auth,
    required this.TopicId,
  });

  @override
  State<WordItem> createState() => _WordItemState();
}

class _WordItemState extends State<WordItem> {
  final TTSService textToSpeechService = TTSService();
  late bool marked = false;

  @override
  void initState() {
    marked = WordViewModel().checkMarked(widget.word.userMarked);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 4,
        shadowColor: widget.backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: widget.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Text(widget.word.english.toString())),
                Expanded(child: Text(widget.word.vietnamese)),
              ],
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      bool isMarked =
                          WordViewModel().checkMarked(widget.word.userMarked);
                      if (isMarked) {
                        await WordViewModel().markWord(
                          widget.TopicId,
                          widget.word,
                          false, // Unmark the word
                        );
                        widget.word.userMarked
                            .remove(FirebaseAuth.instance.currentUser!.uid);
                      } else {
                        await WordViewModel().markWord(
                          widget.TopicId,
                          widget.word,
                          true, // Mark the word
                        );
                        widget.word.userMarked
                            .add(FirebaseAuth.instance.currentUser!.uid);
                      }
                      setState(() {
                        marked = !marked;
                      });
                    },
                    icon: Icon(
                      marked ? Icons.star : Icons.star_border,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      await textToSpeechService.speak(widget.word.english!);
                    },
                    icon: const Icon(Icons.volume_down),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
