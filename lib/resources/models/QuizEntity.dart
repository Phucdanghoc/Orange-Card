class QuizEntity {
  final String? word;
  final String question;
  final List<String> answers;
  String selectedAnswer;
  String meaning;
  QuizEntity(
      {required this.word,
      required this.question,
      required this.answers,
      this.selectedAnswer = '',
      required this.meaning});
}
