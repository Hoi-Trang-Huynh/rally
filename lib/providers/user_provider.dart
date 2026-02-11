import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/responses/follow_status_response.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/models/responses/user_public_profile_response.dart';
import 'package:rally/models/responses/user_rallies_response.dart';
import 'package:rally/models/responses/user_search_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/user_repository.dart';

// Export the repository provider from api_provider to maintain backward compatibility
export 'package:rally/providers/api_provider.dart' show userRepositoryProvider;

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

/// Parameters for fetching user rallies.
class UserRalliesParams {
  final String userId;
  final String? name;
  final String? status;
  final String sort;

  const UserRalliesParams({required this.userId, this.name, this.status, this.sort = 'asc'});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRalliesParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          name == other.name &&
          status == other.status &&
          sort == other.sort;

  @override
  int get hashCode => userId.hashCode ^ name.hashCode ^ status.hashCode ^ sort.hashCode;
}

/// Provider to fetch a user's rallies.
///
/// Supports filtering by name, status, and sorting by start date.
/// Auto-disposes when no longer needed.
final AutoDisposeFutureProviderFamily<UserRalliesResponse, UserRalliesParams> userRalliesProvider =
    FutureProvider.autoDispose.family<UserRalliesResponse, UserRalliesParams>((
      Ref ref,
      UserRalliesParams params,
    ) async {
      final UserRepository repository = ref.watch(userRepositoryProvider);
      return repository.getUserRallies(
        userId: params.userId,
        name: params.name,
        status: params.status,
        sort: params.sort,
      );
    });
