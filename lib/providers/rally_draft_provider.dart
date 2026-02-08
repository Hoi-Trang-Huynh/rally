import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/models/rally_draft.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing Rally draft state.
///
/// Automatically loads from and saves to SharedPreferences.
final StateNotifierProvider<RallyDraftNotifier, RallyDraft?> rallyDraftProvider =
    StateNotifierProvider<RallyDraftNotifier, RallyDraft?>((Ref ref) {
      final SharedPreferences prefs = ref.watch(sharedPrefsServiceProvider);
      return RallyDraftNotifier(prefs);
    });

/// StateNotifier for managing Rally draft.
class RallyDraftNotifier extends StateNotifier<RallyDraft?> {
  /// Creates a new [RallyDraftNotifier].
  RallyDraftNotifier(this._prefs) : super(null) {
    _loadDraft();
  }

  final SharedPreferences _prefs;

  /// Loads the draft from SharedPreferences.
  void _loadDraft() {
    final String? jsonString = _prefs.getString(SharedPrefKeys.rallyDraft);
    state = RallyDraft.fromJsonString(jsonString);
  }

  /// Saves the current draft to SharedPreferences.
  Future<void> _saveDraft() async {
    if (state != null) {
      await _prefs.setString(SharedPrefKeys.rallyDraft, state!.toJsonString());
    } else {
      await _prefs.remove(SharedPrefKeys.rallyDraft);
    }
  }

  /// Updates the draft with new values.
  void updateDraft({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImagePath,
    List<Map<String, String?>>? invitedMembers,
  }) {
    final RallyDraft currentDraft = state ?? RallyDraft.empty();
    state = currentDraft.copyWith(
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      coverImagePath: coverImagePath,
      invitedMembers: invitedMembers,
    );
    _saveDraft();
  }

  /// Sets the entire draft at once.
  void setDraft(RallyDraft draft) {
    state = draft;
    _saveDraft();
  }

  /// Clears the draft.
  Future<void> clearDraft() async {
    state = null;
    await _prefs.remove(SharedPrefKeys.rallyDraft);
  }

  /// Whether a draft exists with meaningful content.
  bool get hasDraft => state?.hasContent ?? false;
}
