import 'package:flutter/material.dart';

class ColumnDetailPage extends StatelessWidget {
  const ColumnDetailPage({super.key});

  Widget box(Color color) {
    return Container(
      width: 150,
      height: 65,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Column Layout',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            box(Colors.blue.shade200),
            box(Colors.blue),
            box(Colors.blue.shade200),
            box(Colors.blue),
          ],
        ),
      ),
    );
  }
}