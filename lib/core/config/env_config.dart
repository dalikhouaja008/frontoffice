class EnvConfig {
  static const bool isDev = bool.fromEnvironment('DEV_MODE', defaultValue: true);
  
  static void setupLogging() {
    print('[2025-02-17 09:57:52] Config: 🔧 Setting up environment'
          '\n└─ Mode: ${isDev ? 'Development' : 'Production'}');
  }
}