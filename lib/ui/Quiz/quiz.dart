import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';

import 'package:orange_card/resources/services/TTSService.dart';

import 'package:orange_card/app_theme.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/injection_container.dart';
import 'package:orange_card/resources/models/QuizEntity.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/ui/Quiz/game_quiz_summary_page.dart';
import 'package:orange_card/widgets/error_page.dart';
import 'package:orange_card/widgets/loading_indicator.dart';
import 'package:orange_card/widgets/pushable_button.dart';
import 'package:orange_card/widgets/select_option_tile.dart';
import 'package:orange_card/widgets/status_bar.dart';
import 'package:orange_card/widgets/text.dart';
import 'package:orange_card/widgets/timer_count_down.dart';
import 'package:orange_card/widgets/gap.dart';

import 'package:orange_card/ui/Quiz/cubits/game_quiz_cubit.dart';

class GameQuizPage extends StatefulWidget {
  final TopicViewModel topicViewModel;
  final List<Word> words;
  final Map<String, dynamic> settings;
  final String topicId;

  const GameQuizPage(
      {Key? key,
      required this.topicViewModel,
      required this.words,
      required this.settings,
      required this.topicId
      })
      : super(key: key);

  @override
  State<GameQuizPage> createState() => _GameQuizPageState();
}

class _GameQuizPageState extends State<GameQuizPage> {
  late List<QuizEntity> quizs;
  late int timeDuration;
  ValueNotifier<int> currentQuestionIndex = ValueNotifier(0);
  ValueNotifier<int> selectedIndex = ValueNotifier(-1);
  final TTSService textToSpeechService = TTSService();

