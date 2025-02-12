// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:quizzle/configs/configs.dart';
// import 'package:quizzle/controllers/auth_controller.dart';
// import 'package:quizzle/widgets/widgets.dart';

// class LoginScreen extends GetView<AuthController> {
//   const LoginScreen({Key? key}) : super(key: key);

//   static const String routeName = '/login';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: const CustomAppBar(),
//       body: Container(
//           constraints: const BoxConstraints(maxWidth: kTabletChangePoint),
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(gradient: mainGradient(context)),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPicture.asset('assets/images/app_splash_logo.svg'),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 60),
//                 child: Text(
//                   'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: kOnSurfaceTextColor, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               MainButton(
//                 onTap: () {
//                   controller.siginInWithGoogle();
//                  },
//                 color: Colors.white,
//                 child: Stack(
//                   children: [
//                     Positioned(
//                         top: 0,
//                         bottom: 0,
//                         left: 0,
//                         child: SvgPicture.asset(
//                           'assets/icons/google.svg',
//                         )),
//                     Center(
//                       child: Text(
//                         'Sign in  with google',
//                         style: TextStyle(
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           )),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzle/configs/configs.dart';
import 'package:quizzle/controllers/auth_controller.dart';
import 'package:quizzle/widgets/widgets.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      body: Container(
        constraints: const BoxConstraints(maxWidth: kTabletChangePoint),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(gradient: mainGradient(context)),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset('assets/images/app_logo.png', width: 150, height: 150),

              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                ),
                obscureText: true,
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Login Button
              MainButton(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    controller.signInWithEmail(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  }
                },
                color: Colors.white,
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Navigate to Sign Up
              TextButton(
                onPressed: () {
                  Get.toNamed('/register'); // Change to your register page route
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
