import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/responses/rally_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/rally_repository.dart';

/// Provider for managing the currently viewed rally.
///
/// Tracks the active rally being viewed on the RallyScreen.
/// When switching rallies, call [loadRally] with the new ID.
///
/// TODO: In the future, this will use a WebSocket/stream connection
/// for real-time updates (live document / chat room style).
final AutoDisposeStateNotifierProvider<CurrentRallyNotifier, AsyncValue<RallyResponse>>
currentRallyProvider =
    StateNotifierProvider.autoDispose<CurrentRallyNotifier, AsyncValue<RallyResponse>>((Ref ref) {
      final RallyRepository repository = ref.watch(rallyRepositoryProvider);
      return CurrentRallyNotifier(repository);
    });

/// StateNotifier for the currently viewed rally.
///
/// Manages loading, caching, and clearing the active rally data.
/// Designed to be extended with streaming capabilities in the future.
class CurrentRallyNotifier extends StateNotifier<AsyncValue<RallyResponse>> {
  /// Creates a new [CurrentRallyNotifier].
  CurrentRallyNotifier(this._repository) : super(const AsyncValue<RallyResponse>.loading());

  final RallyRepository _repository;

  /// The ID of the currently loaded rally, if any.
  String? _currentRallyId;

  /// The ID of the currently loaded rally.
  String? get currentRallyId => _currentRallyId;

  /// Loads a rally by ID from the API.
  ///
  /// If the same rally ID is already loaded, this is a no-op unless [force] is true.
  ///
  /// TODO: Replace API fetch with stream subscription for real-time updates.
  Future<void> loadRally(String rallyId, {bool force = false}) async {
    if (_currentRallyId == rallyId && !force && state is AsyncData<RallyResponse>) {
      return; // Already loaded
    }

    _currentRallyId = rallyId;
    state = const AsyncValue<RallyResponse>.loading();

    try {
      final RallyResponse rally = await _repository.getRally(rallyId);
      // Only update if still viewing the same rally (user may have navigated away)
      if (_currentRallyId == rallyId && mounted) {
        state = AsyncValue<RallyResponse>.data(rally);
      }
    } catch (error, stackTrace) {
      if (_currentRallyId == rallyId && mounted) {
        state = AsyncValue<RallyResponse>.error(error, stackTrace);
      }
    }
  }

  /// Refreshes the currently loaded rally.
  Future<void> refresh() async {
    if (_currentRallyId != null) {
      await loadRally(_currentRallyId!, force: true);
    }
  }

  /// Clears the current rally state.
  void clearRally() {
    _currentRallyId = null;
    state = const AsyncValue<RallyResponse>.loading();
  }
}
