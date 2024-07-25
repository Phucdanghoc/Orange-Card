import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/ui/Quiz/quiz.dart';
import 'package:orange_card/widgets/gap.dart';

class GameQuizSettingsPage extends StatefulWidget {
  final TopicViewModel topicViewModel;
  final Topic topic;

  const GameQuizSettingsPage({
    Key? key,
    required this.topicViewModel,
    required this.topic,
  }) : super(key: key);

  @override
  State<GameQuizSettingsPage> createState() => _GameQuizSettingsPageState();
}

class _GameQuizSettingsPageState extends State<GameQuizSettingsPage> {
  late bool isAuto = false;
  late bool isEnglishQuestions = true;
  late bool isShuffleEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWordCount();
    });
  }

  void _checkWordCount() {
    if ((widget.topic.numberOfChildren!) < 4) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                // Cho phép quay lại màn hình trước khi ấn nút "Quit"
                return true;
              },
              child: AlertDialog(
                title: Text(
                  'Insufficient Words',
                  style: TextStyle(color: Colors.red),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The topic must have at least 4 words to start the quiz.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Đóng dialog
                          Navigator.pop(context); // Quay lại màn hình trước đó
                        },
                        child: Text('Quit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose your style'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Topic ${widget.topic.title}",
              style: TextStyle(
                // body2 -> body1
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w400,
                fontSize: 20,
                letterSpacing: -0.05,
                color: Colors.black,
              ),
            ),
            const Gap(height: 16),
            SwitchListTile(
              title: Text('Auto Mode'),
              subtitle: Text(
                  'Get a response as soon as you answer a word and automatically move on to the next question in 1 second.'),
              value: isAuto,
              onChanged: (value) {
                setState(() {
                  isAuto = value;
                });
              },
            ),
            const Gap(height: 16),
            ListTile(
              title: Text('Question Language'),
              subtitle: Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: isEnglishQuestions,
                    onChanged: (value) {
                      setState(() {
                        isEnglishQuestions = value as bool;
                      });
                    },
                  ),
                  Text('English'),
                  Radio(
                    value: false,
                    groupValue: isEnglishQuestions,
                    onChanged: (value) {
                      setState(() {
                        isEnglishQuestions = value as bool;
                      });
                    },
                  ),
                  Text('Vietnamese'),
                ],
              ),
            ),
            const Gap(height: 16),
            CheckboxListTile(
              title: Text('Shuffle Questions'),
              value: isShuffleEnabled,
              onChanged: (value) {
                setState(() {
                  isShuffleEnabled = value ?? false;
                });
              },
            ),
            const Gap(height: 16),
            ElevatedButton(
              onPressed: () {
                if ((widget.topic.numberOfChildren!) < 4) {
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return WillPopScope(
                          onWillPop: () async {
                            // Cho phép quay lại màn hình trước khi ấn nút "Quit"
                            return true;
                          },
                          child: AlertDialog(
                            title: Text(
                              'Insufficient Words',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The topic must have at least 4 words to start the quiz.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Đóng dialog
                                      Navigator.pop(
                                          context); // Quay lại màn hình trước đó
                                    },
                                    child: Text('Quit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
                } else {
                  // Lưu các tùy chọn vào biến settings
                  var settings = {
                    "autoEnabled": isAuto,
                    "englishQuestions": isEnglishQuestions,
                    "shuffleEnabled": isShuffleEnabled,
                  };

                  // Chuyển đến GameQuizPage và truyền settings
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameQuizPage(
                        settings: settings,
                        topicViewModel: widget.topicViewModel,
                        words: widget.topicViewModel.words,
                        topicId: widget.topic.id.toString()
                      ),
                    ),
                  );
                }
              },
              child: Text('Start Quiz'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}
