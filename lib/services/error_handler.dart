import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

// ── Typed exception ───────────────────────────────────────────────────────────

enum AppErrorType { noInternet, timeout, apiError, unknown }

class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final String? technical;

  const AppException(this.type, this.message, {this.technical});

  @override
  String toString() => message;
}

// ── Classifier ────────────────────────────────────────────────────────────────

AppException classifyError(Object error) {
  if (error is AppException) return error;

  if (error is SocketException ||
      error.toString().contains('SocketException') ||
      error.toString().contains('Failed host lookup') ||
      error.toString().contains('Network is unreachable')) {
    return const AppException(
      AppErrorType.noInternet,
      'No internet connection. Please check your network and try again.',
    );
  }

  if (error is TimeoutException ||
      error.toString().contains('TimeoutException') ||
      error.toString().contains('Connection timed out')) {
    return const AppException(
      AppErrorType.timeout,
      'The request timed out. Please try again.',
    );
  }

  if (error.toString().contains('Groq API error 401') ||
      error.toString().contains('Groq API error 403')) {
    return const AppException(
      AppErrorType.apiError,
      'API authentication failed. Please check your Groq API key.',
    );
  }

  if (error.toString().contains('Groq API error 429')) {
    return const AppException(
      AppErrorType.apiError,
      'Too many requests. Please wait a moment and try again.',
    );
  }

  if (error.toString().contains('Groq API error')) {
    return AppException(
      AppErrorType.apiError,
      'The AI service is temporarily unavailable. Please try again.',
      technical: error.toString(),
    );
  }

  return AppException(
    AppErrorType.unknown,
    'Something went wrong. Please try again.',
    technical: error.toString(),
  );
}

// ── Global scaffold key ───────────────────────────────────────────────────────

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// ── Show error SnackBar ───────────────────────────────────────────────────────

void showErrorSnackBar(Object error) {
  final ex = classifyError(error);
  final (icon, color) = switch (ex.type) {
    AppErrorType.noInternet => (Icons.wifi_off_rounded, AppColors.warning),
    AppErrorType.timeout    => (Icons.timer_off_outlined, AppColors.warning),
    AppErrorType.apiError   => (Icons.cloud_off_rounded, AppColors.error),
    AppErrorType.unknown    => (Icons.error_outline_rounded, AppColors.error),
  };

  scaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ex.message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.primary,
          onPressed: () =>
              scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
        ),
      ),
    );
}

void showSuccessSnackBar(String message) {
  scaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
