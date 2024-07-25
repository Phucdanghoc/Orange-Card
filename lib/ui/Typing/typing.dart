import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orange_card/resources/models/TypingEntity.dart';
import 'package:orange_card/resources/services/TTSService.dart';

import 'package:orange_card/app_theme.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/injection_container.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';
import 'package:orange_card/ui/Typing/game_typing_summary_page.dart';
import 'package:orange_card/widgets/error_page.dart';
import 'package:orange_card/widgets/loading_indicator.dart';
import 'package:orange_card/widgets/pushable_button.dart';
import 'package:orange_card/widgets/status_bar.dart';
import 'package:orange_card/widgets/text.dart';
import 'package:orange_card/widgets/timer_count_down.dart';
import 'package:orange_card/widgets/gap.dart';

import 'package:orange_card/ui/Typing/cubits/game_typing_cubit.dart';

class GameTypingPage extends StatefulWidget {
  final TopicViewModel topicViewModel;
  final List<Word> words;
  final Map<String, dynamic> settings;
  final String topicId;

  const GameTypingPage(
      {Key? key,
      required this.topicViewModel,
      required this.words,
      required this.settings,
      required this.topicId
      })
      : super(key: key);

  @override
  State<GameTypingPage> createState() => _GameTypingPageState();
}

class _GameTypingPageState extends State<GameTypingPage> {
  late List<TypingEntity> typings;
  late int timeDuration;
  ValueNotifier<int> currentQuestionIndex = ValueNotifier(0);
  ValueNotifier<String> answerNoMode = ValueNotifier("");
  final TTSService textToSpeechService = TTSService();
  late bool showAns;
  late bool buttonSubmited = false;
  late String answer;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.showAns = false;
    this.answer = "";
    timeDuration = AppValueConst.timeForTyping * widget.words.length +
        widget.words.length *2;
    // Lấy giá trị từ biến settings
    bool englishQuestions = widget.settings['englishQuestions'] ?? false;
    bool shuffleEnabled = widget.settings['shuffleEnabled'] ?? false;

    if (englishQuestions) {
      typings = List<TypingEntity>.generate(
        widget.words.length,
        (index) {
          return TypingEntity(
              word: widget.words[index].english,
              meaning: widget.words[index].vietnamese);
        },
      );
    } else {
      typings = List<TypingEntity>.generate(
        widget.words.length,
        (index) {
          return TypingEntity(
              word: widget.words[index].vietnamese,
              meaning: widget.words[index].english.toString());
        },
      );
    }

    if (shuffleEnabled) typings = typings..shuffle();

