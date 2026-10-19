import 'package:flutter/material.dart';

class TextDetailPage extends StatelessWidget {
  const TextDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Text Detail',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 12,
            children: [
              Text(
                'The',
                style: TextStyle(fontSize: 28),
              ),

              Text(
                'quick',
                style: TextStyle(
                  fontSize: 28,
                  decoration: TextDecoration.lineThrough,
                ),
              ),

              Text(
                'Brown',
                style: TextStyle(
                  fontSize: 34,
                  color: Colors.orange,
                ),
              ),

              Text(
                'fox',
                style: TextStyle(fontSize: 28),
              ),

              Text(
                'j u m p s',
                style: TextStyle(
                  fontSize: 25,
                  letterSpacing: 3,
                ),
              ),

              Text(
                'over',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),

              Text(
                'the',
                style: TextStyle(
                  fontSize: 28,
                  decoration: TextDecoration.underline,
                ),
              ),

              Text(
                'lazy',
                style: TextStyle(
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                ),
              ),

              Text(
                'dog.',
                style: TextStyle(fontSize: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}