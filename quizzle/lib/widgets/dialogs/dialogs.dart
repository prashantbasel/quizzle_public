import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  /// **📢 Quiz Start Dialog**
  static Future<bool> quizStartDialog({required VoidCallback onTap}) async {
    bool result = await Get.dialog(
      AlertDialog(
        title: const Text("Start Quiz"),
        content: const Text("Are you ready to start the quiz?"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onTap(); // Execute the tap function
              Get.back(result: true);
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
    return result;
  }

  /// **📢 Quiz End Dialog**
  static Future<bool> quizEndDialog() async {
    bool result = await Get.dialog(
      AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("Do you want to exit the quiz without completing it?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return result;
  }
}
