import 'package:flutter/material.dart';

class TextFieldDetailPage extends StatefulWidget {
  const TextFieldDetailPage({super.key});

  @override
  State<TextFieldDetailPage> createState() =>
      _TextFieldDetailPageState();
}

class _TextFieldDetailPageState
    extends State<TextFieldDetailPage> {
  String inputText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TextField',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 100),

            TextField(
              decoration: InputDecoration(
                hintText: 'Thông tin nhập',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'Tự động cập nhật dữ liệu theo TextField',
              style: TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              inputText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}