import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/models/responses/profile_details_response.dart';
import 'package:rally/utils/validation_constants.dart';
import 'package:rally/utils/validators.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui_helpers.dart';
import 'settings_screen.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/profile_tab_bar.dart';

/// The main profile screen displaying user information.
///
/// Shows the user's avatar, username, stats, bio, and achievements.
/// Uses data from [appUserProvider] for available fields.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates a new [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedTabId = 'achievements';

  // Bio state
  String? _bioText;
  bool _isLoadingBio = true;
  bool _isSavingBio = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBio();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  /// Fetches the bio from the backend.
  Future<void> _fetchBio() async {
    try {
      final ProfileDetailsResponse response =
          await ref.read(userRepositoryProvider).getMyProfileDetails();
      if (mounted) {
        setState(() {
          _bioText = response.bioText;
          _isLoadingBio = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bioText = null;
          _isLoadingBio = false;
        });
      }
    }
  }

  /// Saves the bio to the backend.
  Future<void> _saveBio(String newBio) async {
    final AppUser? user = ref.read(appUserProvider).valueOrNull;
    if (user?.id == null) return;

    // Don't save if unchanged
    if (newBio == (_bioText ?? '')) {
      Navigator.pop(context); // Close sheet
      return;
    }

    // Validation
    final String? error = Validators.validateBio(newBio);
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    setState(() => _isSavingBio = true);

    try {
      await ref.read(userRepositoryProvider).updateUserProfile(userId: user!.id!, bioText: newBio);
      if (mounted) {
        setState(() {
          _bioText = newBio.isEmpty ? null : newBio;
          _isSavingBio = false;
        });
        Navigator.pop(context); // Close sheet
        showSuccessSnackBar(context, Translations.of(context).common.saved);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingBio = false);
        // Don't close sheet on error so user can retry
        showErrorSnackBar(context, e.toString());
      }
    }
  }

  /// Shows the bio edit bottom sheet.
  void _showEditBioBottomSheet(AppUser user) {
    _bioController.text = _bioText ?? '';
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Sheet Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Avatar
              ProfileAvatar(avatarUrl: user.avatarUrl, size: 80, showOnlineIndicator: false),
              const SizedBox(height: 16),
              // Username handle
              Text(
                '@${user.username}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              // Edit Field
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: BioValidation.maxLength,
                autofocus: true,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: t.profile.bioPlaceholder,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        foregroundColor: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(t.common.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSavingBio ? null : () => _saveBio(_bioController.text.trim()),
                      child:
                          _isSavingBio
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                              : Text(t.common.save),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  /// Build profile tabs with translations.
  List<ProfileTabData> _buildTabs(Translations t) {
    return <ProfileTabData>[
      ProfileTabData(id: 'achievements', label: t.profile.achievements),
      ProfileTabData(id: 'posts', label: t.profile.posts),
      ProfileTabData(id: 'rallies', label: t.profile.rallies),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> userAsync = ref.watch(appUserProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return userAsync.when(
      data: (AppUser? user) {
        if (user == null) {
          return Center(child: Text(t.profile.notLoggedIn));
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true, // Required for glassmorphism
          body: AnimationLimiter(
            child: CustomScrollView(
              slivers: <Widget>[
                // Glassmorphism App Bar
                SliverAppBar(
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
                  elevation: 0,
                  pinned: true,
                  centerTitle: true,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        user.username ?? 'User',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface, size: 20),
                    ],
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Profile Content with Staggered Animation
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (Widget widget) {
                          return SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          );
                        },
                        children: <Widget>[
                          const SizedBox(height: 24), // Standard spacing
                          // Avatar with online indicator
                          ProfileAvatar(
                            avatarUrl: user.avatarUrl,
                            size: 100,
                            showOnlineIndicator: true,
                            isOnline: true,
                          ),

                          const SizedBox(height: 16),

                          // @username
                          Text(
                            '@${user.username ?? 'username'}',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stats row
                          ProfileStatsRow(
                            followersCount: '03',
                            followingCount: '03',
                            followersLabel: t.profile.followers,
                            followingLabel: t.profile.followings,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bio section - completely separate sliver to avoid animation conflicts
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        _buildBioSection(colorScheme, textTheme, t, user),
                        const SizedBox(height: 24),
                        const SizedBox(height: 24),
                        // Modular Tab Bar
                        ProfileTabBar(
                          tabs: _buildTabs(t),
                          selectedId: _selectedTabId,
                          onTabSelected: (String id) {
                            setState(() {
                              _selectedTabId = id;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab content
                _buildTabContent(colorScheme),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (Object error, StackTrace stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  /// Builds the bio section with loading, display, and edit states.
  Widget _buildBioSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
    AppUser user,
  ) {
    if (_isLoadingBio) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
      );
    }

    // Display mode - tap to edit
    final bool hasBio = _bioText != null && _bioText!.isNotEmpty;
    return GestureDetector(
      onTap: () => _showEditBioBottomSheet(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                hasBio ? _bioText! : t.profile.addBio,
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      hasBio ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit_outlined,
              size: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colorScheme) {
    switch (_selectedTabId) {
      case 'achievements':
        return _buildPlaceholderGrid(colorScheme, 6);
      case 'posts':
        return _buildPlaceholderGrid(colorScheme, 9);
      case 'rallies':
        return _buildPlaceholderGrid(colorScheme, 3);
      default:
        return _buildPlaceholderGrid(colorScheme, 6);
    }
  }

  Widget _buildPlaceholderGrid(ColorScheme colorScheme, int count) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }, childCount: count),
      ),
    );
  }
}
