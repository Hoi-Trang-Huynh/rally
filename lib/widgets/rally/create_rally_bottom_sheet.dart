import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/rally_draft.dart';
import 'package:rally/models/responses/follow_list_response.dart';
import 'package:rally/providers/rally_draft_provider.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/common/date_range_picker.dart';
import 'package:rally/widgets/common/rich_text_editor.dart';
import 'package:rally/widgets/common/stacked_avatars.dart';
import 'package:rally/widgets/rally/invite_members_sheet.dart';

enum _ActiveDateSelection { none, start, end }

/// Bottom sheet for creating a new rally.
///
/// Includes fields for:
/// - Cover image upload
/// - Rally name
/// - Session duration (start/end dates)
/// - Member invitations
/// - Description (rich text)
///
/// Supports draft persistence - unfinished rallies are saved automatically.
class CreateRallyBottomSheet extends ConsumerStatefulWidget {
  /// Creates a new [CreateRallyBottomSheet].
  const CreateRallyBottomSheet({super.key});

  @override
  ConsumerState<CreateRallyBottomSheet> createState() => _CreateRallyBottomSheetState();
}

class _CreateRallyBottomSheetState extends ConsumerState<CreateRallyBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final QuillController _descriptionController = QuillController.basic();
  final FocusNode _descriptionFocusNode = FocusNode();
  final GlobalKey _descriptionKey = GlobalKey();

  String? _coverImagePath;
  DateTime? _startDate;
  DateTime? _endDate;
  _ActiveDateSelection _activeDateSelection = _ActiveDateSelection.none;
  List<FollowUserItem> _invitedMembers = <FollowUserItem>[];
  bool _showingInviteMembers = false;
  bool _draftLoaded = false;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _descriptionFocusNode.addListener(_onDescriptionFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_draftLoaded) {
      _loadDraft();
    }
  }

  void _loadDraft() {
    final RallyDraft? draft = ref.read(rallyDraftProvider);
    if (draft != null && draft.hasContent) {
      // Temporarily disable saving while loading
      _isClearing = true;
      _nameController.text = draft.name ?? '';
      _coverImagePath = draft.coverImagePath;
      _startDate = draft.startDate;
      _endDate = draft.endDate;

      // Restore invited members from draft
      _invitedMembers =
          draft.invitedMembers.map((Map<String, String?> m) {
            return FollowUserItem(
              id: m['id'] ?? '',
              username: m['username'] ?? '',
              firstName: m['firstName'],
              lastName: m['lastName'],
              avatarUrl: m['avatarUrl'],
            );
          }).toList();

      // Restore description from JSON
      if (draft.description != null && draft.description!.isNotEmpty) {
        try {
          final List<dynamic> deltaJson = jsonDecode(draft.description!) as List<dynamic>;
          _descriptionController.document = Document.fromJson(deltaJson);
        } catch (e) {
          // If parsing fails, leave description empty
        }
      }

      _isClearing = false;
      _draftLoaded = true;

      // Show toast that draft was restored
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final Translations t = Translations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.rally.createRally.actions.draftRestored),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
    _draftLoaded = true;
  }

  void _saveDraft() {
    if (_isClearing) return; // Don't save during clear operation

    // Serialize Quill document to JSON string
    final String descriptionJson = jsonEncode(_descriptionController.document.toDelta().toJson());

    ref
        .read(rallyDraftProvider.notifier)
        .updateDraft(
          name: _nameController.text,
          description: descriptionJson,
          coverImagePath: _coverImagePath,
          startDate: _startDate,
          endDate: _endDate,
          invitedMembers:
              _invitedMembers
                  .map(
                    (FollowUserItem m) => <String, String?>{
                      'id': m.id,
                      'username': m.username,
                      'firstName': m.firstName,
                      'lastName': m.lastName,
                      'avatarUrl': m.avatarUrl,
                    },
                  )
                  .toList(),
        );
  }

  void _onFieldChanged() {
    setState(() {}); // Rebuild to update character counter
    _saveDraft();
  }

  void _onDescriptionChanged() {
    if (!_isClearing && _draftLoaded) {
      _saveDraft();
    }
  }

  void _clearDraft() {
    // Set flag to prevent _onFieldChanged from saving
    _isClearing = true;

    // Clear the draft in provider
    ref.read(rallyDraftProvider.notifier).clearDraft();

    // Clear local state - don't clear description controller as it may cause focus issues
    setState(() {
      _nameController.text = '';
      _coverImagePath = null;
      _startDate = null;
      _endDate = null;
      _invitedMembers = <FollowUserItem>[];
    });

    // Clear description separately and unfocus after
    _descriptionController.clear();

    // Unfocus any focused element AFTER all changes are done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });

    // Re-enable saving after clearing is complete
    _isClearing = false;
  }

  void _onDescriptionFocus() {
    // Don't scroll during draft clearing
    if (_isClearing) return;

    if (_descriptionFocusNode.hasFocus) {
      // Wait for keyboard to fully appear, then scroll to description
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (_descriptionKey.currentContext != null && mounted && !_isClearing) {
          Scrollable.ensureVisible(
            _descriptionKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.removeListener(_onDescriptionFocus);
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _coverImagePath = image.path;
      });
      _saveDraft();
    }
  }

  void _toggleDateSelection(_ActiveDateSelection selection) {
    setState(() {
      if (_activeDateSelection == selection) {
        _activeDateSelection = _ActiveDateSelection.none;
      } else {
        _activeDateSelection = selection;
      }
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      if (_activeDateSelection == _ActiveDateSelection.start) {
        _startDate = date;
        // If end date is before start date, clear it or move it?
        // For now, let's just ensure end date is valid or clear it if invalid.
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      } else if (_activeDateSelection == _ActiveDateSelection.end) {
        // Ensure end date is not before start date
        if (_startDate != null && date.isBefore(_startDate!)) {
          _endDate = _startDate;
        } else {
          _endDate = date;
        }
      }
      // Keep selection active to allow changing, or close it?
      // User said "click on either... will show a calendar", implies toggle.
      // Usually users might want to close after picking. I'll keep it open for better UX if they mistapped.
    });
    _saveDraft();
  }

  void _showInviteMembersSheet() {
    setState(() {
      _showingInviteMembers = true;
    });
  }

  void _hideInviteMembersSheet() {
    setState(() {
      _showingInviteMembers = false;
    });
  }

  void _onInviteMembersDone(List<FollowUserItem> invitedMembers) {
    setState(() {
      _invitedMembers = invitedMembers;
      _showingInviteMembers = false;
    });
    _saveDraft();
  }

  void _createRally() {
    final Translations t = Translations.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.rally.createRally.validation.nameRequired)));
      return;
    }

    // TODO: Implement rally creation with RallyRepository
    // Clear draft on successful creation
    ref.read(rallyDraftProvider.notifier).clearDraft();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.rally.createRally.success.comingSoon)));
  }

  Widget _buildInviteMembersPage(ColorScheme colorScheme) {
    final EdgeInsets keyboardInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: InviteMembersPage(
              initialInvitedMembers: _invitedMembers,
              onBack: _hideInviteMembersSheet,
              onDone: _onInviteMembersDone,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    // Show InviteMembersPage as internal navigation
    if (_showingInviteMembers) {
      return _buildInviteMembersPage(colorScheme);
    }

    final bool hasDraft = ref.watch(rallyDraftProvider)?.hasContent ?? false;

    return AppBottomSheet.draggable(
      title: t.rally.createRally.title,
      action: TextButton(
        onPressed: hasDraft ? _clearDraft : null,
        child: Text(
          t.rally.createRally.actions.clearDraft,
          style: textTheme.labelMedium?.copyWith(
            color: hasDraft ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.3),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      bodyBuilder: (ScrollController scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: Responsive.w(context, 24),
            right: Responsive.w(context, 24),
            top: Responsive.h(context, 16),
            bottom: Responsive.h(context, 24) + MediaQuery.of(context).padding.bottom,
          ),
          children: <Widget>[
            // Cover Image Section
            Text(
              t.rally.createRally.coverImage.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                width: double.infinity,
                height: Responsive.h(context, 160),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child:
                    _coverImagePath == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: Responsive.w(context, 48),
                              color: colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(height: Responsive.h(context, 8)),
                            Text(
                              t.rally.createRally.coverImage.tapToUpload,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: Responsive.h(context, 4)),
                            Text(
                              t.rally.createRally.coverImage.fileFormat,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                          child: Image.file(
                            File(_coverImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  size: Responsive.w(context, 48),
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
              ),
            ),

            SizedBox(height: Responsive.h(context, 24)),

            // Rally Name Section
            Text(
              t.rally.createRally.name.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            TextField(
              controller: _nameController,
              maxLength: 60,
              buildCounter:
                  (
                    _, {
                    required int currentLength,
                    required int? maxLength,
                    required bool isFocused,
                  }) => null,
              decoration: InputDecoration(
                hintText: t.rally.createRally.name.placeholder,
                hintStyle: textTheme.bodyMedium?.copyWith(
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
                  vertical: Responsive.h(context, 14),
                ),
                counter: Text(
                  t.rally.createRally.name.maxLength.replaceAll(
                    '{count}',
                    '${_nameController.text.length}',
                  ),
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),

            SizedBox(height: Responsive.h(context, 24)),

            // Session Duration Section
            Text(
              t.rally.createRally.duration.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DateSelectorButton(
                    label: t.rally.createRally.duration.from,
                    hint: t.rally.createRally.duration.selectStartDate,
                    date: _startDate,
                    onTap: () => _toggleDateSelection(_ActiveDateSelection.start),
                    isActive: _activeDateSelection == _ActiveDateSelection.start,
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: _DateSelectorButton(
                    label: t.rally.createRally.duration.to,
                    hint: t.rally.createRally.duration.selectEndDate,
                    date: _endDate,
                    onTap: () => _toggleDateSelection(_ActiveDateSelection.end),
                    isActive: _activeDateSelection == _ActiveDateSelection.end,
                  ),
                ),
              ],
            ),
            if (_activeDateSelection != _ActiveDateSelection.none) ...<Widget>[
              SizedBox(height: Responsive.h(context, 12)),
              DateRangePicker(
                startDate: _startDate,
                endDate: _endDate,
                firstDate:
                    _activeDateSelection == _ActiveDateSelection.start
                        ? DateTime.now()
                        : (_startDate ?? DateTime.now()),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                isSelectingStart: _activeDateSelection == _ActiveDateSelection.start,
                onDateSelected: _onDateChanged,
                onCancel: () => _toggleDateSelection(_ActiveDateSelection.none),
                onTodayPressed: () => _onDateChanged(DateTime.now()),
              ),
            ],

            SizedBox(height: Responsive.h(context, 24)),

            // Invite Members Section
            Text(
              t.rally.createRally.inviteMembers.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            // Conditional layout based on invited members
            if (_invitedMembers.isEmpty)
              // Empty state: Full-width tappable container
              GestureDetector(
                onTap: _showInviteMembersSheet,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 16),
                    vertical: Responsive.h(context, 14),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.person_add_outlined,
                        size: Responsive.w(context, 22),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: Responsive.w(context, 12)),
                      Expanded(
                        child: Text(
                          t.rally.createRally.inviteMembers.tapToInvite,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: Responsive.w(context, 20),
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              )
            else
              // With members: Tappable row showing avatars + count
              GestureDetector(
                onTap: _showInviteMembersSheet,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 12),
                    vertical: Responsive.h(context, 10),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: <Widget>[
                      // Stacked avatars
                      StackedAvatars(
                        items:
                            _invitedMembers
                                .map(
                                  (FollowUserItem member) => StackedAvatarItem(
                                    id: member.id,
                                    imageUrl: member.avatarUrl,
                                    fallbackText: member.displayName,
                                  ),
                                )
                                .toList(),
                        maxVisible: 4,
                        avatarRadius: 16,
                        overlapFactor: 0.6,
                      ),
                      SizedBox(width: Responsive.w(context, 12)),
                      // Member count text
                      Expanded(
                        child: Text(
                          t.rally.createRally.inviteMembers.memberCount.replaceAll(
                            '{count}',
                            _invitedMembers.length.toString(),
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Edit indicator
                      Icon(
                        Icons.edit_outlined,
                        size: Responsive.w(context, 18),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: Responsive.h(context, 24)),

            // Description Section
            Text(
              t.rally.createRally.description.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            RichTextEditor(
              key: _descriptionKey,
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              hintText: t.rally.createRally.description.placeholder,
              maxLines: 6,
            ),

            SizedBox(height: Responsive.h(context, 32)),

            // Action Buttons
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                      side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                      ),
                    ),
                    child: Text(
                      t.rally.createRally.actions.cancel,
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
                  child: ElevatedButton(
                    onPressed: _createRally,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                      ),
                    ),
                    child: Text(
                      t.rally.createRally.actions.create,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(context, 24)),
          ],
        );
      },
    );
  }
}

/// Date selector button widget.
class _DateSelectorButton extends StatelessWidget {
  const _DateSelectorButton({
    required this.label,
    required this.hint,
    required this.date,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final String hint;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 12)),
        decoration: BoxDecoration(
          color:
              isActive
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: Responsive.w(context, 16),
                  color: colorScheme.onSurface,
                ),
                SizedBox(width: Responsive.w(context, 6)),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(context, 6)),
            Text(
              date != null ? '${date!.month}/${date!.day}/${date!.year}' : hint,
              style: textTheme.labelSmall?.copyWith(
                color:
                    date != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
