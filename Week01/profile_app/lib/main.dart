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
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                ]
              ),

              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 60, 
                backgroundImage: AssetImage('assets/avatar_meowbakhi.png'),
              ),

              const SizedBox(height: 20),

              const Text(
                'Trương Bích Vân',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
              ),
              
              const SizedBox(height: 10),

              const Text(
                '068303009740', style: TextStyle(fontSize:16,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}