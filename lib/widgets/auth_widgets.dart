import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Full-screen gradient background used by auth screens.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF0EA5E9)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// White card panel that slides up over the gradient.
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: child,
    );
  }
}

/// Styled text field for auth forms.
class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onFieldSubmitted;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure && !_visible,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
      validator: widget.validator,
      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMain),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon, color: AppColors.primary, size: 20),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _visible = !_visible),
              )
            : null,
      ),
    );
  }
}

/// Primary gradient submit button.
class AuthButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }
}

/// Avatar initials circle — reused across auth + profile screens.
class UserAvatar extends StatelessWidget {
  final String name;
  final int colorValue;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    required this.colorValue,
    this.radius = 32,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        _initials,
        style: GoogleFonts.poppins(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
