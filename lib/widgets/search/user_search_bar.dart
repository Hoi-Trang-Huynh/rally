import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/models/responses/user_search_response.dart';
import 'package:rally/models/responses/user_search_result.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/user_provider.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/utils/responsive.dart';

import '../../i18n/generated/translations.g.dart';

/// A search bar widget that allows searching for users with a dropdown results list.
///
/// When [expandable] is true the bar starts collapsed (icon only) and expands
/// with an animation when tapped.
class UserSearchBar extends ConsumerStatefulWidget {
  /// Creates a new [UserSearchBar].
  const UserSearchBar({super.key, this.expandable = false});

  /// Whether the bar starts collapsed and expands on tap.
  final bool expandable;

  @override
  ConsumerState<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends ConsumerState<UserSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  String _lastQuery = '';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
        if (widget.expandable && _controller.text.isEmpty) {
          _collapse();
        }
      }
    });
  }

  void _expand() {
    setState(() => _isExpanded = true);
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _collapse() {
    _focusNode.unfocus();
    setState(() => _isExpanded = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query != _lastQuery) {
        setState(() {
          _lastQuery = query;
        });
        // The provider automatically updates when the query parameter changes
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          width: _layerLink.leaderSize?.width ?? Responsive.w(context, 340),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(
              0,
              Responsive.h(context, 50),
            ), // Height of search bar + padding
            child: TapRegion(
              groupId: 'UserSearchDropdown',
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.h(context, 300),
                  ),
                  child: Consumer(
                    builder: (
                      BuildContext context,
                      WidgetRef ref,
                      Widget? child,
                    ) {
                      final Translations t = Translations.of(context);

                      if (_lastQuery.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(Responsive.w(context, 16)),
                          child: Text(
                            t.common.search.typeToSearch,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      final AsyncValue<UserSearchResponse> searchAsync = ref
                          .watch(userSearchProvider(_lastQuery));

                      return searchAsync.when(
                        data: (UserSearchResponse response) {
                          if (response.users.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.all(
                                Responsive.w(context, 16),
                              ),
                              child: Text(
                                t.common.search.noUsersFound,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.h(context, 8),
                            ),
                            shrinkWrap: true,
                            itemCount: response.users.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: 1,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.1),
                                ),
                            itemBuilder: (BuildContext context, int index) {
                              final UserSearchResult user =
                                  response.users[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: Responsive.w(context, 16),
                                  backgroundImage:
                                      user.avatarUrl != null
                                          ? NetworkImage(user.avatarUrl!)
                                          : null,
                                  child:
                                      user.avatarUrl == null
                                          ? Text(
                                            user.username.characters.first
                                                .toUpperCase(),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.labelMedium,
                                          )
                                          : null,
                                ),
                                title: Text(
                                  '@${user.username}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle:
                                    (user.firstName != null ||
                                            user.lastName != null)
                                        ? Text(
                                          '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                              .trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                        : null,
                                onTap: () {
                                  _removeOverlay();
                                  _focusNode.unfocus();

                                  final AppUser? currentUser =
                                      ref.read(appUserProvider).valueOrNull;
                                  final bool isMe =
                                      currentUser?.id != null &&
                                      currentUser!.id == user.id;

                                  if (isMe) {
                                    // Navigate to own profile tab
                                    context.go(AppRoutes.profile);
                                  } else {
                                    // Push to user profile (maintains back stack)
                                    context.push(
                                      AppRoutes.userProfile(user.id),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                        loading:
                            () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error:
                            (Object error, StackTrace stack) => Padding(
                              padding: EdgeInsets.all(
                                Responsive.w(context, 16),
                              ),
                              child: Text(
                                'Error: $error',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, ColorScheme colorScheme) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TapRegion(
        groupId: 'UserSearchDropdown',
        onTapOutside: (_) {
          _focusNode.unfocus();
        },
        child: Container(
          height: Responsive.h(context, 40),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: Translations.of(context).common.search.searchUsers,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
                size: Responsive.w(context, 20),
              ),
              suffixIcon:
                  _controller.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _lastQuery = '';
                          });
                          _overlayEntry?.markNeedsBuild();
                        },
                      )
                      : widget.expandable
                      ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: Responsive.w(context, 18),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _collapse,
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
                vertical: Responsive.h(context, 12),
              ),
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: Responsive.w(context, 14),
              ),
            ),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: Responsive.w(context, 14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!widget.expandable) {
      return _buildTextField(context, colorScheme);
    }

    // Expandable variant: icon button ↔ full-width search bar
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 280),
      sizeCurve: Curves.easeInOut,
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      crossFadeState:
          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _expand,
          child: Container(
            width: Responsive.w(context, 40),
            height: Responsive.w(context, 40),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
              size: Responsive.w(context, 20),
            ),
          ),
        ),
      ),
      secondChild: SizedBox(
        width: double.infinity,
        child: _buildTextField(context, colorScheme),
      ),
    );
  }
}
