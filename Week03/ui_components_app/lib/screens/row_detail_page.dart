import 'package:flutter/material.dart';

class RowDetailPage extends StatelessWidget {
  const RowDetailPage({super.key});

  Widget box(Color color) {
    return Expanded(
      child: Container(
        height: 55,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Row Layout',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                box(Colors.blue.shade200),
                box(Colors.blue),
                box(Colors.blue.shade200),
              ],
            ),

            Row(
              children: [
                box(Colors.blue.shade200),
                box(Colors.blue),
                box(Colors.blue.shade200),
              ],
            ),

            Row(
              children: [
                box(Colors.blue.shade200),
                box(Colors.blue),
                box(Colors.blue.shade200),
              ],
            ),

            Row(
              children: [
                box(Colors.blue.shade200),
                box(Colors.blue),
                box(Colors.blue.shade200),
              ],
            ),
          ],
        ),
      ),
    );
  }
}