import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzle/firebase/firebase_configs.dart';
import 'package:quizzle/models/models.dart';
import 'package:quizzle/screens/screens.dart';
import 'package:quizzle/utils/logger.dart';
import 'package:quizzle/widgets/dialogs/dialogs.dart';

import 'quiz_papers_controller.dart';

class QuizController extends GetxController {
  final loadingStatus = LoadingStatus.loading.obs;
  final allQuestions = <Question>[].obs;
  Rxn<QuizPaperModel> quizPaperModel = Rxn<QuizPaperModel>();
  Timer? _timer;
  int remainSeconds = 1;
  final time = '00:00'.obs;
  final RxInt points = 0.obs;
  final RxString feedbackMessage = "".obs;
  final Rx<Color> feedbackColor = Colors.transparent.obs;

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments is QuizPaperModel) {
      loadData(Get.arguments as QuizPaperModel);
    } else {
      loadingStatus.value = LoadingStatus.error;
      Get.snackbar("Error", "Quiz data not found!");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<bool> onExitOfQuiz() async {
    bool exitQuiz = await Dialogs.quizEndDialog();
    if (exitQuiz) {
      navigateToHome(); // Take user to home screen
    }
    return exitQuiz;
  }

  void _startTimer(int? seconds) {
    if (seconds == null) return; // ✅ Prevents null timer crash
    remainSeconds = seconds;
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer timer) {
      if (remainSeconds == 0) {
        timer.cancel();
      } else {
        int minutes = remainSeconds ~/ 60;
        int seconds = remainSeconds % 60;
        time.value =
            "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
        remainSeconds--;
      }
    });
  }

  void loadData(QuizPaperModel quizPaper) async {
    try {
      loadingStatus.value = LoadingStatus.loading;
      quizPaperModel.value = quizPaper;

      final QuerySnapshot<Map<String, dynamic>> questionsQuery =
          await quizePaperFR.doc(quizPaper.id).collection('questions').get();

      final questions = questionsQuery.docs
          .map((question) => Question.fromSnapshot(question))
          .toList();
      quizPaper.questions = questions;

      for (Question question in quizPaper.questions ?? []) {
        final QuerySnapshot<Map<String, dynamic>> answersQuery =
            await quizePaperFR
                .doc(quizPaper.id)
                .collection('questions')
                .doc(question.id)
                .collection('answers')
                .get();
        question.answers = answersQuery.docs
            .map((answer) => Answer.fromSnapshot(answer))
            .toList();
      }

      if (quizPaper.questions != null && quizPaper.questions!.isNotEmpty) {
        allQuestions.assignAll(quizPaper.questions!);
        currentQuestion.value = quizPaper.questions!.first;
        _startTimer(quizPaper.timeSeconds ?? 900); // ✅ Default time if null
        loadingStatus.value = LoadingStatus.completed;
      } else {
        loadingStatus.value = LoadingStatus.noReult;
      }
    } catch (e) {
      AppLogger.e(e);
      loadingStatus.value = LoadingStatus.error;
      Get.snackbar("Error", "Failed to load quiz data");
    }
  }

  Rxn<Question> currentQuestion = Rxn<Question>();
  final questionIndex = 0.obs;

  bool get isFirstQuestion => questionIndex.value > 0;
  bool get isLastQuestion => questionIndex.value >= allQuestions.length - 1;

  void nextQuestion() {
    if (!isLastQuestion) {
      questionIndex.value++;
      currentQuestion.value = allQuestions[questionIndex.value];
      feedbackMessage.value = "";
      feedbackColor.value = Colors.transparent;
    }
  }

  void prevQuestion() {
    if (isFirstQuestion) {
      questionIndex.value--;
      currentQuestion.value = allQuestions[questionIndex.value];
    }
  }

  void jumpToQuestion(int index, {bool isGoBack = true}) {
    if (index < 0 || index >= allQuestions.length)
      return; // ✅ Prevents out-of-range error
    questionIndex.value = index;
    currentQuestion.value = allQuestions[index];
    if (isGoBack) Get.back();
  }

  void selectAnswer(String? answer) {
    if (currentQuestion.value == null) return; // ✅ Prevents null crash
    currentQuestion.value!.selectedAnswer = answer;
    update(['answers_list', 'answers_review_list']);

    if (answer == currentQuestion.value!.correctAnswer) {
      feedbackMessage.value = "Nicely done!";
      feedbackColor.value = Colors.green;
      increaseScore();
    } else {
      feedbackMessage.value =
          "Incorrect! The correct answer is: ${currentQuestion.value!.correctAnswer ?? "N/A"}";
      feedbackColor.value = Colors.red;
    }
  }

  String get completedQuiz {
    final answeredQuestionCount = allQuestions
        .where((question) => question.selectedAnswer != null)
        .length;
    return '$answeredQuestionCount out of ${allQuestions.length} answered';
  }

  void complete() {
    _timer?.cancel();
    Get.offAndToNamed(Resultcreen.routeName);
  }

  void tryAgain() {
    if (quizPaperModel.value == null) return; // ✅ Prevents null error
    points.value = 0;
    remainSeconds = quizPaperModel.value?.timeSeconds ?? 900;
    _startTimer(quizPaperModel.value?.timeSeconds);
    Get.find<QuizPaperController>()
        .navigatoQuestions(paper: quizPaperModel.value!, isTryAgain: true);
  }

  void navigateToHome() {
    _timer?.cancel();
    Get.offNamedUntil(HomeScreen.routeName, (route) => false);
  }

  void increaseScore() {
    points.value += 10;
  }
}
