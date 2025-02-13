import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzle/configs/configs.dart';
import 'package:quizzle/controllers/quiz_paper/quiz_controller.dart';
import 'package:quizzle/screens/quiz/quiz_overview_screen.dart';
import 'package:quizzle/widgets/widgets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title = '',
    this.showActionIcon = false,
    this.leading,
    this.titleWidget,
    this.onMenuActionTap,
  });

  final String title;
  final Widget? titleWidget;
  final bool showActionIcon;
  final Widget? leading;
  final VoidCallback? onMenuActionTap;

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kMobileScreenPadding,
            vertical: kMobileScreenPadding / 1.2),
        child: Stack(
          children: [
            Positioned.fill(
              child: titleWidget ??
                  Center(
                    child: Text(
                      title,
                      style: kAppBarTS,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leading ??
                    Transform.translate(
                        offset: const Offset(-14, 0),
                        child: const BackButton()),
                Obx(
                  () => Text(
                    "Score: ${controller.points.value}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                if (showActionIcon)
                  Transform.translate(
                    offset: const Offset(10, 0),
                    child: CircularButton(
                      onTap: onMenuActionTap ??
                          () {
                            Get.toNamed(QuizOverviewScreen.routeName);
                          },
                      child: const Icon(AppIcons.menu),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 80);
}
