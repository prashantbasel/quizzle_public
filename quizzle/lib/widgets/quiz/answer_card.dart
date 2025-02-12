import 'package:flutter/material.dart';
import 'package:quizzle/configs/configs.dart';

enum AnswerStatus {
  correct,
  wrong,
  answered,
  notanswered,
}

class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.answer,
    this.isSelected = false,
    required this.onTap,
    this.status, bool? isCorrect, // Added AnswerStatus parameter
  });

  final String answer;
  final bool isSelected;
  final VoidCallback onTap;
  final AnswerStatus? status; // Nullable AnswerStatus

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color textColor = Colors.black; // Default to dark color for visibility

    switch (status) {
      case AnswerStatus.correct:
        borderColor = kCorrectAnswerColor;
        backgroundColor = kCorrectAnswerColor.withOpacity(0.1);
        textColor = Colors.black; // Ensures text is visible
        break;
      case AnswerStatus.wrong:
        borderColor = kWrongAnswerColor;
        backgroundColor = kWrongAnswerColor.withOpacity(0.1);
        textColor = Colors.black;
        break;
      case AnswerStatus.answered:
        borderColor = answerSelectedColor(context);
        backgroundColor = answerSelectedColor(context);
        textColor = Colors.white; // Text is white only if background is dark
        break;
      default:
        borderColor = answerBorderColor(context);
        backgroundColor = Theme.of(context).cardColor;
        textColor = Colors.black; // Ensure readability
    }

    return InkWell(
      borderRadius: UIParameters.cardBorderRadius,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: UIParameters.cardBorderRadius,
          color: backgroundColor,
          border: Border.all(color: borderColor),
        ),
        child: Text(
          answer,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// Correct Answer Card
class CorrectAnswerCard extends StatelessWidget {
  const CorrectAnswerCard({super.key, required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return AnswerCard(
      answer: answer,
      status: AnswerStatus.correct,
      onTap: () {}, // Prevent re-selection
    );
  }
}

// Wrong Answer Card
class WrongAnswerCard extends StatelessWidget {
  const WrongAnswerCard({super.key, required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return AnswerCard(
      answer: answer,
      status: AnswerStatus.wrong,
      onTap: () {}, // Prevent re-selection
    );
  }
}

// Not Answered Card
class NotAnswerCard extends StatelessWidget {
  const NotAnswerCard({super.key, required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return AnswerCard(
      answer: answer,
      status: AnswerStatus.notanswered,
      onTap: () {}, // Prevent re-selection
    );
  }
}
