import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizzle/models/quiz_paper_model.dart';

final CollectionReference quizPaperFR =
    FirebaseFirestore.instance.collection("quizpapers");

class TextConverterPage extends StatefulWidget {
  const TextConverterPage({super.key});

  @override
  _TextConverterPageState createState() => _TextConverterPageState();
}

class QnA {
  final int number;
  final String question;
  final List<String> options;
  final String correctAnswer;

  QnA({
    required this.number,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  @override
  String toString() {
    return 'QnA(number: $number, question: "$question", options: $options, correctAnswer: "$correctAnswer")';
  }
}

List<String> cleanOptions(String rawOptions) {
  // Remove list markers `[*` and `]`
  String cleaned = rawOptions.replaceAll(RegExp(r'^\[\*\s*|\]$'), '').trim();

  // Normalize misplaced `*` or extra spaces
  // cleaned = cleaned.replaceAll(RegExp(r'\*\s*'), '');

  // Split by "a)", "b)", "c)", "d)" while keeping the delimiters
  List<String> options = cleaned.split(RegExp(r'(?=\b[a-d]\)\s)'));

  // Trim and filter out empty entries
  return options
      .map((opt) => opt.trim().split(')').last.trim() ?? "".trim())
      .where((opt) => opt.isNotEmpty)
      .toList();
}

class _TextConverterPageState extends State<TextConverterPage> {
  List<String> quizPaperIds = []; // Store available quiz paper IDs
  String selectedQuizPaper = ""; // Default selected ID
  Future<void> fetchQuizPaperIds() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("quizpapers").get();
      setState(() {
        quizPaperIds = querySnapshot.docs.map((doc) => doc.id).toList();
        selectedQuizPaper = quizPaperIds.isNotEmpty
            ? quizPaperIds.first
            : ""; // Default selection
      });
    } catch (e) {
      print("Error fetching quiz papers: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQuizPaperIds(); // Fetch available quiz papers when page loads
  }

  final TextEditingController _textController = TextEditingController();
  final List<String> _questions = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _selectedDifficulty = "Easy"; // Default difficulty level

  final String geminiApiKey =
      "AIzaSyCiNu7ybOzRS06MbA6NbfZTY-j4E7c9mUE"; // 🔹 Replace with your Gemini API Key

  List<QnA> parseQuestions(String input) {
    // 1. Remove the prefix "I/flutter ( 6953): " if it exists:
    final cleaned =
        input.replaceAll(RegExp(r'I/flutter\s*\(\s*\d+\)\:\s*'), '');

    // 2. Split by two or more newlines to get question blocks:
    final blocks = cleaned.trim().split(RegExp(r'\n\s*\n'));

    List<QnA> questions = [];
    int fallbackCounter = 0;

    for (final block in blocks) {
      // Each block is a set of lines for one question+answer chunk
      final lines = block.trim().split('\n').map((l) => l.trim()).toList();

      // Variables to fill:
      int number = 0;
      String questionText = '';
      List<String> options = [];
      String correctAnswer = '';

      // We'll look for a line that starts with "[number]. "
      // Example: "3.  What kind of data is used by the AI system...?"
      final numberPattern = RegExp(r'^(\d+)\.\s+(.*)$');

      for (final line in lines) {
        // Check if this line contains "X. question text"
        print("line $line");
        final match = numberPattern.firstMatch(line);
        if (match != null) {
          number = int.tryParse(match.group(1) ?? '') ?? 0;
          questionText = match.group(2)?.trim() ?? '';
          continue;
        }

        // Check if this line contains options
        if (line.contains('a) ') || line.startsWith('[*')) {
          options = cleanOptions(line);
          // continue;
        }

        // Check if this line contains the correct answer
        final correctAnswerPattern = RegExp(r'\*\*Correct Answer:\s*(.*?)\*\*');
        final caMatch = correctAnswerPattern.firstMatch(line);
        if (caMatch != null) {
          correctAnswer = caMatch.group(1)?.trim() ?? '';
        }
      }

      // If the snippet is missing the question line (like for question #2),
      // we might never fill 'number' or 'questionText'. Let's handle that:
      if (number == 0 && questionText.isEmpty && options.isNotEmpty) {
        // This block likely belongs to question #2 in the snippet but
        // has no question line. We'll use a fallback:
        fallbackCounter++;
        number = -fallbackCounter; // negative means missing question number
        questionText = 'Question text missing for Q$number';
      }
      print("Exporting");
      print(options);
      print(correctAnswer);
      // Build the QnA object if we have at least options and an answer
      if (options.isNotEmpty && correctAnswer.isNotEmpty) {
        questions.add(QnA(
          number: number,
          question: questionText,
          options: options,
          correctAnswer: correctAnswer,
        ));
      }
    }

    return questions;
  }

  List<QnA> questions = [];

  /// **Generate Quiz Questions using Google Gemini AI**
  Future<void> generateQuestions(String text) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter some text")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _questions.clear();
    });

