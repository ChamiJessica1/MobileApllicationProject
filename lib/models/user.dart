class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      token: json['token'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'token': token,
    };
  }
}
