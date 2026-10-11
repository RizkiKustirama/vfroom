import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/garment_item.dart';
import '../models/avatar_model.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  Future<Map<String, dynamic>> uploadGarment({
    required Uint8List bytes,
    required String fileName,
    required String userId,
    required int categoryId,
    required String name,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
    });

    final response = await _dio.post(
      ApiConstants.garmentsUpload,
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Uint8List> downloadBytes(String urlPath) async {
    final fullUrl = urlPath.startsWith('http') ? urlPath : '${ApiConstants.baseUrl}$urlPath';
    final response = await _dio.get<List<int>>(
      fullUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  Future<List<GarmentItem>> fetchGarments({int? categoryId}) async {
    final response = await _dio.get(
      ApiConstants.garmentsList,
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
    final items = response.data['items'] as List;
    return items.map((json) => GarmentItem.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> executeTryon({
    required String userId,
    required String avatarId,
    required List<String> garmentIds,
    String? promptText,
  }) async {
    final response = await _dio.post(
      ApiConstants.tryonFit,
      data: {
        'user_id': userId,
        'avatar_id': avatarId,
        'garment_ids': garmentIds,
        'prompt_text': promptText,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendPoseAction({
    required String avatarId,
    required String action,
  }) async {
    final response = await _dio.post(
      ApiConstants.avatarsPoseAction,
      data: {
        'avatar_id': avatarId,
        'action': action,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

final apiService = ApiService();
