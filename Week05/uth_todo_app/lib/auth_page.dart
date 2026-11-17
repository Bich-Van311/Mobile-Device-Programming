import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _registering = false;
  bool _showEmail = false;
  bool _hidePassword = true;

  static const blue = Color(0xFF3157E9);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _execute(
    Future<UserCredential> Function() action,
    String message,
  ) async {
    if (_loading) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() => _loading = true);

    try {
      await action();

      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_auth.errorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra. Vui lòng thử lại.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _submitEmail() {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();
    final password = _password.text;

    _execute(
      () => _registering
          ? _auth.registerWithEmail(email, password)
          : _auth.signInWithEmail(email, password),
      _registering ? 'Đăng ký thành công!' : 'Đăng nhập thành công!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: blue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Chào mừng đến với\nUTH Todo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Đăng nhập để lưu công việc và '
                    'đồng bộ trên các thiết bị.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 36),
                  OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _execute(
                            _auth.signInWithGoogle,
                            'Đăng nhập thành công!',
                          ),
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    label: const Text('Tiếp tục với Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _showEmail = !_showEmail),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Tiếp tục với Email'),
                  ),
                  if (_showEmail) ...[
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập mật khẩu';
                              }
                              if (_registering && value.length < 6) {
                                return 'Ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _loading ? null : _submitEmail,
                              child: Text(
                                _registering ? 'Đăng ký' : 'Đăng nhập',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(
                                    () => _registering = !_registering,
                                  ),
                            child: Text(
                              _registering
                                  ? 'Đã có tài khoản? Đăng nhập'
                                  : 'Chưa có tài khoản? Đăng ký',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.all(12), child: Text('hoặc')),
                      Expanded(child: Divider()),
                    ],
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => _execute(
                            _auth.signInAnonymously,
                            'Đã vào chế độ dùng thử!',
                          ),
                    child: const Text('Dùng thử không cần tài khoản'),
                  ),
                  if (_loading) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
