class AuthenticationModel {
  final String accessToken;
  final String jwtToken;
  final int expiresIn;

  AuthenticationModel({required this.accessToken, required this.jwtToken, required this.expiresIn});

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(accessToken: json['access_token'] as String, jwtToken: json['jwt_token'] as String, expiresIn: json['expires_in'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'jwt_token': jwtToken, 'expires_in': expiresIn};
  }
}
