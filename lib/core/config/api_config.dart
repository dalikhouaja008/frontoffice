class ApiConfig {
  static const String baseUrl = 'http://localhost:5000';
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const int connectTimeout = 5000;
  static const int receiveTimeout = 3000;
  static const int sendTimeout = 3000;
  static const String healthEndpoint = '/health';
  static const String aboutEndpoint = '/about';
  static const String contactEndpoint = '/contact';
  static const String termsEndpoint = '/terms';
  static const String privacyEndpoint = '/privacy';
  static const String faqEndpoint = '/faq';
  static const String supportEndpoint = '/support';
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String verifyEndpoint = '/verify';
  
  // GraphQL
  static const String graphqlEndpoint = '$baseUrl/graphql';
  
  // REST endpoints
  static const String landsEndpoint = '/lands';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  
}