class ResetData {
  final String email;
  final String otp;
  final String password;

  const ResetData({required this.email, this.otp = '', this.password = ''});

  ResetData copyWith({String? otp, String? password}) {
    return ResetData(
      email: email,
      otp: otp ?? this.otp,
      password: password ?? this.password,
    );
  }
}
