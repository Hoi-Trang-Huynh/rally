import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/responses/participant_list_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/rally_repository.dart';

/// Provider for fetching the participants of a specific rally by role.
/// Supports pagination.
final AutoDisposeAsyncNotifierProviderFamily<
  RallyParticipantsByRoleNotifier,
  ParticipantListResponse,
  ({String rallyId, ParticipantRole role})
>
rallyParticipantsByRoleProvider = AsyncNotifierProvider.autoDispose.family<
  RallyParticipantsByRoleNotifier,
  ParticipantListResponse,
  ({String rallyId, ParticipantRole role})
>(RallyParticipantsByRoleNotifier.new);

class RallyParticipantsByRoleNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          ParticipantListResponse,
          ({String rallyId, ParticipantRole role})
        > {
  int _currentPage = 1;
  static const int _pageSize = 5;
  bool _isFetchingMore = false;

  @override
  FutureOr<ParticipantListResponse> build(({String rallyId, ParticipantRole role}) args) async {
    _currentPage = 1;
    final RallyRepository repository = ref.watch(rallyRepositoryProvider);
    return await repository.getParticipants(
      args.rallyId,
      role: args.role,
      page: _currentPage,
      pageSize: _pageSize,
    );
  }

  /// Loads the next page of participants.
  Future<void> loadMore() async {
    if (_isFetchingMore) return;

    final AsyncValue<ParticipantListResponse> currentState = state;
    if (currentState.isLoading || currentState.hasError || !currentState.hasValue) return;

    final ParticipantListResponse currentData = currentState.requireValue;

    // Check if we already have all participants
    if (currentData.participants.length >= currentData.total) return;

    _isFetchingMore = true;
    _currentPage++;

    try {
      final RallyRepository repository = ref.read(rallyRepositoryProvider);
      final ParticipantListResponse nextPageData = await repository.getParticipants(
        arg.rallyId,
        role: arg.role,
        page: _currentPage,
        pageSize: _pageSize,
      );

      state = AsyncValue<ParticipantListResponse>.data(
        ParticipantListResponse(
          participants: <ParticipantItem>[
            ...currentData.participants,
            ...nextPageData.participants,
          ],
          total: nextPageData.total,
          page: _currentPage,
          pageSize: _pageSize,
          totalPages: nextPageData.totalPages,
        ),
      );
    } catch (e, st) {
      // Revert page increment if failed
      _currentPage--;
      // Optionally handle the error (e.g., show a snackbar) but keep existing data
      state = AsyncValue<ParticipantListResponse>.error(
        e,
        st,
      ).copyWithPrevious(AsyncValue<ParticipantListResponse>.data(currentData));
    } finally {
      _isFetchingMore = false;
    }
  }
}
