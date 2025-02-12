import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TextConverterPage extends StatefulWidget {
  const TextConverterPage({super.key});

  @override
  _TextConverterPageState createState() => _TextConverterPageState();
}

class _TextConverterPageState extends State<TextConverterPage> {
  final TextEditingController _textController = TextEditingController();
  List<String> _questions = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _selectedDifficulty = "Easy"; // Default difficulty level

  final String geminiApiKey =
      "AIzaSyCiNu7ybOzRS06MbA6NbfZTY-j4E7c9mUE"; // 🔹 Replace with your Gemini API Key

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
            "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText?key=$geminiApiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "prompt":
              "Generate exactly 10 quiz questions with multiple-choice answers on the topic:\n\n$text\n\n"
                  "Make the questions $_selectedDifficulty level.",
          "temperature": 0.7,
          "max_tokens": 100, // 🔹 Keeps API cost low
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseText = data['candidates'][0]['output'];

        setState(() {
          _questions = responseText
              .split("\n")
              .where((q) => q.isNotEmpty)
              .map((q) => q.trim())
              .take(10) // ✅ Always limit to 10 questions
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception("API Error: ${response.body}");
      }
    } catch (error) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text to Quiz Generator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text Input Field
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Enter your text here...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Difficulty Selection Dropdown
            DropdownButton<String>(
              value: _selectedDifficulty,
              items: ["Easy", "Medium", "Hard"]
                  .map((level) =>
                      DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedDifficulty = newValue!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Generate Button
            ElevatedButton(
              onPressed: () => generateQuestions(_textController.text),
              child: const Text("Generate Questions"),
            ),

            const SizedBox(height: 20),

            // Show Loading Indicator
            if (_isLoading) const CircularProgressIndicator(),

            // Show Error Message
            if (_hasError)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Error fetching questions. Try again.",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),

            // Display Generated Questions
            Expanded(
              child: _questions.isEmpty && !_isLoading
                  ? const Center(child: Text("No questions generated yet"))
                  : ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.question_mark),
                          title: Text(_questions[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
