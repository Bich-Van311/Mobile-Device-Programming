import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xếp loại học lực',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const GradePage(),
    );
  }
}

class GradePage extends StatelessWidget {
  const GradePage({super.key});

  // Hàm xếp loại bằng if / else
  String classifyGrade(double score) {
    if (score < 0 || score > 10) {
      return 'Không hợp lệ';
    } else if (score >= 8.0) {
      return 'Giỏi';
    } else if (score >= 6.5) {
      return 'Khá';
    } else if (score >= 5.0) {
      return 'Trung bình';
    } else {
      return 'Yếu';
    }
  }

  // Chọn màu chữ bằng if
  Color getGradeColor(String grade) {
    if (grade == 'Giỏi') {
      return Colors.green;
    } else if (grade == 'Khá') {
      return Colors.blue;
    } else if (grade == 'Trung bình') {
      return Colors.orange;
    } else if (grade == 'Yếu') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  // Màu nền cho ô xếp loại
  Color getGradeBackground(String grade) {
    if (grade == 'Giỏi') {
      return Colors.green.shade50;
    } else if (grade == 'Khá') {
      return Colors.blue.shade50;
    } else if (grade == 'Trung bình') {
      return Colors.orange.shade50;
    } else if (grade == 'Yếu') {
      return Colors.red.shade50;
    } else {
      return Colors.grey.shade200;
    }
  }

  Widget buildTestRow(double score) {
    final String grade = classifyGrade(score);

    String scoreText;

    if (score % 1 == 0) {
      scoreText = score.toInt().toString();
    } else {
      scoreText = score.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Điểm $scoreText',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: getGradeBackground(grade),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              grade,
              style: TextStyle(
                color: getGradeColor(grade),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double mainScore = 8.5;
    final String mainGrade = classifyGrade(mainScore);

    final List<double> testScores = [
      9,
      7,
      5.5,
      3,
      11,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF31588F),
        elevation: 0,
        title: const Text(
          'Xếp loại học lực',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Điểm trung bình',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '8.5',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: getGradeBackground(mainGrade),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mainGrade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: getGradeColor(mainGrade),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'KIỂM TRA THÊM',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  for (final score in testScores)
                    buildTestRow(score),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}