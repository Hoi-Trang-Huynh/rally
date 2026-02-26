import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/requests/participant_requests.dart';
import 'package:rally/models/responses/follow_list_response.dart';
import 'package:rally/models/responses/friend_list_response.dart';
import 'package:rally/models/responses/invite_link_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/invite_link_provider.dart';
import 'package:rally/providers/rally_participants_provider.dart';
import 'package:rally/services/rally_repository.dart';
import 'package:rally/utils/participant_role_helper.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/utils/ui_helpers.dart';
import 'package:rally/utils/validation_constants.dart';

/// A bottom-sheet widget for inviting friends to an **existing** rally.
///
/// Unlike [InviteMembersPage] (used during rally creation), this widget:
/// - Fetches only friends who are **not** already participants via
///   `GET /api/v1/rallies/{rallyId}/invitable-friends`.
/// - Supports **debounced server-side search** with the `q` query parameter.
/// - Supports **pagination** with a "Load more" button.
/// - Sends real [inviteParticipant] API calls on confirmation.
/// - Includes an invite-link / QR-code section for generating and managing
///   shareable invite links.
class RallyInviteMembersSheet extends ConsumerStatefulWidget {
  /// Creates a new [RallyInviteMembersSheet].
  const RallyInviteMembersSheet({super.key, required this.rallyId});

  /// The ID of the rally to invite members to.
  final String rallyId;

  @override
  ConsumerState<RallyInviteMembersSheet> createState() => _RallyInviteMembersSheetState();
}

class _RallyInviteMembersSheetState extends ConsumerState<RallyInviteMembersSheet> {
  final TextEditingController _searchController = TextEditingController();

  /// Debounce timer for search input.
  Timer? _debounce;

  /// Current search query sent to the API.
  String _currentQuery = '';

  /// Set of selected friend IDs (pending invitation).
  final Set<String> _selectedIds = <String>{};

  /// Fetched friends from the API (accumulated across pages).
  List<FollowUserItem> _friends = <FollowUserItem>[];

  /// Total number of invitable friends matching the current query.
  int _total = 0;