  @override
  void initState() {
    super.initState();
    if (widget.settings['autoEnabled'])
      timeDuration = AppValueConst.timeForQuiz * widget.words.length +
          widget.words.length; // Example time duration
    else
      timeDuration = AppValueConst.timeForQuiz * widget.words.length;
    // Lấy giá trị từ biến settings
    bool englishQuestions = widget.settings['englishQuestions'] ?? false;
    bool shuffleEnabled = widget.settings['shuffleEnabled'] ?? false;

    if (englishQuestions) {
      quizs = List<QuizEntity>.generate(
        widget.words.length,
        (index) {
          return QuizEntity(
              word: widget.words[index].english,
              question:
                  "What is the meaning of \"${widget.words[index].english}\"",
              answers:
                  _generateRandomAnswers(widget.words[index].vietnamese, true),
              meaning: widget.words[index].vietnamese);
        },
      );
    } else {
      quizs = List<QuizEntity>.generate(
        widget.words.length,
        (index) {
          return QuizEntity(
              word: widget.words[index].vietnamese,
              question:
                  "\"${widget.words[index].vietnamese}\" có từ Tiếng Anh là gì",
              answers: _generateRandomAnswers(
                  widget.words[index].english.toString(), false),
              meaning: widget.words[index].english.toString());
        },
      );
    }

    if (shuffleEnabled) quizs = quizs..shuffle();

    // quizs.forEach((quiz) {
    //   logger.i(quiz.word);
    //   logger.i(quiz.answers);
    //   logger.i(quiz.question);
    //   logger.i(quiz.selectedAnswer);
    //   logger.i(quiz.meaning);
    //   logger.d("next");
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> _generateRandomAnswers(
      String correctAnswer, bool englishQuestions) {
    final answers = widget.words
        .map((word) =>
            englishQuestions ? word.vietnamese : word.english.toString())
        .toList()
      ..shuffle();
    answers.remove(correctAnswer);
    answers.shuffle();
    answers.insert(Random().nextInt(4), correctAnswer);
    return answers.take(4).toList();
  }

  _onCompleteQuiz(BuildContext context) async {
    final correct = quizs
        .where((quiz) =>
            quiz.selectedAnswer.toLowerCase() == quiz.meaning.toLowerCase())
        .length;
    final gold = correct ~/
            AppValueConst.minWordInBagToPlay + // minWordInTopicToPlay  is 5
        (correct == quizs.length ? 2 : 0);

    // quizs.forEach((quiz) {
    //   logger.i(quiz.word);
    //   logger.i(quiz.answers);
    //   logger.i(quiz.question);
    //   logger.i(quiz.selectedAnswer);
    //   logger.i(quiz.meaning);
    //   logger.d("next");
    // });
    logger.i("points: ${correct}"); // Đảm bảo đây là số câu trả lời đúng
    logger.i("Gold: ${gold}");
    // logger.f(FirebaseAuth.instance.currentUser);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await context.read<GameQuizCubit>().calculateResult(
            uid: uid,
            point: correct,
            gold: gold,
            topicId: widget.topicId
          );
    }
  }

  void _onNextQuiz(BuildContext context, int current, bool bnt) {
    if (current < quizs.length - 1) {
      if (quizs[current].selectedAnswer.isNotEmpty) {
        setState(() {
          currentQuestionIndex.value++;
          selectedIndex.value = -1;
        });
      }
    } else if (bnt == false && !widget.settings['autoEnabled']) {
      _onCompleteQuiz(context);
    }
    if (bnt == true && (current == (quizs.length - 1))) {
      _onCompleteQuiz(context);
    }
  }

  _onBack(BuildContext context) async {
    final res = await showDialogWithButton(
      context: context,
      title: "Hey! Are you sure you want to quit this screen?",
      acceptText: "Yes of course",
    );
    if (res != null && res) {
      Navigator.of(context).pop(); // Close the dialog and pop the screen
    }
  }

  Future<bool?> showDialogWithButton({
    String? title,
    String? subtitle,
    String? acceptText,
    String? cancelText,
    Widget? body,
    bool showAccept = true,
    bool showCancel = true,
    bool showIcon = true,
    bool dissmisable = true,
    int maxLinesTitle = 2,
    int maxLinesSubTitle = 3,
    String? icon,
    IconData? iconData,
    VoidCallback? onAccept,
    VoidCallback? onCancel,
    BuildContext? context,
  }) {
    return showGeneralDialog(
      context: context!,
      barrierDismissible: dissmisable,
      barrierLabel: '',
      transitionDuration: Durations.medium1,
      pageBuilder: (context, animation, _) => const SizedBox(),
      transitionBuilder: (context, animation, _, widget) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.75, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1.0).animate(animation),
            child: AlertDialog(
              surfaceTintColor: AppTheme.dark_grey,
              backgroundColor: AppTheme.dark_grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              icon: showIcon
                  ? CircleAvatar(
                      backgroundColor: Colors.purpleAccent,
                      radius: 25,
                      child: icon != null
                          ? SvgPicture.asset(
                              icon,
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              iconData ?? Icons.info,
                              color: Colors.white,
                            ),
                    )
                  : null,
              title: title != null
                  ? Center(
                      child: TextCustom(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: maxLinesTitle,
                        // style: navigationKey
                        //     .currentContext?.textStyle.bodyL.bold.bw,
                      ),
                    )
                  : null,
              content: body ??
                  (subtitle != null
                      ? TextCustom(
                          subtitle ?? '',
                          textAlign: TextAlign.center,
                          maxLines: maxLinesSubTitle,
                          // style: navigationKey
                          //     .currentContext?.textStyle.bodyS.grey,
                        )
                      : null),
              actionsOverflowButtonSpacing: 15,
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: showAccept || showCancel
                  ? [
                      if (showAccept)
                        PushableButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            onAccept?.call();
                          },
                          text: acceptText ?? "Yes of course",
                          type: PushableButtonType.quiz,
                          borderside: false,
                        ),
                      if (showCancel)
                        PushableButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            onCancel?.call();
                          },
                          text: cancelText ?? "Cancel",
                          type: PushableButtonType.white,
                          borderside: false,
                        ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (_) => _onBack(context), // Xử lý việc quay lại màn hình
        child: BlocProvider(
            create: (_) => sl<GameQuizCubit>(),
            child: Builder(builder: (context) {
              return StatusBar(child: BlocBuilder<GameQuizCubit, GameQuizState>(
                builder: (context, state) {
                  if (state.status == GameQuizStatus.loading) {
                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 174, 174, 174),
                      body: const LoadingIndicatorPage(),
                    );
                  }
                  if (state.status == GameQuizStatus.error) {
                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 175, 172, 172),
                      body: ErrorPage(text: state.message ?? ''),
                    );
                  }
                  if (state.status == GameQuizStatus.success) {
                    final correct = quizs
                        .where((e) => e.selectedAnswer == e.meaning)
                        .length;

                    return _buildSuccess(context, correct);
                  }
                  return Scaffold(
                    appBar: _buildAppBar(context),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ValueListenableBuilder(
                              valueListenable: currentQuestionIndex,
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
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                // mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Gap(height: 20),
                                  Center(
                                    child: widget.settings['autoEnabled']
                                        ? _buildCardQuestionAnswerAutoMode(
                                            context)
                                        : _buildCardQuestionAnswer(context),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ));
            })));
  }

  Widget _buildSuccess(BuildContext context, int correct) {
    final gold = correct ~/ AppValueConst.minWordInBagToPlay +
        (correct == quizs.length ? 2 : 0);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 80, 93),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieBuilder.asset(
                  "assets/jsons/trophy.json",
                  height: MediaQuery.of(context).size.height / 4,
                ),
                Text(
                  "$correct/${quizs.length} correct answers",
                  style: TextStyle(
                    // h5 -> headline
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.normal,
                    decorationThickness: 1,
                    fontSize: 16,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
                const Gap(height: 15),
                Text(
                  "Congratlation! You got",
                  style: TextStyle(
                    // h5 -> headline
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 26,
                    letterSpacing: 0.30,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                ),
                const Gap(height: 10),
                Text(
                  "${correct} points",
                  style: TextStyle(
                    // h5 -> headline
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 35,
                    letterSpacing: 0.30,
                    color: Colors.green,
                  ),
                ),
                if (correct ~/ AppValueConst.minWordInBagToPlay > 0) ...[
                  const Gap(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/gold.svg",
                        height: 30,
                        width: 30,
                      ),
                      const Gap(width: 5),
                      TextCustom(
                        "+$gold",
                        style: TextStyle(
                          // h5 -> headline
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          letterSpacing: 0.30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
                const Gap(height: 20),
                !widget.settings['autoEnabled']
                    ? PushableButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              GameQuizSummeryPage(quizs: quizs),
                        )),
                        text: "View result",
                        type: PushableButtonType.quiz,
                      )
                    : const Gap(height: 0),
                const Gap(height: 20),
                PushableButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: "Back",
                  type: PushableButtonType.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardQuestionAnswer(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.lightText,
      ),
      child: ValueListenableBuilder(
        valueListenable: currentQuestionIndex,
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons/question_mark.svg",
              height: 30,
              width: 30,
            ),
            const Gap(width: 8),
            Expanded(
              child: Text(
                "Select your answer",
                style: TextStyle(
                  // Caption -> caption
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  letterSpacing: 0.2,
                  color: Color.fromARGB(255, 255, 255, 255), // was lightText
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 24, 210, 86),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TimeCountDownWidget(
                onFinish: () {
                  _onCompleteQuiz(context);
                },
                durationInSeconds: timeDuration,
                style: AppTheme.caption,
              ),
            ),
          ],
        ),
        builder: (context, current, row) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row!,
              const Gap(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          right: 40), // Để giữ khoảng cách với icon
                      child: Text(
                        "${quizs[current].question}?",
                        textAlign: TextAlign.justify,
                        maxLines: 10,
                        overflow: TextOverflow
                            .visible, // Cho phép hiển thị nhiều dòng
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.27,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      widget.settings['englishQuestions']
                          ? await textToSpeechService
                              .speak(quizs[current].word.toString())
                          : await textToSpeechService
                              .speak(quizs[current].meaning.toString());
                    },
                    child: Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const Gap(height: 15),
              ValueListenableBuilder(
                valueListenable: selectedIndex,
                builder: (context, selected, _) {
                  // return Column(
                  //   children: quizs[current]
                  //       .answers
                  //       .mapIndexed((index, e) => SelectOptionTileWidget(
                  //             onTap: () {
                  //               quizs[current].selectedAnswer = e;
                  //               selectedIndex.value = index;
                  //             },
                  //             isSelected: quizs[current].selectedAnswer == e ||
                  //                 selected == index,
                  //             style: AppTheme.body1,
                  //             text: e.toLowerCase(),
                  //           ))
                  //       .toList(),
                  // );
                  return Column(
                    children:
                        List.generate(quizs[current].answers.length, (index) {
                      final answer = quizs[current].answers[index];
                      return SelectOptionTileWidget(
                        onTap: () {
                          // setState(() {
                          quizs[current].selectedAnswer = answer;
                          selectedIndex.value = index;
                          // });
                        },
                        isSelected: quizs[current].selectedAnswer == answer ||
                            selected == index,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.27,
                          color: Colors.white,
                        ),
                        text: answer.toLowerCase(),
                      );
                    }),
                  );
                },
              ),
              const Gap(height: 15),
              _buildButtons(context, current),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardQuestionAnswerAutoMode(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.lightText,
      ),
      child: ValueListenableBuilder(
        valueListenable: currentQuestionIndex,
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons/question_mark.svg",
              height: 30,
              width: 30,
            ),
            const Gap(width: 8),
            Expanded(
              child: Text(
                "Select your answer",
                style: TextStyle(
                  // Caption -> caption
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  letterSpacing: 0.2,
                  color: Color.fromARGB(255, 255, 255, 255), // was lightText
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 24, 210, 86),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TimeCountDownWidget(
                onFinish: () {
                  _onCompleteQuiz(context);
                },
                durationInSeconds: timeDuration,
                style: AppTheme.caption,
              ),
            ),
          ],
        ),
        builder: (context, current, row) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row!,
              const Gap(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          right: 40), // Để giữ khoảng cách với icon
                      child: Text(
                        "${quizs[current].question}?",
                        textAlign: TextAlign.justify,
                        maxLines: 10,
                        overflow: TextOverflow
                            .visible, // Cho phép hiển thị nhiều dòng
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.27,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      widget.settings['englishQuestions']
                          ? await textToSpeechService
                              .speak(quizs[current].word.toString())
                          : await textToSpeechService
                              .speak(quizs[current].meaning.toString());
                    },
                    child: Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const Gap(height: 15),
              quizs[current].selectedAnswer == ''
                  ? ValueListenableBuilder(
                      valueListenable: selectedIndex,
                      builder: (context, selected, _) {
                        return Column(
                          children: List.generate(quizs[current].answers.length,
                              (index) {
                            final answer = quizs[current].answers[index];
                            return SelectOptionTileWidget(
                              onTap: () {
                                setState(() {
                                  quizs[current].selectedAnswer = answer;
                                  selectedIndex.value = index;
                                });
                                // không cho thay đổi kết quả
                                //đếm thời gian 1s sau đó gọi hàm onNextQuiz()
                                Future.delayed(Duration(milliseconds: 1000),
                                    () {
                                  _onNextQuiz(context, current,
                                      false); // Gọi hàm khi hết thời gian 1 giây
                                });
                              },
                              isSelected:
                                  quizs[current].selectedAnswer == answer ||
                                      selected == index,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.27,
                                color: Colors.white,
                              ),
                              text: answer.toLowerCase(),
                            );
                          }),
                        );
                      },
                    )
                  : Column(
                      children: quizs[current]
                          .answers
                          .mapIndexed((index, e) => SelectOptionTileWidget(
                                onTap: () {},
                                isSelected:
                                    quizs[current].selectedAnswer == e ||
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
                      setState(() {
                        currentQuestionIndex.value--;
                        selectedIndex.value = -1;
                      });
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
          ValueListenableBuilder(
            valueListenable: selectedIndex,
            builder: (context, selected, _) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: PushableButton(
                  onPressed: () => _onNextQuiz(context, current, true),
                  width: MediaQuery.of(context).size.width / 3,
                  type: quizs[current].selectedAnswer.isNotEmpty ||
                          current == quizs.length - 1
                      ? PushableButtonType.quiz
                      : PushableButtonType.grey,
                  text: current == quizs.length - 1 ? "Done" : "Next",
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Question ${currentQuestionIndex.value + 1}/${quizs.length}",
        style: AppTheme.title_appbar2,
      ),
      backgroundColor: Colors.purpleAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          _onBack(context);
        },
      ),
      actions: [
        if (currentQuestionIndex.value < quizs.length - 1)
          TextButton(
            onPressed: () {
              setState(() {
                currentQuestionIndex.value++;
                selectedIndex.value = -1;
              });
            },
            child: Text(
              "Skip",
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
