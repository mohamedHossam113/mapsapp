class AuthResponse {
  final String status;
  final String token;

  AuthResponse({required this.status, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token,
    };
  }
}
