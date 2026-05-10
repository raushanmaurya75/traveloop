import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/auth_widgets.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final err = await AuthService().login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _error = err; });
    }
    // On success the root StreamBuilder in main.dart reacts automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: Column(
          children: [
            // ── Hero section ───────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 20),
                      Text('Welcome\nback! ✈️',
                          style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Text('Sign in to continue planning\nyour dream trips.',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.5)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form card ──────────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sign In',
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMain)),
                        const SizedBox(height: 4),
                        Text('Enter your credentials to continue',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 28),

                        AuthField(
                          controller: _emailCtrl,
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: _submit,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),

                        // ── Error banner ───────────────────────────────────
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          _ErrorBanner(message: _error!),
                        ],

                        const SizedBox(height: 28),
                        AuthButton(
                          label: 'Sign In',
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 24),

                        // ── Switch to sign up ──────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignupScreen()),
                              ),
                              child: Text('Sign Up',
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
