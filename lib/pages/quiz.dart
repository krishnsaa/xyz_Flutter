import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'authProvider.dart';

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String parsedId = "";
    if (json['_id'] is Map) {
      parsedId = json['_id']['\$oid']?.toString() ?? json['_id'].toString();
    } else {
      parsedId = json['_id']?.toString() ?? '';
    }

    List<String> parsedOptions = [];
    if (json['options'] is List) {
      for (var opt in json['options']) {
        if (opt is String) {
          parsedOptions.add(opt);
        } else if (opt is Map) {
          parsedOptions.add(
            opt['text']?.toString() ?? opt.values.first.toString(),
          );
        } else {
          parsedOptions.add(opt.toString());
        }
      }
    }

    int parsedIndex = 0;
    if (json['correctIndex'] is int) {
      parsedIndex = json['correctIndex'];
    } else {
      parsedIndex = int.tryParse(json['correctIndex']?.toString() ?? '0') ?? 0;
    }

    return Question(
      id: parsedId,
      text: json['text']?.toString() ?? 'Unknown Question',
      options: parsedOptions,
      correctIndex: parsedIndex,
    );
  }
}

enum AnswerState { idle, correct, wrong }

class QuizModel extends ChangeNotifier {
  final String baseUrl;
  final String userId;
  final String token;
  final String domain;
  final VoidCallback onQuizComplete;

  List<Question> questions = [];
  bool isLoading = true;
  bool hasError = false;
  int currentIndex = 0;
  AnswerState answerState = AnswerState.idle;
  bool isLocked = false;
  static const int timeLimit = 20;
  int timeLeft = timeLimit;
  Timer? _countdownTimer;
  late DateTime _questionStartTime;
  bool _isDisposed = false;

  QuizModel({
    required this.baseUrl,
    required this.userId,
    required this.token,
    required this.domain,
    required this.onQuizComplete,
  }) {
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final String url = '$baseUrl/quiz/start?domain=$domain';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        questions = data.map((json) => Question.fromJson(json)).toList();
        isLoading = false;

        if (!_isDisposed) notifyListeners();

        if (questions.isNotEmpty) {
          _startNewQuestion();
        } else {
          hasError = true;
        }
      } else {
        hasError = true;
        isLoading = false;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      hasError = true;
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void _startNewQuestion() {
    _questionStartTime = DateTime.now();
    timeLeft = timeLimit;
    isLocked = false;
    answerState = AnswerState.idle;
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isLocked) {
        timer.cancel();
        return;
      }
      if (timeLeft == 0) {
        timer.cancel();
        handleTimeout();
      } else {
        timeLeft--;
        if (!_isDisposed) notifyListeners();
      }
    });
  }

  void handleTimeout() {
    isLocked = true;
    answerState = AnswerState.wrong;
    if (!_isDisposed) notifyListeners();
    _submitAnswer(false, timeLimit * 1000);
    moveToNextQuestionAfterDelay();
  }

  void handleAnswer(int optionIndex) {
    if (isLocked) return;
    _countdownTimer?.cancel();
    final int reactionTimeMs = DateTime.now()
        .difference(_questionStartTime)
        .inMilliseconds;
    final bool isCorrect = optionIndex == questions[currentIndex].correctIndex;
    isLocked = true;
    answerState = isCorrect ? AnswerState.correct : AnswerState.wrong;
    if (!_isDisposed) notifyListeners();
    _submitAnswer(isCorrect, reactionTimeMs);
    moveToNextQuestionAfterDelay();
  }

  Future<void> _submitAnswer(bool correct, int reactionTimeMs) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/session/answer'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "userId": userId,
          "questionId": questions[currentIndex].id,
          "correct": correct,
          "reactionTimeMs": reactionTimeMs,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {}
    } catch (e) {
      print(e);
    }
  }

  void moveToNextQuestionAfterDelay() {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (_isDisposed) return;
      if (currentIndex + 1 >= questions.length) {
        onQuizComplete();
        return;
      }
      currentIndex++;
      _startNewQuestion();
      if (!_isDisposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer?.cancel();
    super.dispose();
  }
}

class QuizScreen extends StatefulWidget {
  final String domain;
  const QuizScreen({super.key, required this.domain});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final realUserId =
        Provider.of<AuthProvider>(context, listen: false).userId ?? "";
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? "";

    return ChangeNotifierProvider(
      create: (context) => QuizModel(
        baseUrl: "https://xyz-backend-ow16.onrender.com",
        userId: realUserId,
        token: token,
        domain: widget.domain,
        onQuizComplete: () {
          if (mounted) Navigator.pop(context);
        },
      ),
      child: Consumer<QuizModel>(
        builder: (context, quizModel, child) {
          if (quizModel.isLoading) {
            return const Scaffold(
              body: Center(
                child: Text("Loading quiz...", style: TextStyle(fontSize: 16)),
              ),
            );
          }
          if (quizModel.hasError || quizModel.questions.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "No questions found",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final currentQuestion = quizModel.questions[quizModel.currentIndex];
          final double progressPercent =
              (quizModel.currentIndex + 1) / quizModel.questions.length;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Questions'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "⏰ ${quizModel.timeLeft}s",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: quizModel.timeLeft <= 5
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF38474E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressPercent,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF22C55E)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, 0.15),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          child: Column(
                            key: ValueKey<String>(currentQuestion.id),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentQuestion.text,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...List.generate(currentQuestion.options.length, (
                                i,
                              ) {
                                Color btnColor = const Color(0xFF334155);
                                if (quizModel.isLocked) {
                                  if (i == currentQuestion.correctIndex) {
                                    btnColor = const Color(0xFF22C55E);
                                  } else if (quizModel.answerState ==
                                      AnswerState.wrong) {
                                    btnColor = const Color(0xFFEF4444);
                                  }
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: InkWell(
                                      onTap: quizModel.isLocked
                                          ? null
                                          : () => quizModel.handleAnswer(i),
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: btnColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            currentQuestion.options[i],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              Text(
                                "Question ${quizModel.currentIndex + 1} of ${quizModel.questions.length}",
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
