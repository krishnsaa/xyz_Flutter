import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'authProvider.dart';
import 'quiz.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? summary;
  List<String> badges = [];
  bool isLoading = true;
  String? selectedDomain;
  final String baseUrl = "https://xyz-backend-ow16.onrender.com";

  final List<Map<String, String>> domains = [
    {"value": "c", "label": "C Programming"},
    {"value": "cpp", "label": "C++ Programming"},
    {"value": "java", "label": "Java"},
    {"value": "dsa", "label": "Data Structures & Algorithms"},
    {"value": "ai", "label": "Artificial Intelligence"},
    {"value": "python", "label": "Python"},
    {"value": "data_analytics", "label": "Data Analytics"},
    {"value": "react", "label": "React"},
    {"value": "mern", "label": "MERN Stack"},
    {"value": "java_app_dev", "label": "Java Application Development"},
    {"value": "flutter", "label": "Flutter"},
  ];

  final Map<String, List<String>> motivationQuotes = {
    'start': [
      "Every expert was once a beginner 🔥",
      "Start today. Progress follows 🌱",
    ],
    'low': ["Progress beats perfection 💙", "Effort builds mastery 🚶‍♂️"],
    'mid': [
      "Great progress — keep pushing 🚀",
      "Consistency is your strength 📈",
    ],
    'high': ["Excellent accuracy! 🎯", "You’re mastering this 🏆"],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? "";

    if (userId == null) return;

    try {
      // 1. Change to http.get (Matching your React code)
      final summaryResponse = await http.get(
        Uri.parse('$baseUrl/dashboard/summary'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final badgesResponse = await http.get(
        Uri.parse('$baseUrl/dashboard/badges'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (summaryResponse.statusCode != 200) {}

      if (mounted) {
        setState(() {
          if (summaryResponse.statusCode == 200) {
            summary = jsonDecode(summaryResponse.body);
          } else {
            summary = {"totalXP": 0, "accuracy": 0.0, "avgReactionTime": 0};
          }

          if (badgesResponse.statusCode == 200) {
            final badgeData = jsonDecode(badgesResponse.body);
            badges = List<String>.from(badgeData['earned'] ?? []);
          }

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          summary = {"totalXP": 0, "accuracy": 0.0, "avgReactionTime": 0};
          isLoading = false;
        });
      }
    }
  }

  String getQuote() {
    if (summary == null) return "";
    double acc =
        double.tryParse(summary!['accuracy']?.toString() ?? '0') ?? 0.0;

    List<String> pool;
    if (acc == 0) {
      pool = motivationQuotes['start']!;
    } else if (acc < 50) {
      pool = motivationQuotes['low']!;
    } else if (acc < 90) {
      pool = motivationQuotes['mid']!;
    } else {
      pool = motivationQuotes['high']!;
    }

    return pool[Random().nextInt(pool.length)];
  }

  void startQuiz() {
    if (selectedDomain != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(domain: selectedDomain!),
        ),
      ).then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _loadDashboardData();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFFCBD5F5),
                        width: 3,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDomain,
                        hint: const Text("Select domain"),
                        isExpanded: true,
                        items: domains.map((d) {
                          return DropdownMenuItem(
                            value: d['value'],
                            child: Text(
                              d['label']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedDomain = val),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: selectedDomain == null ? null : startQuiz,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Start Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: "⭐ Total XP",
                  value: "${summary?['totalXP'] ?? 0}",
                ),
                StatCard(
                  title: "🎯 Accuracy",
                  value:
                      "${(double.tryParse(summary?['accuracy']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1)}%",
                ),
                StatCard(
                  title: "⏱ Avg Reaction",
                  value:
                      "${double.tryParse(summary?['avgReactionTime']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'} ms",
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              "🏅 Badges",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: badges.isEmpty
                  ? [const Text("No badges yet")]
                  : badges.map((b) => BadgeWidget(text: b)).toList(),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0F9FF), Color(0xFFEEF2FF)],
                ),
              ),
              child: Text(
                "💡 ${getQuote()}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String text;
  const BadgeWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
