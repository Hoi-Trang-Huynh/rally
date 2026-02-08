import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rally/models/responses/availability_response.dart';
import 'package:rally/screens/auth/widgets/auth_text_field.dart';
import 'package:rally/utils/image_upload_helper.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import '../../utils/ui_helpers.dart';
import '../../utils/validation_constants.dart';
import '../../utils/validators.dart';
import 'widgets/profile_avatar.dart';

/// Screen for editing user profile.
///
/// Allows updating username, first name, last name, and avatar.
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
  bool _isUploadingAvatar = false;
  String? _usernameError;
  String? _firstNameError;
  String? _lastNameError;

  String? _originalUsername;
  final ImagePicker _picker = ImagePicker();

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
    // colorScheme was unused, removed.

    showAppBottomSheet<void>(
      context: context,
      sheet: AppBottomSheet.fixed(
        title: t.settings.changePhoto,
        body: Column(
          children: <Widget>[
            _buildPhotoOption(
              icon: Icons.photo_library_rounded,
              label: t.settings.chooseFromGallery,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            _buildPhotoOption(
              icon: Icons.camera_alt_rounded,
              label: t.settings.takePhoto,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ... (keep helper logging and upload methods as is, skipping re-definition in this chunk to focus on UI unless needed context)

  // ... (skipping down to build method for Avatar stack replacement)

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 24),
          vertical: Responsive.h(context, 12),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            SizedBox(width: Responsive.w(context, 16)),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: ImageValidation.avatarMaxWidth,
        maxHeight: ImageValidation.avatarMaxHeight,
        imageQuality: ImageValidation.imageQuality,
      );

      if (image == null) return;

      await _uploadAvatar(File(image.path));
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    if (_isUploadingAvatar) return;

    setState(() => _isUploadingAvatar = true);

    try {
      // 1. Get user ID
      final AppUser? user = ref.read(appUserProvider).valueOrNull;
      if (user?.id == null) throw Exception('User not found');

      // 2. Upload and verify avatar using helper
      final ImageUploadHelper helper = ref.read(imageUploadHelperProvider);
      await helper.uploadAndVerifyAvatar(file: imageFile, userId: user!.id!);

      // 3. Refresh profile provider to confirm new image (not auth provider)
      ref.invalidate(myProfileProvider);

      if (mounted) {
        showSuccessSnackBar(context, 'Avatar updated successfully');
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed to upload avatar: $e');
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
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
        final AvailabilityResponse response = await ref
            .read(userRepositoryProvider)
            .checkUsernameAvailability(newUsername);
        if (!response.available) {
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

      // Refresh profile state (not auth provider)
      ref.invalidate(myProfileProvider);

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
              padding: EdgeInsets.all(Responsive.w(context, 24)),
              child: Column(
                children: <Widget>[
                  // Avatar with camera button
                  GestureDetector(
                    onTap:
                        _isUploadingAvatar
                            ? null
                            : () {
                              HapticFeedback.lightImpact();
                              _showPhotoOptions();
                            },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surfaceContainerHighest,
                              width: 1,
                            ),
                          ),
                          child: ProfileAvatar(avatarUrl: user?.avatarUrl, baseSize: 120),
                        ),
                        if (_isUploadingAvatar)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 3),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.h(context, 32)),

                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    labelText: t.auth.signup.username,
                    errorText: _usernameError,
                    enabled: !_isLoading,
                  ),

                  SizedBox(height: Responsive.h(context, 16)),

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
                      SizedBox(width: Responsive.w(context, 16)),
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

                  SizedBox(height: Responsive.h(context, 32)),

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
                                height: Responsive.w(context, 20),
                                width: Responsive.w(context, 20),
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
