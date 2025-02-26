class TwoFactorResponseModel {
  final String? accessToken;
  final String? refreshToken;
  final bool requiresTwoFactor;
  final String? tempToken;
  final String? userId;

  TwoFactorResponseModel({
    this.accessToken,
    this.refreshToken,
    this.requiresTwoFactor = false,
    this.tempToken,
    this.userId,
  });

  factory TwoFactorResponseModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorResponseModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      tempToken: json['tempToken'],
      userId: json['user']?['_id'],
    );
  }
}