    // quizs.forEach((quiz) {
    //   logger.i(quiz.word);
    //   logger.i(quiz.answers);
    //   logger.i(quiz.question);
    //   logger.i(quiz.typingAnswer);
    //   logger.i(quiz.meaning);
    //   logger.d("next");
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onCompleteQuiz(BuildContext context) async {
    final correct = typings
        .where((typing) =>
            typing.typingAnswer.toLowerCase() == typing.meaning.toLowerCase())
        .length;
    final gold = correct ~/
            AppValueConst.minWordInBagToPlay + // minWordInTopicToPlay  is 5
        (correct == typings.length ? 2 : 0);

    // quizs.forEach((quiz) {
    //   logger.i(quiz.word);
    //   logger.i(quiz.answers);
    //   logger.i(quiz.question);
    //   logger.i(quiz.typingAnswer);
    //   logger.i(quiz.meaning);
    //   logger.d("next");
    // });
    logger.i("points: ${correct}"); // Đảm bảo đây là số câu trả lời đúng
    logger.i("Gold: ${gold}");
    // logger.f(FirebaseAuth.instance.currentUser);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await context.read<GameTypingCubit>().calculateResult(
            uid: uid,
            point: correct,
            gold: gold,
            topicId: widget.topicId
          );
    }
  }

  void _onNextQuiz(BuildContext context, int current, bool bnt) {
    logger.i(current);
    if (current < typings.length - 1) {
      if (typings[current].typingAnswer.isNotEmpty) {
        setState(() {
          this.buttonSubmited = false;
          this.showAns = false;
          this.answer = "";
          this.answerNoMode.value = "";
          currentQuestionIndex.value++;
          _textEditingController.text = "";
        });
      }
    } else if (bnt == false && !widget.settings['autoEnabled']) {
      _onCompleteQuiz(context);
    }
    if (bnt == true && (current == (typings.length - 1))) {
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
                      backgroundColor: Colors.blueAccent,
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
                          type: PushableButtonType.typing,
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
            create: (_) => sl<GameTypingCubit>(),
            child: Builder(builder: (context) {
              return StatusBar(
                  child: BlocBuilder<GameTypingCubit, GameTypingState>(
                builder: (context, state) {
                  if (state.status == GameTypingStatus.loading) {
                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 174, 174, 174),
                      body: const LoadingIndicatorPage(),
                    );
                  }
                  if (state.status == GameTypingStatus.error) {
                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 175, 172, 172),
                      body: ErrorPage(text: state.message ?? ''),
                    );
                  }
                  if (state.status == GameTypingStatus.success) {
                    final correct = typings
                        .where((e) =>
                            e.typingAnswer.toLowerCase() ==
                            e.meaning.toLowerCase())
                        .length;

                    return _buildSuccess(context, correct);
                  }
                  return Scaffold(
                    appBar: _buildAppBar(context),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: currentQuestionIndex,
                              builder: (context, value, _) {
                                return LinearProgressIndicator(
                                  value: (value + 1) / typings.length,
                                  color: Colors.green,
                                  backgroundColor: Colors.grey.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(8),
                                  minHeight: 12,
                                );
                              },
                            ),
                            const Gap(height: 20),
                            widget.settings['autoEnabled']
                                ? _buildTypingQuestionAnswerAutoMode(context)
                                : _buildTypingQuestionAnswer(context),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
            })));
  }

  Widget _buildSuccess(BuildContext context, int correct) {
    final gold = correct ~/ AppValueConst.minWordInBagToPlay +
        (correct == typings.length ? 2 : 0);
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
                  "$correct/${typings.length} correct answers",
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
                              GameTypingSummeryPage(typing: typings),
                        )),
                        text: "View result",
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

  Widget _buildTypingQuestionAnswerAutoMode(BuildContext context) {
    return Container(
      child: ValueListenableBuilder(
        valueListenable: currentQuestionIndex,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng 1
                  Row(
                    children: [
                      // Text câu hỏi
                      Expanded(
                        child: Text(
                          widget.settings["englishQuestions"]
                              ? "Hãy điền chính xác nghĩa tiếng Việt của từ sau:"
                              : "Hãy điền chính xác nghĩa tiếng Anh của từ sau:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
        builder: (context, current, row) {
          return Column(
            children: [
              row!,
              const Gap(height: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hàng 2
                    Row(
                      children: [
                        // Widget hiển thị câu hỏi (nếu có)
                        Expanded(
                          child: Container(
                            color: Colors.grey.withOpacity(0.3),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Gold",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        // Ô nhập trả lời (nếu có)
                        Expanded(
                          child: Container(
                            color: Colors.grey.withOpacity(0.3),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Time",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa hàng 3 và hàng 4

                    // Hàng 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Góc trên bên trái (nếu cần)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            child: Text(
                              "${(typings.where((typing) => typing.typingAnswer.toLowerCase() == typing.meaning.toLowerCase()).length) ~/ AppValueConst.minWordInBagToPlay + // minWordInTopicToPlay  is 5
                                  ((typings.where((typing) => typing.typingAnswer.toLowerCase() == typing.meaning.toLowerCase()).length) == typings.length ? 2 : 0)}",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        // Góc trên bên phải (nếu cần)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa hàng 2 và hàng 3

                    // Hàng 4
                    Row(
                      children: [
                        // Widget hiển thị câu hỏi (nếu có)
                        Expanded(
                          child: Container(
                            color: Colors.grey.withOpacity(0.3),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Point",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        // Ô nhập trả lời (nếu có)
                        Expanded(
                          child: Container(
                            color: Colors.grey.withOpacity(0.3),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Đáp án",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa hàng 3 và hàng 4

                    // Hàng 5
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Góc dưới bên trái (nếu cần)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            child: Text(
                              "${typings.where((typing) => typing.typingAnswer.toLowerCase() == typing.meaning.toLowerCase()).length}",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                        // Góc dưới bên phải (nếu cần)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            child: Text(
                              this.showAns
                                  ? "${typings[current].meaning.toLowerCase()}"
                                  : "",
                              style: typings[current].meaning.toLowerCase() ==
                                      this.answer
                                  ? TextStyle(color: Colors.green)
                                  : TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(height: 20),
              // Không gian hiển thị câu hỏi và nhập câu trả lời
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.withOpacity(0.2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${typings[current].word}", // Hiển thị câu hỏi
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Biểu tượng loa
                        GestureDetector(
                          onTap: () async {
                            widget.settings['englishQuestions']
                                ? await textToSpeechService
                                    .speak(typings[current].word.toString())
                                : await textToSpeechService
                                    .speak(typings[current].meaning.toString());
                          },
                          child: Icon(
                            Icons.volume_up,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      enabled: !this
                          .buttonSubmited, // Cho phép chỉnh sửa khi buttonSubmited là false
                      controller: typings[current].typingAnswer.isNotEmpty
                          ? TextEditingController(
                              text: typings[current].typingAnswer)
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Nhập câu trả lời của bạn',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => {
                        setState(() {
                          this.answer = value;
                        })
                      },
                    ),
                  ],
                ),
              ),
              const Gap(height: 20),
              // Nút chuyển câu hỏi
              PushableButton(
                onPressed: () => {
                  typings[current].typingAnswer = this.answer,
                  setState(() {
                    this.showAns = true;
                    this.buttonSubmited = true;
                  }),
                  //đếm thời gian 1s sau đó gọi hàm onNextQuiz()
                  Future.delayed(Duration(milliseconds: 2000), () {
                    _onNextQuiz(context, current, true);
                    // Gọi hàm khi hết thời gian 1 giây
                  }),
                },
                width: MediaQuery.of(context).size.width / 3,
                type: this.answer.isNotEmpty || current == typings.length - 1
                    ? !this.buttonSubmited
                        ? PushableButtonType.typing
                        : PushableButtonType.disable
                    : PushableButtonType.disable,
                text: current == typings.length - 1 ? "Done" : "Next",
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleSubmitted(String value,int current) {
  typings[current].typingAnswer = value;
}

  Widget _buildTypingQuestionAnswer(BuildContext context) {
    return Container(
      child: ValueListenableBuilder(
        valueListenable: currentQuestionIndex,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng 1
                  Row(
                    children: [
                      // Text câu hỏi
                      Expanded(
                        child: Text(
                          widget.settings["englishQuestions"]
                              ? "Hãy điền chính xác nghĩa tiếng Việt của từ sau:"
                              : "Hãy điền chính xác nghĩa tiếng Anh của từ sau:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
        builder: (context, current, row) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row!,
              const Gap(height: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hàng 2
                    Row(
                      children: [
                        // Ô nhập trả lời (nếu có)
                        Expanded(
                          child: Container(
                            color: Colors.grey.withOpacity(0.3),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Time",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa hàng 3 và hàng 4

                    // Hàng 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Góc trên bên phải (nếu cần)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa hàng 2 và hàng 3

                  ],
                ),
              ),
              const Gap(height: 15),
              ValueListenableBuilder(
                valueListenable: answerNoMode,
                builder: (context, answer, _) {
                  return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${typings[current].word}", // Hiển thị câu hỏi
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Biểu tượng loa
                              GestureDetector(
                                onTap: () async {
                                  widget.settings['englishQuestions']
                                      ? await textToSpeechService.speak(
                                          typings[current].word.toString())
                                      : await textToSpeechService.speak(
                                          typings[current].meaning.toString());
                                },
                                child: Icon(
                                  Icons.volume_up,
                                  size: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _textEditingController,
                            // enabled: typings[current].typingAnswer.isEmpty, // Cho phép chỉnh sửa khi buttonSubmited là false
                            decoration: InputDecoration(
                              hintText: typings[current].typingAnswer.isEmpty ? 'Nhập câu trả lời của bạn':typings[current].typingAnswer,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => {
                              setState(() {
                                this.answerNoMode.value = value;
                              })
                            },
                            onSubmitted: (value) => {
                              _handleSubmitted(value, current)
                            },
                          ),
                        ],
                      ));
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
                        // answerNoMode.value = "";
                        _textEditingController.text = "";
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
                        color: Colors.black,
                      ),
                    ),
                  ),
          ),
          ValueListenableBuilder(
            valueListenable: answerNoMode,
            builder: (context, answer, _) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: PushableButton(
                  onPressed: () {
                    if (typings[current].typingAnswer.isEmpty)
                    _handleSubmitted(_textEditingController.text,current);
                    _onNextQuiz(context, current, false);

                  },
                  width: MediaQuery.of(context).size.width / 3,
                  type: answer.isNotEmpty ||
                          current == typings.length - 1 || typings[current].typingAnswer.isNotEmpty
                      ? PushableButtonType.typing
                      : PushableButtonType.grey,
                  text: current == typings.length - 1 ? "Done" : "Next",
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
        "Question ${currentQuestionIndex.value + 1}/${typings.length}",
        style: AppTheme.title_appbar2,
      ),
      backgroundColor: Colors.blueAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          _onBack(context);
        },
      ),
      actions: [
        if (currentQuestionIndex.value < typings.length - 1 &&
            !widget.settings["autoEnabled"])
          TextButton(
            onPressed: () {
              setState(() {
                currentQuestionIndex.value++;
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
