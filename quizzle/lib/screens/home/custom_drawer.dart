import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzle/configs/configs.dart';
import 'package:quizzle/controllers/controllers.dart';
import 'package:quizzle/screens/textconverter.dart';

class CustomDrawer extends GetView<MyDrawerController> {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75, // Limit drawer width
      decoration: BoxDecoration(gradient: mainGradient(context)),
      padding: UIParameters.screenPadding,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: BackButton(
                color: kOnSurfaceTextColor,
                onPressed: () {
                  controller.toggleDrawer();
                },
              ),
            ),
            Center(
              // Centers sign-in or sign-out button
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    return controller.user.value == null
                        ? _DrawerButton(
                            // Show Sign In if user is not logged in
                            icon: Icons.login_rounded,
                            label: 'Sign in',
                            onPressed: () {
                              controller.signIn();
                            },
                          )
                        : _DrawerButton(
                            // Show Sign Out if user is logged in
                            icon: AppIcons.logout,
                            label: 'Sign out',
                            onPressed: () {
                              controller.signOut();
                            },
                          );
                  }),

                  const SizedBox(height: 20),

                  // ✅ Text Converter Button
                  _DrawerButton(
                    icon: Icons.text_fields, // Icon for text conversion
                    label: 'Conveter ',
                    onPressed: () {
                      Get.to(() => const TextConverterPage());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white), // Icon color
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    );
  }
}
