import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _avatarColors = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF0EA5E9),
    Color(0xFFEC4899), Color(0xFF14B8A6),
  ];
  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final err = await AuthService().signUp(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      avatarColorValue: _avatarColors[_selectedColorIndex].toARGB32(),
    );

    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    }
    // On success the root StreamBuilder reacts automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: Column(
          children: [
            // ── Hero ───────────────────────────────────────────────────────
            Expanded(
              flex: 1,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Account',
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('Start your journey today 🌍',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.75))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form card ──────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar color picker
                        Center(
                          child: Column(
                            children: [
                              UserAvatar(
                                name: _nameCtrl.text.isEmpty
                                    ? '?'
                                    : _nameCtrl.text,
                                colorValue:
                                    _avatarColors[_selectedColorIndex].toARGB32(),
                                radius: 36,
                              ),
                              const SizedBox(height: 12),
                              Text('Pick your avatar color',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _avatarColors
                                    .asMap()
                                    .entries
                                    .map((e) => GestureDetector(
                                          onTap: () => setState(
                                              () => _selectedColorIndex = e.key),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            width: _selectedColorIndex == e.key
                                                ? 28
                                                : 22,
                                            height: _selectedColorIndex == e.key
                                                ? 28
                                                : 22,
                                            decoration: BoxDecoration(
                                              color: e.value,
                                              shape: BoxShape.circle,
                                              border: _selectedColorIndex ==
                                                      e.key
                                                  ? Border.all(
                                                      color: e.value,
                                                      width: 3)
                                                  : null,
                                              boxShadow: _selectedColorIndex ==
                                                      e.key
                                                  ? [
                                                      BoxShadow(
                                                        color: e.value
                                                            .withValues(
                                                                alpha: 0.4),
                                                        blurRadius: 8,
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        AuthField(
                          controller: _nameCtrl,
                          hint: 'Full name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                          onFieldSubmitted: () => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AuthField(
                          controller: _emailCtrl,
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        AuthField(
                          controller: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'At least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AuthField(
                          controller: _confirmCtrl,
                          hint: 'Confirm password',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: _submit,
                          validator: (v) => v != _passCtrl.text
                              ? 'Passwords do not match'
                              : null,
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          _ErrorBanner(message: _error!),
                        ],

                        const SizedBox(height: 28),
                        AuthButton(
                          label: 'Create Account',
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text('Sign In',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
