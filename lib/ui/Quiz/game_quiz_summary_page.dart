import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
import 'package:orange_card/resources/models/QuizEntity.dart';
import 'package:orange_card/widgets/app_bar.dart';
import 'package:orange_card/widgets/gap.dart';
import 'package:orange_card/widgets/pushable_button.dart';
import 'package:orange_card/widgets/select_option_tile.dart';
import 'package:orange_card/widgets/status_bar.dart';
import 'package:orange_card/widgets/text.dart';

class GameQuizSummeryPage extends StatelessWidget {
  GameQuizSummeryPage({super.key, required this.quizs});

  final List<QuizEntity> quizs;
  final ValueNotifier<int> currentQuestion = ValueNotifier(0);

  void _onNextQuiz(BuildContext context, int current) {
    if (current < quizs.length - 1) {
      currentQuestion.value++;
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusBar(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder(
                  valueListenable: currentQuestion,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: (value + 1) / quizs.length,
                      color: Colors.green,
                      backgroundColor: Colors.grey.withOpacity(.15),
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 12,
                    );
                  },
                ),
                const Gap(height: 20),
                _buildCardQuestionAnswer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardQuestionAnswer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.lightText,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ValueListenableBuilder(
        valueListenable: currentQuestion,
        builder: (context, current, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Result",
                    style: TextStyle(
                      // Caption -> caption
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      letterSpacing: 0.2,
                      color:
                          Color.fromARGB(255, 255, 255, 255), // was lightText
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (quizs[current].meaning.toLowerCase() ==
                                  quizs[current].selectedAnswer.toLowerCase()
                              ? Colors.green
                              : Colors.redAccent)
                          .withOpacity(.75),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      quizs[current].meaning.toLowerCase() ==
                              quizs[current].selectedAnswer.toLowerCase()
                          ? "Correct"
                          : "Incorrect",
                      style: TextStyle(
                        // body2 -> body1
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        letterSpacing: -0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(height: 10),
              TextCustom(
                "${quizs[current].question}.",
                textAlign: TextAlign.justify,
                maxLines: 10,
              ),
              const Gap(height: 15),
              Column(
                children: quizs[current]
                    .answers
                    .mapIndexed((index, e) => SelectOptionTileWidget(
                          onTap: () {},
                          isSelected: quizs[current].selectedAnswer == e ||
                              quizs[current].meaning == e,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.27,
                            color: Colors.white,
                          ),
                          text: e.toLowerCase(),
                          color: quizs[current].meaning == e
                              ? Colors.green
                              : quizs[current].selectedAnswer == e
                                  ? Colors.redAccent
                                  : Color.fromARGB(255, 213, 213, 213)
                                      .withOpacity(.3),
                        ))
                    .toList(),
              ),
              const Gap(height: 15),
              _buildButtons(context, current),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context, int current) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: current == 0
                ? const SizedBox()
                : TextButton(
                    onPressed: () {
                      currentQuestion.value--;
                    },
                    child: Text(
                      "Back",
                      style: TextStyle(
                        // h5 -> headline
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.30,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: PushableButton(
              onPressed: () => _onNextQuiz(context, current),
              width: MediaQuery.of(context).size.width / 3,
              text: current == quizs.length - 1 ? "Done" : "Next",
              type: PushableButtonType.quiz,
            ),
          ),
        ],
      ),
    );
  }

  AppBarCustom _buildAppBar(BuildContext context) {
    return AppBarCustom(
      transparent: false,
      // enablePadding: true,
      leading: BackButton(
        color: Colors.white,
        style: ButtonStyle(
            iconSize: MaterialStateProperty.all(24),
            iconColor: MaterialStateProperty.all(Colors.white)),
      ),
      title: ValueListenableBuilder(
        valueListenable: currentQuestion,
        builder: (context, value, _) {
          return Text(
            "Question ${(value + 1).toString()}/${quizs.length.toString()}",
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
      action: SizedBox(width: 50),
      backgroundColor: Colors.purpleAccent
    );
  }
}
