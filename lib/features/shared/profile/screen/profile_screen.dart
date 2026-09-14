import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/routes/app_routes.dart';
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
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService =
      AuthService.instance;

  final ImagePicker _imagePicker =
  ImagePicker();

  // ============================================================
  // STATE
  // ============================================================

  UserModel? _user;

  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  String? _error;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;

  // ============================================================
  // INIT
  // ============================================================

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
      final UserModel? user =
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

      print('==========================================');
      print('PROFILE LOADED');
      print('NAME: ${user.name}');
      print('EMAIL: ${user.email}');
      print('PHOTO URL: ${user.photoUrl}');
      print('==========================================');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // PICK + UPLOAD PROFILE PHOTO
  // ============================================================

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) {
      return;
    }

    try {
      // --------------------------------------------------------
      // PICK IMAGE
      // --------------------------------------------------------

      final XFile? image =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      // --------------------------------------------------------
      // READ IMAGE BYTES
      // --------------------------------------------------------

      final Uint8List imageBytes =
      await image.readAsBytes();

      if (imageBytes.isEmpty) {
        throw Exception(
          'Selected image could not be read.',
        );
      }

      // --------------------------------------------------------
      // CURRENT FIREBASE USER
      // --------------------------------------------------------

      final currentUser =
          _authService.currentUser;

      if (currentUser == null) {
        throw Exception(
          'User is not logged in.',
        );
      }

      print('==========================================');
      print('STARTING PROFILE PHOTO UPDATE');
      print('UID: ${currentUser.uid}');
      print('IMAGE SIZE: ${imageBytes.length}');
      print('==========================================');

      // --------------------------------------------------------
      // UPLOAD TO FIREBASE STORAGE
      // --------------------------------------------------------

      final String uploadedUrl =
      await StorageService.instance
          .uploadProfilePhoto(
        uid: currentUser.uid,
        imageBytes: imageBytes,
      );

      if (uploadedUrl.trim().isEmpty) {
        throw Exception(
          'Profile photo upload failed.',
        );
      }

      // --------------------------------------------------------
      // CACHE BUSTING
      // --------------------------------------------------------
      //
      // Firebase Storage uses the same file path:
      // profiles/{uid}.jpg
      //
      // Browser may cache the old image.
      // Adding a unique query value forces the browser
      // to load the latest image.
      // --------------------------------------------------------

      final String photoUrl =
      uploadedUrl.contains('?')
          ? '$uploadedUrl&v=${DateTime.now().millisecondsSinceEpoch}'
          : '$uploadedUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      print('==========================================');
      print('UPLOADED PHOTO URL');
      print(photoUrl);
      print('==========================================');

      // --------------------------------------------------------
      // SAVE URL TO FIRESTORE
      // --------------------------------------------------------

      await _authService.updateProfilePhoto(
        photoUrl,
      );

      // --------------------------------------------------------
      // RELOAD PROFILE FROM FIRESTORE
      // --------------------------------------------------------

      final UserModel? updatedUser =
      await _authService
          .getCurrentUserProfile();

      if (!mounted) return;

      if (updatedUser == null) {
        throw Exception(
          'Profile was updated but could not be reloaded.',
        );
      }

      print('==========================================');
      print('UPDATED USER PROFILE');
      print('PHOTO URL: ${updatedUser.photoUrl}');
      print('==========================================');

      setState(() {
        _user = updatedUser;
      });

      _showMessage(
        'Profile photo updated successfully.',
      );
    } catch (error) {
      if (!mounted) return;

      print(
        'PROFILE PHOTO UPDATE ERROR: $error',
      );

      _showMessage(
        _cleanError(error),
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

  Future<bool> _saveProfile() async {
    final String name =
    _nameController.text.trim();

    final String city =
    _cityController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
      );
      return false;
    }

    if (name.length < 2) {
      _showMessage(
        'Name must contain at least 2 characters.',
      );
      return false;
    }

    if (city.isEmpty) {
      _showMessage(
        'Please enter your city.',
      );
      return false;
    }

    if (_isSaving) {
      return false;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      // --------------------------------------------------------
      // UPDATE FIRESTORE
      // --------------------------------------------------------

      await _authService.updateProfile(
        name: name,
        city: city,
      );

      // --------------------------------------------------------
      // RELOAD PROFILE
      // --------------------------------------------------------

      final UserModel? updatedUser =
      await _authService
          .getCurrentUserProfile();

      if (!mounted) {
        return false;
      }

      if (updatedUser != null) {
        setState(() {
          _user = updatedUser;
        });
      }

      setState(() {
        _isSaving = false;
      });

      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        _cleanError(error),
      );

      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from your student account?',
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
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // --------------------------------------------------------
      // FIREBASE SIGN OUT
      // --------------------------------------------------------

      await _authService.logout();

      if (!mounted) return;

      // --------------------------------------------------------
      // CLEAR NAVIGATION STACK
      // --------------------------------------------------------

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        AppRoutes.login,
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        _cleanError(error),
      );
    }
  }

  // ============================================================
  // EDIT PROFILE SHEET
  // ============================================================

  void _openEditProfile() {
    final UserModel? user = _user;

    if (user == null) {
      return;
    }

    _nameController.text = user.name;
    _cityController.text = user.city;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
            MediaQuery.of(
              sheetContext,
            ).viewInsets.bottom +
                20,
          ),
          child: StatefulBuilder(
            builder: (
                context,
                setSheetState,
                ) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================

                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration:
                          BoxDecoration(
                            color: AppColors
                                .primary
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),
                          child:
                          const Icon(
                            Icons
                                .edit_outlined,
                            color: AppColors
                                .primary,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                'Edit Profile',
                                style:
                                TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Update your personal information',
                                style:
                                TextStyle(
                                  fontSize: 11,
                                  color: AppColors
                                      .textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed:
                          _isSaving
                              ? null
                              : () {
                            Navigator.of(
                              sheetContext,
                            ).pop();
                          },
                          icon:
                          const Icon(
                            Icons
                                .close_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // =================================================
                    // NAME
                    // =================================================

                    TextField(
                      controller:
                      _nameController,
                      enabled:
                      !_isSaving,
                      textCapitalization:
                      TextCapitalization
                          .words,
                      keyboardType:
                      TextInputType.name,
                      decoration:
                      InputDecoration(
                        labelText:
                        'Full Name',
                        hintText:
                        'Enter your full name',
                        prefixIcon:
                        const Icon(
                          Icons
                              .person_outline,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // =================================================
                    // CITY
                    // =================================================

                    TextField(
                      controller:
                      _cityController,
                      enabled:
                      !_isSaving,
                      textCapitalization:
                      TextCapitalization
                          .words,
                      keyboardType:
                      TextInputType
                          .streetAddress,
                      decoration:
                      InputDecoration(
                        labelText:
                        'City',
                        hintText:
                        'Enter your city',
                        prefixIcon:
                        const Icon(
                          Icons
                              .location_city_outlined,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =================================================
                    // SAVE
                    // =================================================

                    SizedBox(
                      width:
                      double.infinity,
                      height: 52,
                      child:
                      FilledButton(
                        onPressed:
                        _isSaving
                            ? null
                            : () async {
                          setSheetState(
                                () {},
                          );

                          final bool
                          saved =
                          await _saveProfile();

                          if (!mounted) {
                            return;
                          }

                          if (saved) {
                            Navigator.of(
                              sheetContext,
                            ).pop();

                            _showMessage(
                              'Profile updated successfully.',
                            );
                          }

                          if (mounted) {
                            setSheetState(
                                  () {},
                            );
                          }
                        },
                        child: _isSaving
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                            color:
                            Colors.white,
                          ),
                        )
                            : const Text(
                          'Save Changes',
                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
          margin:
          const EdgeInsets.all(16),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    String message =
    error.toString();

    message = message.replaceFirst(
      'Exception: ',
      '',
    );

    return message.trim();
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
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isLoading &&
              _user != null)
            IconButton(
              onPressed:
              _openEditProfile,
              tooltip:
              'Edit Profile',
              icon:
              const Icon(
                Icons.edit_outlined,
              ),
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
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration:
                BoxDecoration(
                  color: AppColors
                      .error
                      .withValues(
                    alpha: 0.10,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child:
                const Icon(
                  Icons
                      .person_off_outlined,
                  size: 36,
                  color:
                  AppColors.error,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Unable to load profile',
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                _error!,
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  fontSize: 12,
                  color: AppColors
                      .textSecondary,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              ElevatedButton.icon(
                onPressed:
                _loadProfile,
                icon:
                const Icon(
                  Icons
                      .refresh_rounded,
                ),
                label:
                const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // USER
    // ----------------------------------------------------------

    final UserModel? user =
        _user;

    if (user == null) {
      return const Center(
        child: Text(
          'Profile not available.',
        ),
      );
    }

    // ----------------------------------------------------------
    // CONTENT
    // ----------------------------------------------------------

    return RefreshIndicator(
      onRefresh:
      _loadProfile,
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

          const SizedBox(
            height: 22,
          ),

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

          const SizedBox(
            height: 18,
          ),

          FadeSlideAnimation(
            delay:
            const Duration(
              milliseconds: 140,
            ),
            child:
            _buildActions(),
          ),

          const SizedBox(
            height: 25,
          ),
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
    final String rawPhotoUrl =
        user.photoUrl
            ?.trim() ??
            '';

    final bool hasPhoto =
        rawPhotoUrl.isNotEmpty;

    return Container(
      padding:
      const EdgeInsets.all(22),
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // =====================================================
          // PROFILE PHOTO
          // =====================================================

          Stack(
            alignment:
            Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                padding:
                const EdgeInsets.all(
                  3,
                ),
                decoration:
                const BoxDecoration(
                  color:
                  Colors.white,
                  shape:
                  BoxShape.circle,
                ),
                child:
                CircleAvatar(
                  radius: 47,
                  backgroundColor:
                  AppColors
                      .accentLight,

                  // IMPORTANT:
                  // NetworkImage loads the URL saved
                  // from Firebase Firestore.
                  backgroundImage:
                  hasPhoto
                      ? NetworkImage(
                    rawPhotoUrl,
                  )
                      : null,

                  child: !hasPhoto
                      ? const Icon(
                    Icons
                        .person_rounded,
                    size: 50,
                    color: AppColors
                        .primary,
                  )
                      : null,
                ),
              ),

              // =================================================
              // CAMERA BUTTON
              // =================================================

              GestureDetector(
                onTap:
                _isUploadingPhoto
                    ? null
                    : _pickAndUploadPhoto,
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 200,
                  ),
                  width: 36,
                  height: 36,
                  decoration:
                  const BoxDecoration(
                    color:
                    Colors.white,
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
                      strokeWidth:
                      2.2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .camera_alt_outlined,
                    size: 18,
                    color: AppColors
                        .primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          // =====================================================
          // NAME
          // =====================================================

          Text(
            user.name.isEmpty
                ? 'Student'
                : user.name,
            textAlign:
            TextAlign.center,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 21,
              fontWeight:
              FontWeight.w800,
              color:
              Colors.white,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          // =====================================================
          // EMAIL
          // =====================================================

          Text(
            user.email,
            textAlign:
            TextAlign.center,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 12,
              color:
              Colors.white70,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // =====================================================
          // ROLE
          // =====================================================

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
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
            child: const Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .verified_user_outlined,
                  size: 14,
                  color:
                  Colors.white,
                ),

                SizedBox(
                  width: 5,
                ),

                Text(
                  'Student',
                  style:
                  TextStyle(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // UPLOAD MESSAGE
          // =====================================================

          if (_isUploadingPhoto) ...[
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Uploading profile photo...',
              style:
              TextStyle(
                fontSize: 11,
                color:
                Colors.white70,
              ),
            ),
          ],
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
    final String courseValue =
    user.courseId
        ?.trim()
        .isNotEmpty ==
        true
        ? user.courseId!
        : 'Not assigned';

    final String batchValue =
    user.batchId
        ?.trim()
        .isNotEmpty ==
        true
        ? user.batchId!
        : 'Not assigned';

    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border:
        Border.all(
          color:
          AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _InfoTile(
            icon:
            Icons.person_outline,
            title:
            'Full Name',
            value:
            user.name.isEmpty
                ? 'Not added'
                : user.name,
          ),

          const Divider(
            height: 24,
          ),

          _InfoTile(
            icon:
            Icons.email_outlined,
            title:
            'Email',
            value:
            user.email.isEmpty
                ? 'Not available'
                : user.email,
          ),

          const Divider(
            height: 24,
          ),

          _InfoTile(
            icon:
            Icons.phone_outlined,
            title:
            'Phone',
            value:
            user.phone.isEmpty
                ? 'Not added'
                : user.phone,
          ),

          const Divider(
            height: 24,
          ),

          _InfoTile(
            icon:
            Icons.location_city_outlined,
            title:
            'City',
            value:
            user.city.isEmpty
                ? 'Not added'
                : user.city,
          ),

          const Divider(
            height: 24,
          ),

          _InfoTile(
            icon:
            Icons.school_outlined,
            title:
            'Campus',
            value:
            user.campus.isEmpty
                ? 'Not assigned'
                : user.campus,
          ),

          const Divider(
            height: 24,
          ),

          _InfoTile(
            icon:
            Icons.menu_book_outlined,
            title:
            'Course',
            value:
            courseValue,
          ),

          const Divider(
            height: 24,
          ),

          _InfoTile(
            icon:
            Icons.groups_outlined,
            title:
            'Batch',
            value:
            batchValue,
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
          title:
          'Edit Profile',
          subtitle:
          'Update your name and city',
          onTap:
          _openEditProfile,
        ),

        const SizedBox(
          height: 10,
        ),

        _ActionTile(
          icon:
          Icons.logout_rounded,
          title:
          'Logout',
          subtitle:
          'Sign out from your student account',
          iconColor:
          AppColors.error,
          onTap:
          _logout,
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
  Widget build(
      BuildContext context,
      ) {
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
          child:
          Icon(
            icon,
            size: 20,
            color:
            AppColors.primary,
          ),
        ),

        const SizedBox(
          width: 13,
        ),

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
                  color: AppColors
                      .textSecondary,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value.isEmpty
                    ? 'Not available'
                    : value,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                  color: AppColors
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

class _ActionTile
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    final Color color =
        iconColor ??
            AppColors.primary;

    return Material(
      color:
      Colors.white,
      borderRadius:
      BorderRadius.circular(
        17,
      ),
      child: InkWell(
        onTap:
        onTap,
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        child: Container(
          padding:
          const EdgeInsets.all(
            15,
          ),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            border:
            Border.all(
              color:
              AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                Icon(
                  icon,
                  color:
                  color,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 11,
                        color: AppColors
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
                color: AppColors
                    .textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}