import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/services/api_client.dart';
import 'package:rally/services/user_repository.dart';

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
