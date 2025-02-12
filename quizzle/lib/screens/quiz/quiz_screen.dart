import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quizzle/configs/configs.dart';
import 'package:quizzle/controllers/controllers.dart';
import 'package:quizzle/firebase/loading_status.dart';
import 'package:quizzle/screens/quiz/quiz_overview_screen.dart';
import 'package:quizzle/widgets/widgets.dart';

class QuizeScreen extends StatefulWidget {
  const QuizeScreen({super.key});

  static const String routeName = '/quizescreen';

  @override
  State<QuizeScreen> createState() => _QuizeScreenState();
}

class _QuizeScreenState extends State<QuizeScreen> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  final AudioPlayer audioPlayer = AudioPlayer();
  String feedbackMessage = "";
  Color feedbackColor = const Color.fromARGB(0, 0, 0, 0);

  void playCorrectSound() async {
    await audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  void playWrongSound() async {
    await audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await controller.onExitOfQuiz();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Q. ${(controller.questionIndex.value + 1).toString().padLeft(2, '0')}",
                  style: kAppBarTS),
              Obx(() =>
                  Text("Score: ${controller.points.value}", style: kAppBarTS)),
              Obx(() => Text("⏳ ${controller.time.value}",
                  style: kAppBarTS)), // Stopwatch Timer
            ],
          ),
        ),
        body: Stack(
          children: [
            BackgroundDecoration(
              child: Obx(
                () => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10),
                      child: Obx(
                        () {
                          // ✅ Fix: Prevent division by zero error
                          double percent = (controller.allQuestions.isNotEmpty)
                              ? (controller.questionIndex.value + 1) /
                                  controller.allQuestions.length
                              : 0.0;

                          return LinearPercentIndicator(
                            lineHeight: 8.0,
                            percent:
                                percent.clamp(0.0, 1.0), // Ensure valid range
                            backgroundColor: Colors.grey[300]!,
                            progressColor: Colors.green,
                            barRadius: const Radius.circular(10),
                          );
                        },
                      ),
                    ),

                    // ✅ Prevent Bottom Overflow
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            if (controller.loadingStatus.value ==
                                LoadingStatus.loading)
                              const ContentArea(child: QuizScreenPlaceHolder()),
                            if (controller.loadingStatus.value ==
                                LoadingStatus.completed)
                              ContentArea(
                                child: Column(
                                  children: [
                                    Text(
                                        controller
                                            .currentQuestion.value!.question,
                                        style: kQuizeTS),
                                    GetBuilder<QuizController>(
                                      id: 'answers_list',
                                      builder: (_) {
                                        return ListView.separated(
                                          itemCount: controller.currentQuestion
                                              .value!.answers.length,
                                          shrinkWrap: true,
                                          padding:
                                              const EdgeInsets.only(top: 25),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return const SizedBox(height: 10);
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final answer = controller
                                                .currentQuestion
                                                .value!
                                                .answers[index];
                                            final isSelected =
                                                answer.identifier ==
                                                    controller.currentQuestion
                                                        .value!.selectedAnswer;
                                            final isCorrect =
                                                answer.identifier ==
                                                    controller.currentQuestion
                                                        .value!.correctAnswer;

                                            return TweenAnimationBuilder<
                                                double>(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut,
                                              tween: Tween<double>(
                                                  begin: 1.0,
                                                  end: isSelected && isCorrect
                                                      ? 1.2
                                                      : 1.0),
                                              builder: (context, scale, child) {
                                                return Transform.scale(
                                                  scale: scale,
                                                  child: AnswerCard(
                                                    isSelected: isSelected,
                                                    status: isSelected
                                                        ? (isCorrect
                                                            ? AnswerStatus
                                                                .correct
                                                            : AnswerStatus
                                                                .wrong)
                                                        : null,
                                                    onTap: () {
                                                      controller.selectAnswer(
                                                          answer.identifier);
                                                      if (isCorrect) {
                                                        playCorrectSound();
                                                        _confettiController
                                                            .play();
                                                        controller
                                                            .increaseScore();
                                                        setState(() {
                                                          feedbackMessage =
                                                              "Nicely done!";
                                                          feedbackColor =
                                                              Colors.green;
                                                        });
                                                      } else {
                                                        playWrongSound();
                                                        setState(() {
                                                          feedbackMessage =
                                                              "Incorrect! The correct answer is: ${controller.currentQuestion.value!.correctAnswer}";
                                                          feedbackColor =
                                                              Colors.red;
                                                        });
                                                      }
                                                    },
                                                    answer:
                                                        '${answer.identifier}. ${answer.answer}',
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ✅ Feedback Message (Fixed Overflow Issue)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: feedbackMessage.isNotEmpty ? 60 : 0,
                      color: feedbackColor,
                      alignment: Alignment.center,
                      child: Text(feedbackMessage,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),

                    // ✅ Buttons Section
                    ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: UIParameters.screenPadding,
                        child: Row(
                          children: [
                            Visibility(
                              visible: controller.isFirstQuestion,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: SizedBox(
                                  height: 55,
                                  width: 55,
                                  child: MainButton(
                                    onTap: () => controller.prevQuestion(),
                                    child: const Icon(Icons.arrow_back_ios_new),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Obx(
                                () => Visibility(
                                  visible: controller.loadingStatus.value ==
                                      LoadingStatus.completed,
                                  child: MainButton(
                                    onTap: () {
                                      setState(() {
                                        feedbackMessage =
                                            ""; // Clear feedback before moving to next
                                      });
                                      controller.isLastQuestion
                                          ? Get.toNamed(
                                              QuizOverviewScreen.routeName)
                                          : controller.nextQuestion();
                                    },
                                    title: "Next",
                                    color:
                                        feedbackColor, // Change button color based on answer
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
