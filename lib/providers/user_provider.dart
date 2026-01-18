import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/responses/follow_status_response.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/models/responses/user_public_profile_response.dart';
import 'package:rally/models/responses/user_search_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/user_repository.dart';

/// Provider for user repository related operations.
final AutoDisposeProvider<UserRepository> userRepositoryProvider =
    Provider.autoDispose<UserRepository>((Ref ref) {
      return UserRepository(ref.watch(apiClientProvider));
    });

/// Provider to fetch a specific user's public profile by ID.
final AutoDisposeFutureProviderFamily<UserPublicProfileResponse, String> userProfileProvider =
    FutureProvider.autoDispose.family<UserPublicProfileResponse, String>((
      Ref ref,
      String userId,
    ) async {
      final UserRepository repository = ref.watch(userRepositoryProvider);
      return repository.getUserPublicProfile(userId);
    });

/// Provider for user search.
final AutoDisposeFutureProviderFamily<UserSearchResponse, String> userSearchProvider =
    FutureProvider.autoDispose.family<UserSearchResponse, String>((Ref ref, String query) async {
      if (query.isEmpty) {
        return const UserSearchResponse(
          page: 1,
          pageSize: 20,
          total: 0,
          totalPages: 0,
          users: <ProfileResponse>[],
        );
      }
      final UserRepository repository = ref.watch(userRepositoryProvider);
      return repository.searchUsers(query: query);
    });

/// Provider to fetch follow status for a specific user.
///
/// Auto-disposes when the user leaves the profile page.
/// Invalidate after follow/unfollow actions to refetch.
final AutoDisposeFutureProviderFamily<FollowStatusResponse, String> followStatusProvider =
    FutureProvider.autoDispose.family<FollowStatusResponse, String>((Ref ref, String userId) async {
      final UserRepository repository = ref.watch(userRepositoryProvider);
      return repository.getFollowStatus(userId);
    });
