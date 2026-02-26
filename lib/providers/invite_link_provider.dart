import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/requests/invite_link_request.dart';
import 'package:rally/models/responses/invite_link_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/rally_repository.dart';

/// Provider for managing invite links for a specific rally.
///
/// Keyed on `rallyId`. Automatically fetches all active invite links
/// on build and exposes [create] / [revoke] methods that refresh the list.
final AutoDisposeAsyncNotifierProviderFamily<InviteLinksNotifier, List<InviteLinkItem>, String>
inviteLinksProvider = AsyncNotifierProvider.autoDispose
    .family<InviteLinksNotifier, List<InviteLinkItem>, String>(InviteLinksNotifier.new);

/// Async notifier that manages the list of invite links for a rally.
class InviteLinksNotifier extends AutoDisposeFamilyAsyncNotifier<List<InviteLinkItem>, String> {
  late RallyRepository _repository;

  @override
  Future<List<InviteLinkItem>> build(String arg) async {
    _repository = ref.read(rallyRepositoryProvider);
    return _fetchLinks();
  }

  /// Fetches all invite links from the backend.
  Future<List<InviteLinkItem>> _fetchLinks() async {
    final InviteLinkListResponse response = await _repository.getInviteLinks(arg);
    return response.links;
  }

  /// Creates a new invite link and refreshes the list.
  ///
  /// Returns the newly created [InviteLinkItem].
  Future<InviteLinkItem> create({CreateInviteLinkRequest? request}) async {
    final InviteLinkItem newLink = await _repository.createInviteLink(arg, request: request);

    // Optimistically add the new link to the current list.
    final List<InviteLinkItem> current = state.valueOrNull ?? <InviteLinkItem>[];
    state = AsyncData<List<InviteLinkItem>>(<InviteLinkItem>[newLink, ...current]);

    return newLink;
  }

  /// Revokes an invite link by its token and refreshes the list.
  Future<void> revoke(String token) async {
    await _repository.revokeInviteLink(arg, token);

    // Optimistically remove the revoked link from the list.
    final List<InviteLinkItem> current = state.valueOrNull ?? <InviteLinkItem>[];
    state = AsyncData<List<InviteLinkItem>>(
      current.where((InviteLinkItem link) => link.token != token).toList(),
    );
  }
}
