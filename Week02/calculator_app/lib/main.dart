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
      title: 'Thực hành 03',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController number1Controller = TextEditingController();
  final TextEditingController number2Controller = TextEditingController();

  String selectedOperator = '';
  String result = '';

  void calculate(String operator) {
    final double? number1 = double.tryParse(number1Controller.text);
    final double? number2 = double.tryParse(number2Controller.text);

    setState(() {
      selectedOperator = operator;

      if (number1 == null || number2 == null) {
        result = '';
        return;
      }

      double value;

      switch (operator) {
        case '+':
          value = number1 + number2;
          break;
        case '-':
          value = number1 - number2;
          break;
        case '*':
          value = number1 * number2;
          break;
        case '/':
          if (number2 == 0) {
            result = 'Không thể chia cho 0';
            return;
          }
          value = number1 / number2;
          break;
        default:
          return;
      }

      if (value % 1 == 0) {
        result = value.toInt().toString();
      } else {
        result = value.toStringAsFixed(2);
      }
    });
  }

  Widget operationButton({
    required String text,
    required Color color,
  }) {
    final bool isSelected = selectedOperator == text;

    return GestureDetector(
      onTap: () => calculate(text),
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
          border: isSelected
              ? Border.all(
                  color: Colors.black,
                  width: 3,
                )
              : null,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  void dispose() {
    number1Controller.dispose();
    number2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 110),

              const Text(
                'Thực hành 03',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 65),

              TextField(
                controller: number1Controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: inputDecoration(),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  operationButton(
                    text: '+',
                    color: Colors.red,
                  ),
                  operationButton(
                    text: '-',
                    color: Colors.orange,
                  ),
                  operationButton(
                    text: '*',
                    color: Colors.deepPurple,
                  ),
                  operationButton(
                    text: '/',
                    color: Colors.black87,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: number2Controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: inputDecoration(),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  result.isEmpty
                      ? 'Kết quả:'
                      : 'Kết quả: $result',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}