  /// Current page number.
  int _currentPage = 1;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSending = false;
  bool _isGeneratingLink = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFriends(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data fetching
  // ---------------------------------------------------------------------------

  /// Fetches invitable friends from the API.
  ///
  /// When [page] is 1, replaces the current list (new search).
  /// When [page] > 1, appends to the current list (load more).
  Future<void> _fetchFriends({required int page, String? query}) async {
    final bool isFirstPage = page == 1;

    setState(() {
      if (isFirstPage) {
        _isLoading = true;
        _errorMessage = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final RallyRepository rallyRepo = ref.read(rallyRepositoryProvider);

      final FriendListResponse response = await rallyRepo.getInvitableFriends(
        widget.rallyId,
        query: query,
        page: page,
        pageSize: PaginationDefaults.invitableFriendsPageSize,
      );

      if (mounted) {
        setState(() {
          _currentPage = page;
          _total = response.total;

          if (isFirstPage) {
            _friends = response.users;
          } else {
            _friends = <FollowUserItem>[..._friends, ...response.users];
          }

          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          if (isFirstPage) {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Search (debounced, server-side)
  // ---------------------------------------------------------------------------

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final String trimmed = query.trim();
      if (trimmed != _currentQuery) {
        _currentQuery = trimmed;
        // Reset selection when query changes
        _selectedIds.clear();
        _fetchFriends(page: 1, query: _currentQuery.isEmpty ? null : _currentQuery);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  bool get _hasMore => _friends.length < _total;

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;
    _fetchFriends(page: _currentPage + 1, query: _currentQuery.isEmpty ? null : _currentQuery);
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Invite action
  // ---------------------------------------------------------------------------

  Future<void> _sendInvites() async {
    if (_selectedIds.isEmpty) return;

    setState(() => _isSending = true);

    final Translations t = Translations.of(context);
    try {
      final RallyRepository repository = ref.read(rallyRepositoryProvider);

      for (final String userId in _selectedIds) {
        await repository.inviteParticipant(
          widget.rallyId,
          InviteParticipantRequest(userId: userId),
        );
      }

      // Refresh all participant role lists so the tab updates immediately.
      ref.invalidate(
        rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.owner)),
      );
      ref.invalidate(
        rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.editor)),
      );
      ref.invalidate(
        rallyParticipantsByRoleProvider((
          rallyId: widget.rallyId,
          role: ParticipantRole.participant,
        )),
      );

      if (mounted) {
        showSuccessSnackBar(context, t.rally.rallyInvite.inviteSuccess);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, t.rally.rallyInvite.inviteError);
        setState(() => _isSending = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Invite link actions
  // ---------------------------------------------------------------------------

  Future<void> _generateInviteLink() async {
    if (_isGeneratingLink) return;

    setState(() => _isGeneratingLink = true);

    final Translations t = Translations.of(context);
    try {
      await ref.read(inviteLinksProvider(widget.rallyId).notifier).create();

      if (mounted) {
        showSuccessSnackBar(context, t.rally.rallyInvite.inviteLink.generateButton);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, t.rally.rallyInvite.inviteLink.generateError);
      }
    } finally {
      if (mounted) setState(() => _isGeneratingLink = false);
    }
  }

  Future<void> _revokeInviteLink(String token) async {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext ctx) => AlertDialog(
            title: Text(t.rally.rallyInvite.inviteLink.revokeConfirmTitle),
            content: Text(t.rally.rallyInvite.inviteLink.revokeConfirmMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(t.rally.rallyInvite.inviteLink.revokeConfirmNo),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                child: Text(t.rally.rallyInvite.inviteLink.revokeConfirmYes),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(inviteLinksProvider(widget.rallyId).notifier).revoke(token);

      if (mounted) {
        showSuccessSnackBar(context, t.rally.rallyInvite.inviteLink.revokeSuccess);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, t.rally.rallyInvite.inviteLink.revokeError);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Column(
      children: <Widget>[
        // ── Header ──────────────────────────────────────────────────────
        _buildHeader(colorScheme, textTheme, t),

        // ── Scrollable body ─────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: Responsive.h(context, 16)),

                // Invite link / QR code section
                _buildInviteLinkSection(colorScheme, textTheme, t),

                SizedBox(height: Responsive.h(context, 24)),

                // Search bar
                _buildSearchBar(colorScheme, textTheme, t),

                SizedBox(height: Responsive.h(context, 16)),

                // Friends list
                _buildFriendsList(colorScheme, textTheme, t),

                SizedBox(height: Responsive.h(context, 24)),
              ],
            ),
          ),
        ),

        // ── Bottom action bar ───────────────────────────────────────────
        _buildBottomBar(colorScheme, textTheme, t),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-builders
  // ---------------------------------------------------------------------------

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme, Translations t) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 8),
        vertical: Responsive.h(context, 8),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              t.rally.rallyInvite.title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          // Spacer for symmetry with the close button
          SizedBox(width: Responsive.w(context, 48)),
        ],
      ),
    );
  }

  /// Invite link / QR code section.
  ///
  /// Shows existing invite links as QR cards with actions, plus a
  /// "Generate Invite Link" button.
  Widget _buildInviteLinkSection(ColorScheme colorScheme, TextTheme textTheme, Translations t) {
    final AsyncValue<List<InviteLinkItem>> linksAsync = ref.watch(
      inviteLinksProvider(widget.rallyId),
    );

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Section header
          Row(
            children: <Widget>[
              Icon(
                Icons.qr_code_2_rounded,
                size: Responsive.w(context, 22),
                color: colorScheme.primary,
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Expanded(
                child: Text(
                  t.rally.rallyInvite.inviteLink.activeLinks,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.h(context, 12)),

          // Links content
          linksAsync.when(
            loading:
                () => Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            error:
                (Object error, _) => Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                  child: Text(
                    error.toString(),
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  ),
                ),
            data: (List<InviteLinkItem> links) {
              if (links.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                  child: Text(
                    t.rally.rallyInvite.inviteLink.noLinksYet,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                );
              }

              return Column(
                children:
                    links
                        .map(
                          (InviteLinkItem link) => Padding(
                            padding: EdgeInsets.only(bottom: Responsive.h(context, 12)),
                            child: _InviteLinkCard(
                              link: link,
                              onRevoke: () => _revokeInviteLink(link.token),
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          ),

          SizedBox(height: Responsive.h(context, 8)),

          // Generate button
          OutlinedButton.icon(
            onPressed: _isGeneratingLink ? null : _generateInviteLink,
            icon:
                _isGeneratingLink
                    ? SizedBox(
                      width: Responsive.w(context, 16),
                      height: Responsive.w(context, 16),
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                    )
                    : Icon(Icons.add_link_rounded, size: Responsive.w(context, 18)),
            label: Text(
              _isGeneratingLink
                  ? t.rally.rallyInvite.inviteLink.generating
                  : t.rally.rallyInvite.inviteLink.generateButton,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              ),
              padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, TextTheme textTheme, Translations t) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: t.rally.rallyInvite.searchPlaceholder,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: Responsive.w(context, 18),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 16),
          vertical: Responsive.h(context, 12),
        ),
      ),
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildFriendsList(ColorScheme colorScheme, TextTheme textTheme, Translations t) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 40)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
        child: Text(
          _errorMessage!,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        ),
      );
    }

    if (_friends.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 40)),
        child: Center(
          child: Text(
            t.rally.rallyInvite.noFriends,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        ..._friends.map(
          (FollowUserItem friend) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
            child: _InvitableFriendItem(
              friend: friend,
              isSelected: _selectedIds.contains(friend.id),
              onToggle: () => _toggleSelection(friend.id),
            ),
          ),
        ),
        // Load more button / indicator
        if (_hasMore)
          _isLoadingMore
              ? Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
              : Padding(
                padding: EdgeInsets.only(top: Responsive.h(context, 4)),
                child: TextButton(
                  onPressed: _loadMore,
                  child: Text(
                    t.rally.common.loadMore,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme, TextTheme textTheme, Translations t) {
    final bool hasSelection = _selectedIds.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: Responsive.w(context, 24),
        right: Responsive.w(context, 24),
        top: Responsive.h(context, 16),
        bottom: Responsive.h(context, 24) + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: <Widget>[
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: _isSending ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                ),
              ),
              child: Text(
                t.rally.rallyInvite.cancel,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          // Send invites button
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    hasSelection && !_isSending
                        ? LinearGradient(
                          colors: <Color>[
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        )
                        : null,
                color:
                    hasSelection && !_isSending
                        ? null
                        : colorScheme.onSurface.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
              ),
              child: ElevatedButton(
                onPressed: hasSelection && !_isSending ? _sendInvites : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                  ),
                ),
                child:
                    _isSending
                        ? SizedBox(
                          width: Responsive.w(context, 20),
                          height: Responsive.w(context, 20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                        : Text(
                          _selectedIds.isEmpty
                              ? t.rally.rallyInvite.done
                              : '${t.rally.rallyInvite.done} (${_selectedIds.length})',
                          style: textTheme.labelLarge?.copyWith(
                            color:
                                hasSelection
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface.withValues(alpha: 0.38),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Private sub-widgets
// =============================================================================

/// A card displaying a single invite link with QR code, stats, and actions.
class _InviteLinkCard extends StatelessWidget {
  const _InviteLinkCard({required this.link, required this.onRevoke});

  final InviteLinkItem link;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    final String usageText =
        link.maxUses != null
            ? t.rally.rallyInvite.inviteLink.uses
                .replaceAll('{current}', link.currentUses.toString())
                .replaceAll('{max}', link.maxUses.toString())
            : t.rally.rallyInvite.inviteLink.usesUnlimited.replaceAll(
              '{current}',
              link.currentUses.toString(),
            );

    String? expiryText;
    if (link.isExpired) {
      expiryText = t.rally.rallyInvite.inviteLink.expired;
    } else if (link.expiresAt != null) {
      expiryText = t.rally.rallyInvite.inviteLink.expiresAt.replaceAll(
        '{date}',
        DateFormat.yMMMd().format(link.expiresAt!),
      );
    }

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // QR Code (tappable to expand)
          GestureDetector(
            onTap: () => _showQrDetail(context, link),
            child: Container(
              padding: EdgeInsets.all(Responsive.w(context, 6)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
              ),
              child: QrImageView(
                data: 'https://rally-go.com/invite/${link.token}',
                version: QrVersions.auto,
                size: Responsive.w(context, 80),
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
                embeddedImage: const AssetImage('assets/images/rally_logo_transparent.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(Responsive.w(context, 20), Responsive.w(context, 20)),
                ),
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
          ),

          SizedBox(width: Responsive.w(context, 12)),

          // Info & actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Role badge using ParticipantRoleHelper
                Builder(
                  builder: (BuildContext context) {
                    final ParticipantRole role = ParticipantRole.fromString(link.role);
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 8),
                        vertical: Responsive.h(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: ParticipantRoleHelper.roleColor(role, colorScheme),
                        borderRadius: BorderRadius.circular(Responsive.w(context, 6)),
                      ),
                      child: Text(
                        ParticipantRoleHelper.roleLabel(role, t),
                        style: textTheme.labelSmall?.copyWith(
                          color: ParticipantRoleHelper.roleTextColor(role, colorScheme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: Responsive.h(context, 6)),

                // Usage stats
                Text(
                  usageText,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),

                // Expiry (only if present)
                if (expiryText != null)
                  Padding(
                    padding: EdgeInsets.only(top: Responsive.h(context, 2)),
                    child: Text(
                      expiryText,
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            link.isExpired
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),

                SizedBox(height: Responsive.h(context, 8)),

                // Revoke button
                _CompactActionButton(
                  icon: Icons.link_off_rounded,
                  label: t.rally.rallyInvite.inviteLink.revokeButton,
                  color: colorScheme.error,
                  onTap: onRevoke,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens a fullscreen dialog to display the QR code enlarged with a save option.
  static void _showQrDetail(BuildContext context, InviteLinkItem link) {
    showDialog<void>(context: context, builder: (BuildContext ctx) => _QrDetailDialog(link: link));
  }
}

/// A compact tappable action chip for invite link actions.
class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 8),
          vertical: Responsive.h(context, 4),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: Responsive.w(context, 14), color: color),
            SizedBox(width: Responsive.w(context, 4)),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single friend row with selection toggle.
class _InvitableFriendItem extends StatelessWidget {
  const _InvitableFriendItem({
    required this.friend,
    required this.isSelected,
    required this.onToggle,
  });

  final FollowUserItem friend;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color:
            isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          CircleAvatar(
            radius: Responsive.w(context, 22),
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
            child:
                friend.avatarUrl == null
                    ? Text(
                      friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : '?',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),

          SizedBox(width: Responsive.w(context, 12)),

          // Name & username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  friend.displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '@${friend.username}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Invite / Invited toggle
          ElevatedButton(
            onPressed: onToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? colorScheme.primaryContainer : colorScheme.onSurface,
              foregroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 14),
                vertical: Responsive.h(context, 8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
              ),
              elevation: 0,
            ),
            child: Text(
              isSelected ? t.rally.rallyInvite.invited : t.rally.rallyInvite.invite,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen dialog displaying an enlarged QR code with a save-to-gallery option.
class _QrDetailDialog extends StatefulWidget {
  const _QrDetailDialog({required this.link});

  final InviteLinkItem link;

  @override
  State<_QrDetailDialog> createState() => _QrDetailDialogState();
}

class _QrDetailDialogState extends State<_QrDetailDialog> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final Translations t = Translations.of(context);
    try {
      // Request gallery access first.
      final bool hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
        final bool granted = await Gal.hasAccess(toAlbum: true);
        if (!granted) {
          if (mounted) {
            showErrorSnackBar(context, t.rally.rallyInvite.inviteLink.saveError);
          }
          return;
        }
      }

      // Capture the QR widget as an image.
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception('Failed to encode image');

      // Save to gallery.
      await Gal.putImageBytes(byteData.buffer.asUint8List(), album: 'Rally');

      if (mounted) {
        showSuccessSnackBar(context, t.rally.rallyInvite.inviteLink.savedToGallery);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, t.rally.rallyInvite.inviteLink.saveError);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);
    final double qrSize = MediaQuery.of(context).size.width * 0.65;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(context, 24))),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Main content
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 24),
              Responsive.h(context, 40),
              Responsive.w(context, 24),
              Responsive.w(context, 24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // QR code (captured by RepaintBoundary for saving)
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: EdgeInsets.all(Responsive.w(context, 16)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                    ),
                    child: QrImageView(
                      data: 'https://rally-go.com/invite/${widget.link.token}',
                      version: QrVersions.auto,
                      size: qrSize,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      embeddedImage: const AssetImage('assets/images/rally_logo_transparent.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(qrSize * 0.22, qrSize * 0.22),
                      ),
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ),

                SizedBox(height: Responsive.h(context, 20)),

                // Save to Gallery button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveToGallery,
                    icon:
                        _isSaving
                            ? SizedBox(
                              width: Responsive.w(context, 18),
                              height: Responsive.w(context, 18),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                            : Icon(Icons.download_rounded, size: Responsive.w(context, 20)),
                    label: Text(t.rally.rallyInvite.inviteLink.saveToGallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                      ),
                      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button — positioned at dialog top-right edge
          Positioned(
            top: Responsive.h(context, 8),
            right: Responsive.w(context, 8),
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
