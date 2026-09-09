import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/fade_slide_animation.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService =
      AuthService.instance;

  final ImagePicker _imagePicker =
  ImagePicker();

  UserModel? _user;

  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  String? _error;

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController();

    _cityController =
        TextEditingController();

    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final user =
      await _authService
          .getCurrentUserProfile();

      if (!mounted) return;

      if (user == null) {
        throw Exception(
          'Student profile not found.',
        );
      }

      _nameController.text = user.name;
      _cityController.text = user.city;

      setState(() {
        _user = user;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(e);
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // PICK AND UPLOAD PROFILE PHOTO
  // ============================================================

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;

    try {
      final image =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 900,
        maxHeight: 900,
      );

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final bytes =
      await image.readAsBytes();

      final currentUser =
          _authService.currentUser;

      if (currentUser == null) {
        throw Exception(
          'User is not logged in.',
        );
      }

      final photoUrl =
      await StorageService.instance
          .uploadProfilePhoto(
        uid: currentUser.uid,
        imageBytes: bytes,
      );

      await _authService.updateProfilePhoto(
        photoUrl,
      );

      final updatedUser =
      await _authService
          .getCurrentUserProfile();

      if (!mounted) return;

      if (updatedUser != null) {
        setState(() {
          _user = updatedUser;
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanError(e),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    final name =
    _nameController.text.trim();

    final city =
    _cityController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
      );
      return;
    }

    if (city.isEmpty) {
      _showMessage(
        'Please enter your city.',
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _authService.updateProfile(
        name: name,
        city: city,
      );

      final updatedUser =
      await _authService
          .getCurrentUserProfile();

      if (!mounted) return;

      if (updatedUser != null) {
        setState(() {
          _user = updatedUser;
        });
      }

      setState(() {
        _isSaving = false;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        _cleanError(e),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanError(e),
      );
    }
  }

  // ============================================================
  // EDIT PROFILE SHEET
  // ============================================================

  void _openEditProfile() {
    if (_user == null) return;

    _nameController.text = _user!.name;
    _cityController.text = _user!.city;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
              context,
              setSheetState,
              ) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(
                  context,
                ).viewInsets.bottom +
                    20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(
                              sheetContext,
                            ).pop();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller:
                      _nameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Full Name',
                        prefixIcon:
                        Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller:
                      _cityController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration:
                      const InputDecoration(
                        labelText: 'City',
                        prefixIcon:
                        Icon(
                          Icons.location_city_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                          setSheetState(
                                () {},
                          );

                          await _saveProfile();
                        },
                        child: _isSaving
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                            Colors.white,
                          ),
                        )
                            : const Text(
                          'Save Changes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    )
        .trim();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
        ),
        actions: [
          if (!_isLoading &&
              _user != null)
            IconButton(
              onPressed:
              _openEditProfile,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_outlined,
                size: 52,
                color:
                AppColors.textSecondary,
              ),

              const SizedBox(height: 15),

              Text(
                _error!,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed:
                _loadProfile,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;

    if (user == null) {
      return const Center(
        child: Text(
          'Profile not available.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.all(20),
        children: [
          FadeSlideAnimation(
            child:
            _buildProfileHeader(
              user,
            ),
          ),

          const SizedBox(height: 22),

          FadeSlideAnimation(
            delay:
            const Duration(
              milliseconds: 80,
            ),
            child:
            _buildInformationCard(
              user,
            ),
          ),

          const SizedBox(height: 18),

          FadeSlideAnimation(
            delay:
            const Duration(
              milliseconds: 140,
            ),
            child: _buildActions(),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
      UserModel user,
      ) {
    final hasPhoto =
        user.photoUrl != null &&
            user.photoUrl!.trim().isNotEmpty;

    return Container(
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Stack(
            alignment:
            Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor:
                Colors.white,
                backgroundImage:
                hasPhoto
                    ? NetworkImage(
                  user.photoUrl!,
                )
                    : null,
                child: !hasPhoto
                    ? const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color:
                  AppColors.primary,
                )
                    : null,
              ),

              GestureDetector(
                onTap:
                _isUploadingPhoto
                    ? null
                    : _pickAndUploadPhoto,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration:
                  const BoxDecoration(
                    color: Colors.white,
                    shape:
                    BoxShape.circle,
                  ),
                  child:
                  _isUploadingPhoto
                      ? const Padding(
                    padding:
                    EdgeInsets.all(
                      8,
                    ),
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .camera_alt_outlined,
                    size: 18,
                    color:
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            user.name.isEmpty
                ? 'Student'
                : user.name,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              fontSize: 21,
              fontWeight:
              FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            user.email,
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
              Colors.white
                  .withValues(
                alpha: 0.85,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration:
            BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),
            child: const Text(
              'Student',
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard(
      UserModel user,
      ) {
    final courseValue =
    user.courseId?.trim().isNotEmpty ==
        true
        ? user.courseId!
        : 'Not assigned';

    final batchValue =
    user.batchId?.trim().isNotEmpty ==
        true
        ? user.batchId!
        : 'Not assigned';

    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _InfoTile(
            icon:
            Icons.person_outline,
            title: 'Full Name',
            value: user.name.isEmpty
                ? 'Not added'
                : user.name,
          ),

          const Divider(height: 24),

          _InfoTile(
            icon:
            Icons.email_outlined,
            title: 'Email',
            value: user.email.isEmpty
                ? 'Not available'
                : user.email,
          ),

          const Divider(height: 24),

          _InfoTile(
            icon:
            Icons.phone_outlined,
            title: 'Phone',
            value: user.phone.isEmpty
                ? 'Not added'
                : user.phone,
          ),

          const Divider(height: 24),

          _InfoTile(
            icon:
            Icons.location_city_outlined,
            title: 'City',
            value: user.city.isEmpty
                ? 'Not added'
                : user.city,
          ),

          const Divider(height: 24),

          _InfoTile(
            icon:
            Icons.school_outlined,
            title: 'Campus',
            value:
            user.campus.isEmpty
                ? 'Not assigned'
                : user.campus,
          ),

          const Divider(height: 24),

          _InfoTile(
            icon:
            Icons.menu_book_outlined,
            title: 'Course',
            value: courseValue,
          ),

          const Divider(height: 24),

          _InfoTile(
            icon:
            Icons.groups_outlined,
            title: 'Batch',
            value: batchValue,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return Column(
      children: [
        _ActionTile(
          icon:
          Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle:
          'Update your name and city',
          onTap:
          _openEditProfile,
        ),

        const SizedBox(height: 10),

        _ActionTile(
          icon:
          Icons.logout_rounded,
          title: 'Logout',
          subtitle:
          'Sign out from your account',
          iconColor:
          AppColors.error,
          onTap: _logout,
        ),
      ],
    );
  }
}

// ============================================================
// INFO TILE
// ============================================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration:
          BoxDecoration(
            color:
            AppColors.accentLight,
            borderRadius:
            BorderRadius.circular(
              11,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
            AppColors.primary,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  fontSize: 11,
                  color:
                  AppColors
                      .textSecondary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value.isEmpty
                    ? 'Not available'
                    : value,
                style:
                const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  AppColors
                      .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACTION TILE
// ============================================================

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        iconColor ?? AppColors.primary;

    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(17),
        child: Container(
          padding:
          const EdgeInsets.all(15),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color: color
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style:
                      const TextStyle(
                        fontSize: 11,
                        color:
                        AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 14,
                color:
                AppColors
                    .textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}