class GDPRConsent {
  final bool acceptedTerms;
  final bool acceptedPrivacyPolicy;
  final bool acceptedDataProcessing;
  final bool acceptedMarketing;
  final DateTime consentTimestamp;

  GDPRConsent({
    required this.acceptedTerms,
    required this.acceptedPrivacyPolicy,
    required this.acceptedDataProcessing,
    this.acceptedMarketing = false,
    DateTime? consentTimestamp,
  }) : this.consentTimestamp = consentTimestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'acceptedTerms': acceptedTerms,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'acceptedDataProcessing': acceptedDataProcessing,
      'acceptedMarketing': acceptedMarketing,
      'consentTimestamp': consentTimestamp.toIso8601String(),
    };
  }
}