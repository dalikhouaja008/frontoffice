// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_factor_auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwoFactorAuthModel _$TwoFactorAuthModelFromJson(Map<String, dynamic> json) =>
    TwoFactorAuthModel(
      qrCodeUrl: json['qrCodeUrl'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? false,
      tempToken: json['tempToken'] as String?,
    );

Map<String, dynamic> _$TwoFactorAuthModelToJson(TwoFactorAuthModel instance) =>
    <String, dynamic>{
      'qrCodeUrl': instance.qrCodeUrl,
      'isEnabled': instance.isEnabled,
      'tempToken': instance.tempToken,
    };
