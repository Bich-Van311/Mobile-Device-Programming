import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'reset_data.dart';

const resetBlue = Color(0xFF159BE8);
const demoOtp = '123456';

// Khung giao diện dùng chung cho 4 màn.
class ResetLayout extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const ResetLayout({
    super.key,
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              children: [
                const Text(
                  'UTH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087F83),
                  ),
                ),
                const Text(
                  'UNIVERSITY OF TRANSPORT\nHO CHI MINH CITY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'SmartTasks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: resetBlue,
                  ),
                ),
                const SizedBox(height: 38),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ResetButton({super.key, this.label = 'Next', required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: resetBlue),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// MÀN 1: nhập email và nhận kết quả từ luồng phía sau.
class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  ResetData? _result;

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final data = ResetData(email: _emailController.text.trim());

    final result = await Navigator.of(context).push<ResetData>(
      MaterialPageRoute<ResetData>(builder: (_) => VerifyPage(data: data)),
    );

    if (!mounted || result == null) return;

    setState(() => _result = result);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return ResetLayout(
      title: 'Forget Password?',
      description: 'Enter your email to start the demo.',
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline),
              hintText: 'Your Email',
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(email);

              return valid ? null : 'Nhập email hợp lệ.';
            },
          ),
        ),
        const SizedBox(height: 24),
        ResetButton(onPressed: _next),
        if (result != null) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Dữ liệu nhận từ màn Confirm:\n\n'
              'Email: ${result.email}\n'
              'OTP: ${result.otp}\n'
              'Mật khẩu: ${'•' * result.password.length}\n'
              'Độ dài: ${result.password.length} ký tự',
            ),
          ),
        ],
      ],
    );
  }
}

// MÀN 2: nhận email, nhập OTP và truyền tiếp.
class VerifyPage extends StatefulWidget {
  final ResetData data;

  const VerifyPage({super.key, required this.data});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _code => _controllers.map((controller) => controller.text).join();

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final nextData = widget.data.copyWith(otp: _code);

    final result = await Navigator.of(context).push<ResetData>(
      MaterialPageRoute<ResetData>(
        builder: (_) => PasswordPage(data: nextData),
      ),
    );

    if (!mounted || result == null) return;

    // Nhận kết quả cuối và trả tiếp về EmailPage.
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResetLayout(
      title: 'Verify Code',
      description:
          'Email: ${widget.data.email}\n'
          'OTP demo: $demoOtp — không gửi email thật.',
      children: [
        Form(
          key: _formKey,
          child: FormField<String>(
            validator: (_) => _code == demoOtp ? null : 'OTP demo là $demoOtp.',
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(6, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == 5 ? 0 : 6),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                            ),
                            onChanged: (value) {
                              field.didChange(_code);

                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        field.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        ResetButton(onPressed: _next),
      ],
    );
  }
}

// MÀN 3: nhận email + OTP, thêm mật khẩu.
class PasswordPage extends StatefulWidget {
  final ResetData data;

  const PasswordPage({super.key, required this.data});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hidden = true;

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final nextData = widget.data.copyWith(password: _passwordController.text);

    final result = await Navigator.of(context).push<ResetData>(
      MaterialPageRoute<ResetData>(builder: (_) => ConfirmPage(data: nextData)),
    );

    if (!mounted || result == null) return;

    // Nhận kết quả từ Confirm và trả về VerifyPage.
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResetLayout(
      title: 'Create new password',
      description: 'Nhập mật khẩu demo có ít nhất 8 ký tự.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _hidden,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _hidden = !_hidden);
                    },
                    icon: Icon(
                      _hidden ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Mật khẩu cần ít nhất 8 ký tự.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _hidden,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận chưa khớp.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResetButton(onPressed: _next),
      ],
    );
  }
}

// MÀN 4: nhận đủ dữ liệu, Submit để trả về.
class ConfirmPage extends StatelessWidget {
  final ResetData data;

  const ConfirmPage({super.key, required this.data});

  Widget _field(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(prefixIcon: Icon(icon)),
        child: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResetLayout(
      title: 'Confirm',
      description: 'Kiểm tra dữ liệu trước khi trả về màn đầu.',
      children: [
        _field(Icons.person_outline, data.email),
        _field(Icons.mail_outline, data.otp),
        _field(Icons.lock_outline, '•' * data.password.length),
        const SizedBox(height: 12),
        ResetButton(
          label: 'Submit',
          onPressed: () {
            Navigator.of(context).pop(data);
          },
        ),
      ],
    );
  }
}
