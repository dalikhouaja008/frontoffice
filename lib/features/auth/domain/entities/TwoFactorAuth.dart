class TwoFactorAuth {
  final String? qrCodeUrl;
  final bool isEnabled;
  final String? tempToken;

  const TwoFactorAuth({
    this.qrCodeUrl,
    this.isEnabled = false,
    this.tempToken,
  });
}