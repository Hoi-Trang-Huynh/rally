import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/responses/follow_list_response.dart';
import 'package:rally/models/responses/friend_list_response.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/user_provider.dart';
import 'package:rally/services/user_repository.dart';
import 'package:rally/utils/responsive.dart';

/// An internal page widget for inviting members to a rally.
///
/// Features:
/// - User avatar header
/// - Collapsible "Invited" section showing currently invited members
/// - Collapsible "Suggested" section with search functionality
/// - Search only filters the Suggested section
class InviteMembersPage extends ConsumerStatefulWidget {
  /// Creates a new [InviteMembersPage].
  const InviteMembersPage({
    super.key,
    required this.initialInvitedMembers,
    required this.onBack,
    required this.onDone,
  });

  /// The initially invited members (from parent widget).
  final List<FollowUserItem> initialInvitedMembers;

  /// Callback when user taps the back button.
  final VoidCallback onBack;

  /// Callback when user taps Done with the final invited members list.
  final void Function(List<FollowUserItem> invitedMembers) onDone;

  @override
  ConsumerState<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends ConsumerState<InviteMembersPage> {
  final TextEditingController _searchController = TextEditingController();

  /// Set of invited member IDs for quick lookup.
  final Set<String> _invitedMemberIds = <String>{};

  /// Map of invited members by ID for easy access.
  final Map<String, FollowUserItem> _invitedMembersMap = <String, FollowUserItem>{};

  /// All suggested friends (not yet invited).
  List<FollowUserItem> _allSuggestedFriends = <FollowUserItem>[];

  /// Filtered suggested friends based on search query.
  List<FollowUserItem> _filteredSuggestedFriends = <FollowUserItem>[];

  bool _isLoading = true;
  String? _errorMessage;

  /// Section expansion states.
  bool _isInvitedExpanded = true;
  bool _isSuggestedExpanded = true;

  @override
  void initState() {
    super.initState();
    // Initialize with already invited members
    for (final FollowUserItem member in widget.initialInvitedMembers) {
      _invitedMemberIds.add(member.id);
      _invitedMembersMap[member.id] = member;
    }
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UserRepository userRepo = ref.read(userRepositoryProvider);
      final ProfileResponse? profile = ref.read(myProfileProvider).valueOrNull;

      if (profile == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      final FriendListResponse response = await userRepo.getFriends(
        userId: profile.id!,
        pageSize: 100,
      );

      if (mounted) {
        setState(() {
          // Store all friends, filter out already invited ones for suggested
          _allSuggestedFriends =
              response.users
                  .where((FollowUserItem f) => !_invitedMemberIds.contains(f.id))
                  .toList();
          _filteredSuggestedFriends = List<FollowUserItem>.from(_allSuggestedFriends);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestedFriends = List<FollowUserItem>.from(_allSuggestedFriends);
      } else {
        final String lowerQuery = query.toLowerCase();
        _filteredSuggestedFriends =
            _allSuggestedFriends
                .where(
                  (FollowUserItem f) =>
                      f.displayName.toLowerCase().contains(lowerQuery) ||
                      f.username.toLowerCase().contains(lowerQuery),
                )
                .toList();
      }
    });
  }

  void _addMember(FollowUserItem member) {
    setState(() {
      _invitedMemberIds.add(member.id);
      _invitedMembersMap[member.id] = member;
      // Move from suggested to invited
      _allSuggestedFriends.removeWhere((FollowUserItem f) => f.id == member.id);
      _filteredSuggestedFriends.removeWhere((FollowUserItem f) => f.id == member.id);
    });
  }

  void _removeMember(FollowUserItem member) {
    setState(() {
      _invitedMemberIds.remove(member.id);
      _invitedMembersMap.remove(member.id);
      // Move back to suggested
      _allSuggestedFriends.add(member);
      // Re-apply search filter
      _onSearchChanged(_searchController.text);
    });
  }

  void _onDone() {
    // Collect all invited members
    final List<FollowUserItem> invitedMembers = _invitedMembersMap.values.toList();
    widget.onDone(invitedMembers);
  }

  List<FollowUserItem> get _invitedMembersList => _invitedMembersMap.values.toList();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);
    final ProfileResponse? profile = ref.watch(myProfileProvider).valueOrNull;

    return Column(
      children: <Widget>[
        // Header with back button
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 8),
            vertical: Responsive.h(context, 8),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  t.rally.createRally.inviteMembers.title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Spacer for symmetry
              SizedBox(width: Responsive.w(context, 48)),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: Responsive.h(context, 16)),

                // Current user avatar
                CircleAvatar(
                  radius: Responsive.w(context, 40),
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage:
                      profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                  child:
                      profile?.avatarUrl == null
                          ? Icon(
                            Icons.person,
                            size: Responsive.w(context, 40),
                            color: colorScheme.onPrimaryContainer,
                          )
                          : null,
                ),

                SizedBox(height: Responsive.h(context, 16)),

                // Headline
                Text(
                  t.rally.createRally.inviteMembers.headline,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: Responsive.h(context, 24)),

                // INVITED SECTION (Collapsible)
                _CollapsibleSection(
                  title: t.rally.createRally.inviteMembers.invitedSection.replaceAll(
                    '{count}',
                    _invitedMembersList.length.toString(),
                  ),
                  isExpanded: _isInvitedExpanded,
                  onToggle: () => setState(() => _isInvitedExpanded = !_isInvitedExpanded),
                  child:
                      _invitedMembersList.isEmpty
                          ? Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                            child: Text(
                              t.rally.createRally.inviteMembers.noInvitedYet,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                          : Column(
                            children:
                                _invitedMembersList
                                    .map(
                                      (FollowUserItem member) => Padding(
                                        padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
                                        child: _MemberListItem(
                                          member: member,
                                          isInvited: true,
                                          onTap: () => _removeMember(member),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                ),

                SizedBox(height: Responsive.h(context, 16)),

                // SUGGESTED SECTION (Collapsible)
                _CollapsibleSection(
                  title: t.rally.createRally.inviteMembers.suggestedSection,
                  isExpanded: _isSuggestedExpanded,
                  onToggle: () => setState(() => _isSuggestedExpanded = !_isSuggestedExpanded),
                  child: Column(
                    children: <Widget>[
                      // Search field inside the section
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: t.rally.createRally.inviteMembers.searchPlaceholder,
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
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
                      ),

                      SizedBox(height: Responsive.h(context, 12)),

                      // Friends list
                      if (_isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
                          child: const CircularProgressIndicator(),
                        )
                      else if (_errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
                          child: Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                          ),
                        )
                      else if (_filteredSuggestedFriends.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 24)),
                          child: Text(
                            t.rally.createRally.inviteMembers.noFriends,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        Column(
                          children:
                              _filteredSuggestedFriends
                                  .map(
                                    (FollowUserItem friend) => Padding(
                                      padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
                                      child: _MemberListItem(
                                        member: friend,
                                        isInvited: false,
                                        onTap: () => _addMember(friend),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.h(context, 24)),
              ],
            ),
          ),
        ),

        // Bottom action buttons
        Container(
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
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                    side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                    ),
                  ),
                  child: Text(
                    t.rally.createRally.inviteMembers.cancel,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                  ),
                  child: ElevatedButton(
                    onPressed: _onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                      ),
                    ),
                    child: Text(
                      t.rally.createRally.inviteMembers.done,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A collapsible section with header and expandable content.
class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header (tappable)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
                vertical: Responsive.h(context, 14),
              ),
              child: Row(
                children: <Widget>[
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: Responsive.w(context, 20),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 8)),
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content (expandable)
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(
                left: Responsive.w(context, 16),
                right: Responsive.w(context, 16),
                bottom: Responsive.h(context, 12),
              ),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// A single member item in the list.
class _MemberListItem extends StatelessWidget {
  const _MemberListItem({required this.member, required this.isInvited, required this.onTap});

  final FollowUserItem member;
  final bool isInvited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: isInvited ? colorScheme.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          CircleAvatar(
            radius: Responsive.w(context, 22),
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child:
                member.avatarUrl == null
                    ? Text(
                      member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : '?',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),

          SizedBox(width: Responsive.w(context, 12)),

          // Name and username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  member.displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '@${member.username}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Add/Remove button
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isInvited ? colorScheme.errorContainer : colorScheme.onSurface,
              foregroundColor: isInvited ? colorScheme.onErrorContainer : colorScheme.surface,
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
              isInvited
                  ? t.rally.createRally.inviteMembers.remove
                  : t.rally.createRally.inviteMembers.add,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isInvited ? colorScheme.onErrorContainer : colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
