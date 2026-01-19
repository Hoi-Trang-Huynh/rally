import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../models/feedback_category.dart';
import '../../providers/auth_provider.dart';
import '../../services/feedback_repository.dart';
import '../../utils/responsive.dart';

/// Screen for submitting user feedback.
///
/// Allows users to select feedback categories and write their thoughts.
class FeedbackScreen extends ConsumerStatefulWidget {
  /// Creates a new [FeedbackScreen].
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();
  FeedbackCategory? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final Translations t = Translations.of(context);

    // Validate
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settings.feedback.selectCategory),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final String comment = _commentController.text.trim();
    if (comment.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final AppUser? user = ref.read(appUserProvider).valueOrNull;
      if (user == null || user.username == null || user.username!.isEmpty) return;

      await ref
          .read(feedbackRepositoryProvider)
          .submitFeedback(
            username: user.username!,
            comment: comment,
            categories: <String>[_selectedCategory!.value],
            avatarUrl: user.avatarUrl,
          );

      if (!mounted) return;

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settings.feedback.success),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settings.feedback.error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getCategoryLabel(FeedbackCategory category, Translations t) {
    switch (category) {
      case FeedbackCategory.uiUx:
        return t.settings.feedback.categories.uiUx;
      case FeedbackCategory.bug:
        return t.settings.feedback.categories.bug;
      case FeedbackCategory.feature:
        return t.settings.feedback.categories.feature;
      case FeedbackCategory.performance:
        return t.settings.feedback.categories.performance;
      case FeedbackCategory.other:
        return t.settings.feedback.categories.other;
    }
  }

  IconData _getCategoryIcon(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.uiUx:
        return Icons.design_services_outlined;
      case FeedbackCategory.bug:
        return Icons.bug_report_outlined;
      case FeedbackCategory.feature:
        return Icons.lightbulb_outline;
      case FeedbackCategory.performance:
        return Icons.speed_outlined;
      case FeedbackCategory.other:
        return Icons.more_horiz;
    }
  }

  Widget _buildCategoryChip(
    FeedbackCategory category,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    final bool isSelected = _selectedCategory == category;
    return ChoiceChip(
      selected: isSelected,
      avatar: Icon(
        _getCategoryIcon(category),
        size: Responsive.w(context, 18),
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
      ),
      label: Text(_getCategoryLabel(category, t)),
      labelStyle: textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: colorScheme.primaryContainer,
      side: BorderSide(
        color:
            isSelected ? colorScheme.primaryContainer : colorScheme.outline.withValues(alpha: 0.5),
      ),
      onSelected: (bool selected) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          t.settings.feedback.title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 24),
            vertical: Responsive.h(context, 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Subtitle
              Text(
                t.settings.feedback.subtitle,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),

              SizedBox(height: Responsive.h(context, 24)),

              // Category chips
              Text(
                t.settings.feedback.selectCategory,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),

              SizedBox(height: Responsive.h(context, 12)),

              Wrap(
                spacing: Responsive.w(context, 8),
                runSpacing: Responsive.h(context, 8),
                children:
                    FeedbackCategory.values.map((FeedbackCategory category) {
                      return _buildCategoryChip(category, colorScheme, textTheme, t);
                    }).toList(),
              ),

              SizedBox(height: Responsive.h(context, 24)),

              // Comment input
              TextField(
                controller: _commentController,
                maxLines: 6,
                maxLength: 1000,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: t.settings.feedback.placeholder,
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(Responsive.w(context, 16)),
                ),
              ),

              SizedBox(height: Responsive.h(context, 32)),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: Responsive.h(context, 52),
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child:
                      _isSubmitting
                          ? SizedBox(
                            width: Responsive.w(context, 24),
                            height: Responsive.w(context, 24),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                          : Text(
                            t.settings.feedback.submit,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                ),
              ),

              SizedBox(height: Responsive.h(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}
