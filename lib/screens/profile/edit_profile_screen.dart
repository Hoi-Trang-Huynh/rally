import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui_helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_text_field.dart';
import 'widgets/profile_avatar.dart';

/// Screen for editing user profile.
///
/// Allows updating username, first name, last name, and avatar (placeholder).
class EditProfileScreen extends ConsumerStatefulWidget {
  /// Creates a new [EditProfileScreen].
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  String? _usernameError;
  String? _firstNameError;
  String? _lastNameError;

  String? _originalUsername;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final AppUser? user = ref.read(appUserProvider).valueOrNull;
    if (user != null) {
      _usernameController.text = user.username ?? '';
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _originalUsername = user.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _showPhotoOptions() {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  t.settings.changePhoto,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  title: Text(
                    t.settings.chooseFromGallery,
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showInfoSnackBar(context, t.settings.comingSoon);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  title: Text(
                    t.settings.takePhoto,
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showInfoSnackBar(context, t.settings.comingSoon);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    // Clear errors
    setState(() {
      _usernameError = null;
      _firstNameError = null;
      _lastNameError = null;
    });

    // Validate fields
    _usernameError = Validators.validateUsername(_usernameController.text);
    _firstNameError = Validators.validateFirstName(_firstNameController.text);
    _lastNameError = Validators.validateLastName(_lastNameController.text);

    setState(() {});

    if (_usernameError != null || _firstNameError != null || _lastNameError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String newUsername = _usernameController.text.trim();

      // Check username availability only if it changed
      if (newUsername != _originalUsername) {
        final bool available = await ref
            .read(userRepositoryProvider)
            .checkUsernameAvailability(newUsername);
        if (!available) {
          setState(() {
            _usernameError = t.validation.username.taken;
            _isLoading = false;
          });
          return;
        }
      }

      // Get current user ID
      final AppUser? user = ref.read(appUserProvider).valueOrNull;
      if (user?.id == null) {
        throw Exception('User ID not found');
      }

      // Update profile
      await ref
          .read(userRepositoryProvider)
          .updateUserProfile(
            userId: user!.id!,
            username: newUsername,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );

      // Refresh user state
      ref.invalidate(appUserProvider);

      if (mounted) {
        showSuccessSnackBar(context, t.settings.saveChanges);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> userAsync = ref.watch(appUserProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.settings.editProfile,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        data:
            (AppUser? user) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  // Avatar with camera button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showPhotoOptions();
                    },
                    child: Stack(
                      children: <Widget>[
                        ProfileAvatar(avatarUrl: user?.avatarUrl, size: 100),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
                            ),
                            child: Icon(Icons.camera_alt, size: 18, color: colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    labelText: t.auth.signup.username,
                    errorText: _usernameError,
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 16),

                  // First and Last name row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: AuthTextField(
                          controller: _firstNameController,
                          labelText: t.auth.signup.firstName,
                          errorText: _firstNameError,
                          enabled: !_isLoading,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AuthTextField(
                          controller: _lastNameController,
                          labelText: t.auth.signup.lastName,
                          errorText: _lastNameError,
                          enabled: !_isLoading,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                              : Text(t.settings.saveChanges),
                    ),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
