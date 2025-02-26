import 'package:json_annotation/json_annotation.dart';

part 'two_factor_auth_model.g.dart';

@JsonSerializable()
class TwoFactorAuthModel {
  @JsonKey(name: 'qrCodeUrl')
  final String? qrCodeUrl;
  
  @JsonKey(name: 'isEnabled', defaultValue: false)
  final bool isEnabled;
  
  @JsonKey(name: 'tempToken')
  final String? tempToken;

  TwoFactorAuthModel({
    this.qrCodeUrl,
    this.isEnabled = false,
    this.tempToken,
  });

  factory TwoFactorAuthModel.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorAuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFactorAuthModelToJson(this);
}