import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:quizzle/configs/configs.dart';
import 'package:quizzle/controllers/controllers.dart';
import 'package:quizzle/widgets/widgets.dart';

import 'custom_drawer.dart';

class HomeScreen extends GetView<MyDrawerController> {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final QuizPaperController quizPaperController = Get.find();
    return Scaffold(
      body: GetBuilder<MyDrawerController>(
        builder: (_) => ZoomDrawer(
          controller: _.zoomDrawerController,
          borderRadius: 50.0,
          showShadow: true,
          angle: 0.0,
          style: DrawerStyle.defaultStyle,
          menuScreen: const CustomDrawer(),
          menuBackgroundColor: Colors.white.withOpacity(0.7),
          slideWidth: MediaQuery.of(context).size.width * 0.6,
          mainScreen: Container(
            decoration: BoxDecoration(gradient: mainGradient(context)),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(kMobileScreenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(-10, 0),
                          child: CircularButton(
                            onTap: controller.toggleDrawer,
                            child: const Icon(AppIcons.menuleft),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              const Icon(AppIcons.peace),
                              Builder(
                                builder: (_) {
                                  final AuthController auth = Get.find();
                                  final user = auth.getUser();
                                  String label = '  Hello mate';
                                  if (user != null) {
                                    label = '  Hello ${user.displayName}';
                                  }
                                  return Text(label,
                                      style: kDetailsTS.copyWith(
                                          color: kOnSurfaceTextColor));
                                },
                              ),
                            ],
                          ),
                        ),
                        const Text('What Do You Want To Improve Today?',
                            style: kHeaderTS),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ContentArea(
                        addPadding: false,
                        child: Obx(
                          () => LiquidPullToRefresh(
                            height: 120,
                            springAnimationDurationInMilliseconds: 400,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.4),
                            onRefresh: () async {
                              quizPaperController.getAllPapers();
                            },
                            child: ListView.builder(
                              padding: UIParameters.screenPadding,
                              itemCount: quizPaperController.allPapers.length,
                              itemBuilder: (context, index) {
                                return QuizPaperCard(
                                  model: quizPaperController.allPapers[index],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
