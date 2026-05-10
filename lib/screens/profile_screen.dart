import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/error_handler.dart';
import '../services/isar_service.dart';
import '../theme.dart';
import '../widgets/auth_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _uploadingPhoto = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final u = AuthService().currentUser!;
    _nameCtrl = TextEditingController(text: u.name);
    _bioCtrl = TextEditingController(text: u.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    await AuthService().updateProfile(
      name: _nameCtrl.text,
      bio: _bioCtrl.text,
    );
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _pickPhoto() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Change Profile Photo',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            _PhotoSourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Take a Photo',
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
            _PhotoSourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: choice,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      await AuthService().updateProfilePhoto(file.path);
    } catch (e) {
      showErrorSnackBar(e);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign Out',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userStream,
      initialData: AuthService().currentUser,
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Gradient SliverAppBar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.primary,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(
                      _editing ? Icons.close_rounded : Icons.edit_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() {
                      if (_editing) {
                        _nameCtrl.text = user.name;
                        _bioCtrl.text = user.bio;
                      }
                      _editing = !_editing;
                    }),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          // ── Avatar with edit overlay ─────────────────
                          GestureDetector(
                            onTap: _pickPhoto,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _buildAvatar(user),
                                if (_uploadingPhoto)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24, height: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 14),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(user.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(user.email,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.75))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Edit form ────────────────────────────────────
                      if (_editing) ...[
                        _SectionCard(
                          title: 'Edit Profile',
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Full name',
                                  prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _bioCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'Bio (optional)',
                                  prefixIcon: Icon(Icons.notes_rounded,
                                      color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _saveProfile,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: Text('Save Changes',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Stats ────────────────────────────────────────
                      StreamBuilder<List>(
                        stream: IsarService().watchTrips(),
                        builder: (context, tripSnap) {
                          final count = tripSnap.data?.length ?? 0;
                          final joined =
                              '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}';
                          return Row(
                            children: [
                              _StatCard(
                                  icon: Icons.flight_takeoff_rounded,
                                  label: 'Trips',
                                  value: '$count'),
                              const SizedBox(width: 12),
                              _StatCard(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Joined',
                                  value: joined),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Bio ──────────────────────────────────────────
                      if (user.bio.isNotEmpty && !_editing) ...[
                        _SectionCard(
                          title: 'About',
                          child: Text(user.bio,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.6)),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Account info ─────────────────────────────────
                      _SectionCard(
                        title: 'Account',
                        child: Column(
                          children: [
                            _InfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: user.email),
                            const Divider(height: 24),
                            _InfoRow(
                                icon: Icons.shield_outlined,
                                label: 'Password',
                                value: '••••••••'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Sign out ─────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 18),
                          label: Text('Sign Out',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                                color:
                                    AppColors.error.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(User user) {
    final hasPhoto =
        user.photoPath != null && File(user.photoPath!).existsSync();
    if (hasPhoto) {
      return CircleAvatar(
        radius: 44,
        backgroundImage: FileImage(File(user.photoPath!)),
      );
    }
    return UserAvatar(
        name: user.name, colorValue: user.avatarColorValue, radius: 44);
  }
}

// ── Photo source tile ─────────────────────────────────────────────────────────

class _PhotoSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PhotoSourceTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMain)),
          ],
        ),
      ),
    );
  }
}

// ── Reused sub-widgets ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
