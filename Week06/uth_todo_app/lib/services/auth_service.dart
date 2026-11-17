import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();

    provider.setCustomParameters({'prompt': 'select_account'});

    if (kIsWeb) {
      return await _auth.signInWithPopup(provider);
    }

    return await _auth.signInWithProvider(provider);
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String errorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu chưa đủ mạnh.';
      case 'network-request-failed':
        return 'Không thể kết nối Internet.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
      case 'web-context-canceled':
        return 'Bạn đã hủy đăng nhập.';
      case 'popup-blocked':
        return 'Trình duyệt đã chặn cửa sổ đăng nhập.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật.';
      case 'unauthorized-domain':
        return 'Tên miền chưa được cấp quyền.';
      case 'account-exists-with-different-credential':
        return 'Email đã sử dụng phương thức đăng nhập khác.';
      default:
        return 'Xác thực thất bại (${error.code}).';
    }
  }
}
