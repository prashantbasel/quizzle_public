import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:quizzle/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIntroductionScreen extends StatefulWidget {
  const AppIntroductionScreen({super.key});
  static const String routeName = '/introduction';

  @override
  State<AppIntroductionScreen> createState() => _AppIntroductionScreenState();
}

class _AppIntroductionScreenState extends State<AppIntroductionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int openCount = 0; // This will store the count

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _loadOpenCount(); // Load count when app starts
  }

  // Function to load the count from shared preferences
  Future<void> _loadOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      openCount =
          (prefs.getInt('open_count') ?? 0) + 1; // Increment on every open
    });
    await prefs.setInt('open_count', openCount); // Save new count
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 88, 24, 152), // Darker for a gamified feel
              Color.fromARGB(255, 195, 208, 230)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ✅ Replace the faulty sparkle animation with a working one

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 🪁 Kite Animation (TOP)
                Lottie.network(
                  'https://assets7.lottiefiles.com/packages/lf20_x62chJ.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                // 🔥 Fire Animation + Streak Badge (MIDDLE)
                Column(
                  children: [
                    // ✅ Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Text(
                        "🔥 Streak: $openCount Days!",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ✅ Fire animation + Open Count Number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Fire animation with glow effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.9),
                                blurRadius: 20,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Lottie.asset(
                            'assets/animations/fire.json', // Ensure this file is in assets
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            controller: _controller,
                            onLoaded: (composition) {
                              _controller.duration = composition.duration;
                              _controller.repeat();
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        // ✅ Fix: Display only **one** counter with stroke effect
                        Text(
                          '$openCount',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black
                                    .withOpacity(0.5), // Stroke effect
                              ),
                            ],
                            color: Colors.white, // Inner color
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🎮 App Title
                    const Text(
                      'AI-Powered Gamified Quiz App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24, // Slightly larger for emphasis
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 🎮 Futuristic Start Button (Bottom)
                GestureDetector(
                  onTap: () {
                    _controller.stop();
                    Get.offAndToNamed(HomeScreen.routeName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 40),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.deepPurple],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          "Start Game",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
