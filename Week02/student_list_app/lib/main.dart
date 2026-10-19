import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Class Student
class Student {
  final String name;
  final String? email;
  final String? phone;

  Student({
    required this.name,
    this.email,
    this.phone,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Danh sách sinh viên',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const StudentListPage(),
    );
  }
}

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách 5 sinh viên
    final List<Student> students = [
      Student(
        name: 'Nguyễn Văn An',
        email: 'an@sv.edu.vn',
        phone: '0901 234 567',
      ),
      Student(
        name: 'Trần Thị Bình',
        email: null,
        phone: '0912 888 999',
      ),
      Student(
        name: 'Lê Minh Chi',
        email: 'chi@sv.edu.vn',
        phone: null,
      ),
      Student(
        name: 'Phạm Quốc Dũng',
        email: null,
        phone: null,
      ),
      Student(
        name: 'Võ Thanh Em',
        email: 'em@sv.edu.vn',
        phone: '0933 111 222',
      ),
    ];

    // Dùng for để đếm số sinh viên thiếu email
    int missingEmailCount = 0;

    for (final student in students) {
      if (student.email == null) {
        missingEmailCount++;
      }
    }

    // Dùng for để tạo các thẻ sinh viên
    final List<Widget> studentWidgets = [];

    for (final student in students) {
      studentWidgets.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Text(
                    'Email: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    student.email ?? 'Chưa cập nhật',
                    style: TextStyle(
                      fontSize: 13,
                      color: student.email == null
                          ? Colors.red
                          : Colors.black54,
                      fontStyle: student.email == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  const Text(
                    'SĐT: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    student.phone ?? 'Chưa cập nhật',
                    style: TextStyle(
                      fontSize: 13,
                      color: student.phone == null
                          ? Colors.red
                          : Colors.black54,
                      fontStyle: student.phone == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
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
          'Danh sách sinh viên',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            ...studentWidgets,

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE1EAF5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tổng: ',
                        style: TextStyle(
                          color: Color(0xFF31588F),
                        ),
                      ),
                      Text(
                        '${students.length} sinh viên',
                        style: const TextStyle(
                          color: Color(0xFF31588F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Text(
                        'Thiếu email: ',
                        style: TextStyle(
                          color: Color(0xFF31588F),
                        ),
                      ),
                      Text(
                        '$missingEmailCount',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}