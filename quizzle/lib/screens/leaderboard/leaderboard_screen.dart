import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:quizzle/controllers/controllers.dart';
import 'package:quizzle/firebase/firebase_configs.dart';
import 'package:quizzle/models/models.dart';
import 'package:quizzle/widgets/widgets.dart';

class LeaderBoardScreen extends StatefulWidget {
  LeaderBoardScreen({super.key}) {
    SchedulerBinding.instance.addPostFrameCallback((d) {
      final paper = Get.arguments as QuizPaperModel;
      Get.find<LeaderBoardController>().getAll(paper.id);
      Get.find<LeaderBoardController>().getMyScores(paper.id);
    });
  }

  static const String routeName = '/leaderboard';

  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showAnimation = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaderBoardController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Background with Gradient
          BackgroundDecoration(
            showGradient: true,
            child: Column(
              children: [
                // Display score at the top
                Obx(() {
                  if (controller.myScores.value == null) {
                    return const SizedBox();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LeaderBoardCard(
                        data: controller.myScores.value!,
                        index: -1,
                      ),
                    );
                  }
                }),

                // Leaderboard List
                Expanded(
                  child: Obx(
                    () => controller.loadingStatus.value ==
                            LoadingStatus.loading
                        ? const ContentArea(
                            addPadding: true,
                            child: LeaderBoardPlaceHolder(),
                          )
                        : ContentArea(
                            addPadding: false,
                            child: ListView.separated(
                              itemCount: controller.leaderBoard.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                              itemBuilder: (BuildContext context, int index) {
                                final data = controller.leaderBoard[index];
                                return LeaderBoardCard(
                                  data: data,
                                  index: index,
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Animation Overlay
          if (_showAnimation)
            Center(
              child:
                  Lottie.asset('assets/animations/trofie.json', repeat: false),
            ),
        ],
      ),
    );
  }
}

class LeaderBoardCard extends StatelessWidget {
  const LeaderBoardCard({
    super.key,
    required this.data,
    required this.index,
  });

  final LeaderBoardData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    const tsStyle = TextStyle(fontWeight: FontWeight.bold);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          foregroundImage:
              data.user.image == null ? null : NetworkImage(data.user.image!),
          child: data.user.image == null
              ? const Icon(Icons.person, size: 24, color: Colors.grey)
              : null,
        ),
        title: Text(
          data.user.name,
          style: tsStyle,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconWithText(
              icon: Icon(Icons.done_all, color: Theme.of(context).primaryColor),
              text: Text('${data.correctCount}', style: tsStyle),
            ),
            IconWithText(
              icon: Icon(Icons.timer, color: Theme.of(context).primaryColor),
              text: Text('${data.time}', style: tsStyle),
            ),
            IconWithText(
              icon: Icon(Icons.emoji_events_outlined,
                  color: Theme.of(context).primaryColor),
              text: Text('${data.points}', style: tsStyle),
            ),
          ],
        ),
        trailing: Text(
          '#${(index + 1).toString().padLeft(2, "0")}',
          style: tsStyle,
        ),
      ),
    );
  }
}
