import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:quizzle/controllers/controllers.dart';
import 'package:quizzle/firebase/references.dart';
import 'package:quizzle/services/notification/notification_service.dart';

extension QuizeResult on QuizController {
  int get correctQuestionCount => allQuestions
      .where((question) => question.selectedAnswer == question.correctAnswer)
      .length;

  String get correctAnsweredQuestions {
    return '$correctQuestionCount out of ${allQuestions.length} are correct';
  }

  String get points {
    if (quizPaperModel.value?.timeSeconds == null)
      return "0.00"; // ✅ Fix: Prevents null access

    double timeFactor = (quizPaperModel.value!.timeSeconds - remainSeconds) /
        quizPaperModel.value!.timeSeconds;

    var points =
        (correctQuestionCount / allQuestions.length) * 100 * timeFactor * 100;

    return points.toStringAsFixed(2);
  }

  Future<void> saveQuizResults() async {
    var batch = fi.batch();
    User? user = Get.find<AuthController>().getUser();
    if (user == null || quizPaperModel.value == null)
      return; // ✅ Prevent null errors

    batch.set(
        userFR
            .doc(user.email)
            .collection('myrecent_quizes')
            .doc(quizPaperModel.value!.id),
        {
          "points": points,
          "correct_count": '$correctQuestionCount/${allQuestions.length}',
          "paper_id": quizPaperModel.value!.id,
          "time": quizPaperModel.value!.timeSeconds - remainSeconds
        });

    batch.set(
        leaderBoardFR
            .doc(quizPaperModel.value!.id)
            .collection('scores')
            .doc(user.email),
        {
          "points": double.parse(points),
          "correct_count": '$correctQuestionCount/${allQuestions.length}',
          "paper_id": quizPaperModel.value!.id,
          "user_id": user.email,
          "time": quizPaperModel.value!.timeSeconds - remainSeconds
        });

    await batch.commit();

    Get.find<NotificationService>().showQuizCompletedNotification(
        id: 1,
        title: quizPaperModel.value!.title,
        body:
            'You have just got $points points for ${quizPaperModel.value!.title} - Tap here to view leaderboard',
        imageUrl: quizPaperModel.value!.imageUrl,
        payload: json.encode(quizPaperModel.value!.toJson()));

    navigateToHome();
  }
}
