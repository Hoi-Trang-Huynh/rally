import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rally/models/cloudinary_signature.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/services/api_client.dart';

/// Repository for Cloudinary-related operations.
class CloudinaryRepository {
  final ApiClient _apiClient;
  final http.Client _httpClient;

  /// Creates a new [CloudinaryRepository].
  CloudinaryRepository(this._apiClient) : _httpClient = http.Client();

  /// Fetches a signed upload signature from the backend.
  Future<CloudinarySignature> getUploadSignature({String? folder, String? userId}) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (folder != null) 'folder': folder,
      if (userId != null) 'user_id': userId,
    };
    // Removed print('Body: $body');
    final dynamic response = await _apiClient.post('/api/v1/media/sign', body: body);
    // Removed print('Cloudinary: Signature received: $response');
    return CloudinarySignature.fromJson(response as Map<String, dynamic>);
  }

  /// Uploads an image directly to Cloudinary using the signature.
  ///
  /// Returns a Map with 'public_id' and 'secure_url' on success.
  Future<Map<String, dynamic>> uploadImage({
    required File file,
    required CloudinarySignature signature,
    String? folder,
  }) async {
    if (signature.cloudName.isEmpty) {
      throw Exception('Cloud name is missing in signature');
    }

    final Uri uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${signature.cloudName}/image/upload',
    );

    final http.MultipartRequest request =
        http.MultipartRequest('POST', uri)
          ..fields['api_key'] = signature.apiKey
          ..fields['timestamp'] = signature.timestamp.toString()
          ..fields['signature'] = signature.signature
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    if (signature.publicId != null) {
      request.fields['public_id'] = signature.publicId!;
    }
    if (folder != null) {
      request.fields['folder'] = folder;
    }

    final http.StreamedResponse streamedResponse = await _httpClient.send(request);
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return <String, dynamic>{'public_id': data['public_id'], 'secure_url': data['secure_url']};
    } else {
      throw Exception('Failed to upload to cloud "${signature.cloudName}": ${response.body}');
    }
  }

  /// Verifies and updates the user's avatar after a successful upload.
  Future<ProfileResponse> verifyAvatar({
    required String publicId,
    required String avatarUrl,
  }) async {
    final Map<String, String> body = <String, String>{
      'public_id': publicId,
      'avatar_url': avatarUrl,
    };

    final dynamic response = await _apiClient.post('/api/v1/media/verify-avatar', body: body);
    return ProfileResponse.fromJson(response as Map<String, dynamic>);
  }
}

/// Provider for [CloudinaryRepository].
