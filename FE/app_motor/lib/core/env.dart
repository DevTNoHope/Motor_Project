class Env {
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.4:8000/api/v1', // Android emulator
  );
}
