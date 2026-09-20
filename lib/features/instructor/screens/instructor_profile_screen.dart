import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState
    extends State<InstructorProfileScreen> {
  final AuthService _authService = AuthService.instance;

  UserModel? _profile;
  bool _isLoading = true;
  // bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getCurrentUserProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load profile: $e'),
        ),
      );
    }
  }

  Future<void> _editProfile() async {
    final profile = _profile;

    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name);
    final cityController = TextEditingController(text: profile.city);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setSheetState(() {
                                saving = true;
                              });

                              try {
                                await _authService.updateProfile(
                                  name: nameController.text,
                                  city: cityController.text,
                                );

                                final updatedProfile =
                                    await _authService
                                        .getCurrentUserProfile();

                                if (!sheetContext.mounted) return;

                                Navigator.of(sheetContext).pop(true);

                                if (mounted) {
                                  setState(() {
                                    _profile = updatedProfile;
                                  });
                                }
                              } catch (e) {
                                setSheetState(() {
                                  saving = false;
                                });

                                if (!sheetContext.mounted) return;

                                ScaffoldMessenger.of(sheetContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Unable to update profile: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    cityController.dispose();

    if (result == true && mounted) {
      await _loadProfile();
    }
  }

  Future<void> _changePhoto() async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) return;

    try {
      final picker = ImagePicker();

      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final Uint8List imageBytes = await pickedImage.readAsBytes();

      final photoUrl =
          await StorageService.instance.uploadProfilePhoto(
        uid: currentUser.uid,
        imageBytes: imageBytes,
      );

      await _authService.updateProfilePhoto(photoUrl);

      final updatedProfile =
          await _authService.getCurrentUserProfile();

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update photo: $e'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to logout: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final profile = _profile;

    if (profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 56,
            ),
            const SizedBox(height: 12),
            const Text(
              'Instructor profile not found.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: 24),
          _buildInformationCard(profile),
          const SizedBox(height: 16),
          _buildAccountCard(profile),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundImage: profile.photoUrl != null &&
                          profile.photoUrl!.isNotEmpty
                      ? NetworkImage(
                          '${profile.photoUrl!}&v=${DateTime.now().millisecondsSinceEpoch}',
                        )
                      : null,
                  child: profile.photoUrl == null ||
                          profile.photoUrl!.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 52,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _isUploadingPhoto ? null : _changePhoto,
                    borderRadius: BorderRadius.circular(22),
                    child: CircleAvatar(
                      radius: 20,
                      child: _isUploadingPhoto
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.name.isEmpty ? 'Instructor' : profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Instructor',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
            onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard(UserModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            _infoRow(
              Icons.person_outline,
              'Name',
              profile.name,
            ),
            _infoRow(
              Icons.phone_outlined,
              'Phone',
              profile.phone,
            ),
            _infoRow(
              Icons.email_outlined,
              'Email',
              profile.email,
            ),
            _infoRow(
              Icons.location_city_outlined,
              'City',
              profile.city,
            ),
            _infoRow(
              Icons.school_outlined,
              'Campus',
              profile.campus.isEmpty
                  ? 'Not assigned'
                  : profile.campus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(UserModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            _infoRow(
              Icons.badge_outlined,
              'Role',
              'Instructor',
            ),
            _infoRow(
              profile.isActive
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              'Status',
              profile.isActive ? 'Active' : 'Inactive',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}