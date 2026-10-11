import 'package:flutter/foundation.dart';

class ApiConstants {
  // Otomatis deteksi: localhost untuk Chrome (Web), 10.0.2.2 untuk Android Emulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://10.0.2.2:8000';
  }

  // Endpoints
  static const String garmentsUpload = '/api/v1/garments/upload';
  static const String garmentsList = '/api/v1/garments';
  static const String avatarsBase = '/api/v1/avatars/base';
  static const String avatarsGeneratePose = '/api/v1/avatars/generate-pose';
  static const String avatarsPoseAction = '/api/v1/avatars/pose/action';
  static const String tryonFit = '/api/v1/tryon/fit';
}
