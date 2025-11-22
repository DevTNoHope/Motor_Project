class Env {
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.33:8000/api/v1', // Android emulator
  );
  static const googleWebClientId ='52869346165-t1dbp80ie94b973hpspu0rb45b5frciq.apps.googleusercontent.com';
}
