import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const FlashcardApp());
}

class Flashcard {
  String question;
  String answer;
  String category;

  Flashcard({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---------------- DATA ----------------
  List<Flashcard> allFlashcards = [
    Flashcard(question: "What is Flutter?", answer: "flutter", category: "Tech"),
    Flashcard(question: "Capital of India?", answer: "delhi", category: "GK"),
    Flashcard(question: "What is HR?", answer: "human resource", category: "Non-Tech"),
  ];

  List<Flashcard> quizCards = [];
  final List<String> categories = ["Tech", "Non-Tech", "GK"];
  String? selectedCategory;

  bool testMode = false;
  bool showAnswer = false;
  bool quizFinished = false;
  bool answerSubmitted = false; // ✅ added

  int currentIndex = 0;
  int score = 0;

  final TextEditingController userAnswerController = TextEditingController();

  // ---------------- TEST MODE LOGIC ----------------
  void startQuiz() {
    quizCards = allFlashcards
        .where((c) => c.category == selectedCategory)
        .toList()
      ..shuffle(Random());

    setState(() {
      currentIndex = 0;
      score = 0;
      quizFinished = false;
      showAnswer = false;
      answerSubmitted = false;
      userAnswerController.clear();
    });
  }

  void checkAnswer() {
    if (userAnswerController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Answer Required"),
          content: const Text("Please enter your answer first"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    if (!answerSubmitted) {
      if (userAnswerController.text.trim().toLowerCase() ==
          quizCards[currentIndex].answer.toLowerCase()) {
        score++;
      }
    }

    setState(() {
      answerSubmitted = true;
      showAnswer = true;
    });
  }

  void nextCard() {
    if (currentIndex < quizCards.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
        answerSubmitted = false;
        userAnswerController.clear();
      });
    } else {
      setState(() => quizFinished = true);
    }
  }

  void resetQuiz() {
    setState(() {
      selectedCategory = null;
      quizFinished = false;
      quizCards.clear();
    });
  }

  // ---------------- CRUD ----------------
  void addOrEditCard({Flashcard? card, int? index}) {
    final qController = TextEditingController(text: card?.question ?? "");
    final aController = TextEditingController(text: card?.answer ?? "");
    String selectedCat = card?.category ?? categories.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(card == null ? "Add Flashcard" : "Edit Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedCat,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => selectedCat = val!,
            ),
            TextField(
              controller: qController,
              decoration: const InputDecoration(labelText: "Question"),
            ),
            TextField(
              controller: aController,
              decoration: const InputDecoration(labelText: "Answer"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (qController.text.isEmpty || aController.text.isEmpty) return;

              setState(() {
                if (index != null) {
                  allFlashcards[index] = Flashcard(
                    question: qController.text,
                    answer: aController.text,
                    category: selectedCat,
                  );
                } else {
                  allFlashcards.add(Flashcard(
                    question: qController.text,
                    answer: aController.text,
                    category: selectedCat,
                  ));
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void deleteCard(int index) {
    setState(() {
      allFlashcards.removeAt(index);
      currentIndex = 0;
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(testMode ? "Test Mode" : "Flashcards"),
        actions: [
          Switch(
            value: testMode,
            onChanged: (val) {
              setState(() {
                testMode = val;
                resetQuiz();
              });
            },
          ),
          if (!testMode && allFlashcards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  addOrEditCard(card: allFlashcards[currentIndex], index: currentIndex),
            ),
          if (!testMode && allFlashcards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteCard(currentIndex),
            ),
          if (!testMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => addOrEditCard(),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6a11cb), Color(0xff2575fc)],
          ),
        ),
        child: SafeArea(
          child: testMode ? testModeUI() : browseModeUI(),
        ),
      ),
    );
  }

  // ---------------- BROWSE MODE ----------------
  Widget browseModeUI() {
    if (allFlashcards.isEmpty) {
      return const Center(
        child: Text("No flashcards",
            style: TextStyle(color: Colors.white, fontSize: 20)),
      );
    }

    final card = allFlashcards[currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(card.category, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    showAnswer ? card.answer : card.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => showAnswer = !showAnswer),
            child: const Text("Show Answer"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex =
                        (currentIndex - 1 + allFlashcards.length) %
                            allFlashcards.length;
                    showAnswer = false;
                  });
                },
                child: const Text("Previous"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex =
                        (currentIndex + 1) % allFlashcards.length;
                    showAnswer = false;
                  });
                },
                child: const Text("Next"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- TEST MODE ----------------
  Widget testModeUI() {
    if (selectedCategory == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Select Quiz Category",
              style: TextStyle(color: Colors.white, fontSize: 24)),
          ...categories.map((c) => RadioListTile(
            title: Text(
              c,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            value: c,
            groupValue: selectedCategory,
            onChanged: (val) {
              selectedCategory = val;
              startQuiz();
            },
          )),
        ],
      );
    }

    if (quizFinished) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Score: $score / ${quizCards.length}",
                    style: const TextStyle(fontSize: 24)),
                ElevatedButton(
                    onPressed: resetQuiz, child: const Text("Back")),
              ],
            ),
          ),
        ),
      );
    }

    final card = quizCards[currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                showAnswer ? card.answer : card.question,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: userAnswerController,
            enabled: !answerSubmitted,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your answer",
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: checkAnswer,
              child: const Text("Show Answer")),
          ElevatedButton(onPressed: nextCard, child: const Text("Next")),
        ],
      ),
    );
  }
}
