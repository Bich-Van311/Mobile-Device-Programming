import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Student có name bắt buộc
// score có thể null
class Student {
  final String name;
  final double? score;

  Student({
    required this.name,
    this.score,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bảng điểm lớp',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const ClassGradePage(),
    );
  }
}

class ClassGradePage extends StatelessWidget {
  const ClassGradePage({super.key});

  // Hàm xếp loại dùng lại logic bài trước
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

  // Chọn màu theo xếp loại
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

  @override
  Widget build(BuildContext context) {
    // Danh sách 5 sinh viên theo đề
    final List<Student> students = [
      Student(
        name: 'Nguyễn Văn An',
        score: 9.0,
      ),
      Student(
        name: 'Trần Thị Bình',
        score: 7.2,
      ),
      Student(
        name: 'Lê Minh Chi',
        score: null,
      ),
      Student(
        name: 'Phạm Quốc Dũng',
        score: 4.5,
      ),
      Student(
        name: 'Võ Thanh Em',
        score: 5.8,
      ),
    ];

    // Các biến thống kê
    double totalScore = 0;
    int scoredStudentCount = 0;
    int excellentCount = 0;
    int noScoreCount = 0;
    double highestScore = 0;

    // Dùng for + if để tính toán
    for (final student in students) {
      if (student.score == null) {
        noScoreCount++;
      } else {
        final double score = student.score!;

        totalScore += score;
        scoredStudentCount++;

        if (score >= 8.0) {
          excellentCount++;
        }

        if (score > highestScore) {
          highestScore = score;
        }
      }
    }

    // Điểm trung bình - bỏ qua người chưa có điểm
    final double average =
        scoredStudentCount > 0 ? totalScore / scoredStudentCount : 0;

    // Dùng for để tạo thẻ sinh viên
    final List<Widget> studentCards = [];

    for (final student in students) {
      String grade;
      String scoreText;
      Color gradeColor;

      if (student.score == null) {
        grade = 'Chưa có điểm';
        scoreText = '—';
        gradeColor = Colors.grey;
      } else {
        grade = classifyGrade(student.score!);
        scoreText = student.score!.toStringAsFixed(1);
        gradeColor = getGradeColor(grade);
      }

      studentCards.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 12,
                      color: gradeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                scoreText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: student.score == null
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF31588F),
        elevation: 0,
        title: const Text(
          'Bảng điểm lớp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khung thống kê phía trên
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF31588F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Điểm trung bình lớp',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    average.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 1,
                    color: Colors.white24,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giỏi',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '$excellentCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chưa có điểm',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '$noScoreCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cao nhất',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            highestScore.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'DANH SÁCH · ${students.length} SINH VIÊN',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...studentCards,
          ],
        ),
      ),
    );
  }
}