    try {
      var response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Generate exactly 10 quiz questions with multiple-choice answers on the topic:\n\n $text\n\n Make the questions $_selectedDifficulty level. Also provide the correct answers to each question. Just start with the question and answer."
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseText = data['candidates'][0]['content']["parts"][0]["text"];
        final parsedList = parseQuestions(responseText);
        // print("data");
        // print(parsedList.length);
        // for (var q in parsedList) {
        //   print(q);
        // }
        // This should give us each Q&A block separately.
        // print(questionBlocks);
        setState(() {
          questions = parsedList;
          // _questions = responseText
          //     .split("\n")
          //     .where((q) => q.isNotEmpty)
          //     .map((q) => q.trim())
          //     .take(10) // ✅ Always limit to 10 questions
          //     .toList();
          _isLoading = false;
        });
      } else {
        throw Exception("API Error: ${response.body}");
      }
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      print("Error: $error");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to fetch questions: ${error.toString()}")),
      );
    }
  }

  String makeABC(int num) {
    switch (num) {
      case 0:
        return "A";
      case 1:
        return "B";
      case 2:
        return "C";
      case 3:
        return "D";
      case 4:
        return "E";
      default:
        return "A";
    }
  }

  Future<void> saveQuestions() async {
    // ✅ Step 1: Ensure a quiz paper is selected before proceeding
    if (selectedQuizPaper.isEmpty) {
      print("No quiz paper selected! Please select one.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a quiz paper before saving.")),
      );
      return; // Stop execution if no quiz paper is selected
    }

    // ✅ Step 2: Convert `questions` to `Question` objects
    List<Question> qq = questions
        .map((elem) => Question(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            question: elem.question,
            answers: elem.options
                .asMap()
                .entries
                .map((ans) => Answer(
                    identifier: makeABC(ans.key),
                    answer: elem.options[ans.key]))
                .toList(),
            correctAnswer: elem.correctAnswer.contains(")")
                ? elem.correctAnswer.split(")").first.trim().toUpperCase()
                : elem.correctAnswer.trim().toUpperCase()))
        .toList();

    // ✅ Step 3: Save questions to Firestore
    for (Question q in qq) {
      DocumentReference questionDocRef = await quizPaperFR
          .doc(selectedQuizPaper)
          .collection("questions")
          .add(q.toJson());

      // ✅ Step 4: Save answers inside the question document
      for (Answer answer in q.answers) {
        await questionDocRef
            .collection("answers")
            .doc(answer.identifier)
            .set(answer.toJson());
      }
    }

    print("✅ Questions successfully saved under: $selectedQuizPaper");

    // ✅ Step 5: Show confirmation message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Questions saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Text to Quiz Generator",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Paper Selection Dropdown
              if (quizPaperIds.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Quiz Paper:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: selectedQuizPaper,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              selectedQuizPaper = newValue!;
                            });
                          },
                          items: quizPaperIds
                              .map((id) =>
                                  DropdownMenuItem(value: id, child: Text(id)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(
                  child: Text(
                    "No quiz papers available.",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),

              const SizedBox(height: 20),

              // Text Input for User Prompt
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter Quiz Topic:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Enter your text here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Difficulty Level Selection
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Difficulty Level:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedDifficulty,
                        isExpanded: true,
                        items: ["Easy", "Medium", "Hard"]
                            .map((level) => DropdownMenuItem(
                                value: level, child: Text(level)))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDifficulty = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Buttons for Generate and Save
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => generateQuestions(_textController.text),
                      child: const Text(
                        "Generate Questions",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => saveQuestions(),
                      child: const Text(
                        "Save Questions",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Show Loading Indicator
              if (_isLoading) const Center(child: CircularProgressIndicator()),

              // Show Error Message
              if (_hasError)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Error fetching questions. Try again.",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // Display Generated Questions
              if (questions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Generated Questions:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Q${index + 1}: ${questions[index].question}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    children:
                                        questions[index].options.map((option) {
                                      return ListTile(
                                        leading: const Icon(
                                            Icons.check_circle_outline),
                                        title: Text(option),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No questions generated yet.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
