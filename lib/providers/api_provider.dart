import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/services/api_client.dart';
import 'package:rally/services/cloudinary_repository.dart';
import 'package:rally/services/rally_repository.dart';
import 'package:rally/services/user_repository.dart';
import 'package:rally/utils/image_upload_helper.dart';

/// Provider for the [ApiClient] singleton.
///
/// Uses the [AuthRepository] to get Firebase ID tokens for authentication.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final ApiClient client = ApiClient(authRepository: ref.watch(authRepositoryProvider));
  ref.onDispose(client.dispose);
  return client;
});

/// Provider for the [UserRepository].
///
/// Provides access to user profile API operations.
final Provider<UserRepository> userRepositoryProvider = Provider<UserRepository>((Ref ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

/// Provider for the [CloudinaryRepository].
///
/// Provides access to Cloudinary upload operations.
final Provider<CloudinaryRepository> cloudinaryRepositoryProvider = Provider<CloudinaryRepository>((
  Ref ref,
) {
  return CloudinaryRepository(ref.watch(apiClientProvider));
});

/// Provider for the [RallyRepository].
///
/// Provides access to rally, event, activity, and participant API operations.
final Provider<RallyRepository> rallyRepositoryProvider = Provider<RallyRepository>((Ref ref) {
  return RallyRepository(ref.watch(apiClientProvider));
});

/// Provider for the [ImageUploadHelper].
///
/// Provides consolidated image upload functionality (sign + upload + optional verify).
final Provider<ImageUploadHelper> imageUploadHelperProvider = Provider<ImageUploadHelper>((
  Ref ref,
) {
  return ImageUploadHelper(ref.watch(cloudinaryRepositoryProvider));
});
