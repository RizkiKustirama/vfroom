class ApiConstants {
  // Ganti dengan IP lokal PC saat testing di HP fisik via WiFi (misal: http://192.168.1.x:8000)
  static const String baseUrl = 'http://10.0.2.2:8000'; // Default Android Emulator host IP

  // Endpoints
  static const String garmentsUpload = '/api/v1/garments/upload';
  static const String garmentsList = '/api/v1/garments';
  static const String avatarsBase = '/api/v1/avatars/base';
  static const String avatarsGeneratePose = '/api/v1/avatars/generate-pose';
  static const String avatarsPoseAction = '/api/v1/avatars/pose/action';
  static const String tryonFit = '/api/v1/tryon/fit';
}
