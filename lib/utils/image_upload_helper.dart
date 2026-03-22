import 'dart:io';

import 'package:rally/models/cloudinary_signature.dart';
import 'package:rally/services/cloudinary_repository.dart';

/// Result of an image upload operation.
class ImageUploadResult {
  /// The Cloudinary public ID of the uploaded image.
  final String publicId;

  /// The secure URL of the uploaded image.
  final String secureUrl;

  /// Creates a new [ImageUploadResult].
  const ImageUploadResult({required this.publicId, required this.secureUrl});
}

/// Helper class for handling image upload operations.
///
/// Consolidates the sign-upload flow used across the app
/// (e.g., avatar updates, feedback attachments, rally cover images).
class ImageUploadHelper {
  final CloudinaryRepository _cloudinaryRepository;

  /// Creates a new [ImageUploadHelper].
  const ImageUploadHelper(this._cloudinaryRepository);

  /// Uploads a single image to Cloudinary.
  ///
  /// [file] The image file to upload.
  /// [folder] The Cloudinary folder to upload to (e.g., 'rally_avatars', 'rally_feedback').
  /// [userId] Optional user ID for generating unique public IDs.
  /// [customId] Optional custom ID suffix for the public ID.
  ///
  /// Returns an [ImageUploadResult] with the public ID and secure URL.
  Future<ImageUploadResult> uploadImage({
    required File file,
    required String folder,
    String? userId,
    String? customId,
  }) async {
    // 1. Get upload signature from backend
    final CloudinarySignature signature = await _cloudinaryRepository.getUploadSignature(
      userId: customId ?? userId,
      folder: folder,
    );

    // 2. Upload to Cloudinary
    final Map<String, dynamic> result = await _cloudinaryRepository.uploadImage(
      file: file,
      signature: signature,
      folder: folder,
    );

    return ImageUploadResult(
      publicId: result['public_id'] as String,
      secureUrl: result['secure_url'] as String,
    );
  }

  /// Uploads multiple images to Cloudinary.
  ///
  /// [files] List of image files to upload.
  /// [folder] The Cloudinary folder to upload to.
  /// [userId] User ID for generating unique public IDs.
  /// [onProgress] Optional callback for upload progress (current index, total count).
  ///
  /// Returns a list of [ImageUploadResult] for each uploaded image.
  Future<List<ImageUploadResult>> uploadMultipleImages({
    required List<File> files,
    required String folder,
    required String userId,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<ImageUploadResult> results = <ImageUploadResult>[];

    for (int i = 0; i < files.length; i++) {
      onProgress?.call(i + 1, files.length);

      // Create unique ID to prevent overwriting
      final String uniqueId = '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i';

      final ImageUploadResult result = await uploadImage(
        file: files[i],
        folder: folder,
        customId: uniqueId,
      );

      results.add(result);
    }

    return results;
  }

  /// Uploads an avatar image and verifies it with the backend.
  ///
  /// This is a convenience method that combines upload + verify for avatar updates.
  ///
  /// [file] The avatar image file.
  /// [userId] The user ID for the upload.
  ///
  /// Returns the [ImageUploadResult] after successful upload and verification.
  Future<ImageUploadResult> uploadAndVerifyAvatar({
    required File file,
    required String userId,
  }) async {
    const String folder = 'rally_avatars';

    // 1. Upload the image
    final ImageUploadResult uploadResult = await uploadImage(
      file: file,
      folder: folder,
      userId: userId,
    );

    // 2. Verify with backend (updates user profile)
    await _cloudinaryRepository.verifyAvatar(
      publicId: uploadResult.publicId,
      avatarUrl: uploadResult.secureUrl,
    );

    return uploadResult;
  }
}
