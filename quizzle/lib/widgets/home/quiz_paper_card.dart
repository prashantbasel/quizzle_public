import 'package:easy_separator/easy_separator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:quizzle/configs/configs.dart';
import 'package:quizzle/controllers/controllers.dart';
import 'package:quizzle/models/quiz_paper_model.dart';
import 'package:quizzle/screens/screens.dart';
import 'package:quizzle/widgets/widgets.dart';

class QuizPaperCard extends GetView<QuizPaperController> {
  const QuizPaperCard({Key? key, required this.model}) : super(key: key);

  final QuizPaperModel model;

  @override
  Widget build(BuildContext context) {
    const double padding = 10.0;
    return Ink(
      decoration: BoxDecoration(
        borderRadius: UIParameters.cardBorderRadius,
        color: Theme.of(context).cardColor,
      ),
      child: InkWell(
        borderRadius: UIParameters.cardBorderRadius,
        onTap: () {
          _showAnimationAndNavigate(context, model);
        },
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Row Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: UIParameters.cardBorderRadius,
                    child: ColoredBox(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: SizedBox(
                        width: 65,
                        height: 65,
                        child: model.imageUrl == null || model.imageUrl!.isEmpty
                            ? null
                            : Image.network(model.imageUrl!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.title, style: cardTitleTs(context)),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Text(model.description),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: EasySeparatedRow(
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(width: 15);
                            },
                            children: [
                              IconWithText(
                                icon: Icon(Icons.help_outline_sharp,
                                    color: Colors.blue[700]),
                                text: Text('${model.questionsCount} quizzes',
                                    style: kDetailsTS.copyWith(
                                        color: Colors.blue[700])),
                              ),
                              IconWithText(
                                icon: const Icon(Icons.timer,
                                    color: Colors.blueGrey),
                                text: Text(model.timeInMinits(),
                                    style: kDetailsTS.copyWith(
                                        color: Colors.blueGrey)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),

              // LEADERBOARD ICON (TROPHY)
              Positioned(
                bottom: -padding,
                right: -padding,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // Navigate to Leaderboard Screen
                    Get.toNamed(LeaderBoardScreen.routeName, arguments: model);
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kCardBorderrRadius),
                        bottomRight: Radius.circular(kCardBorderrRadius),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Icon(
                      Icons.emoji_events, // Trophy Icon
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show animation before navigating to quiz
  void _showAnimationAndNavigate(BuildContext context, QuizPaperModel model) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Lottie.asset(
          'assets/animations/cat.json',
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pop();
              Get.find<QuizPaperController>().navigatoQuestions(paper: model);
            });
          },
        ),
      ),
    );
  }
}
