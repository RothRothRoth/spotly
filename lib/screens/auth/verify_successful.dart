import 'package:flutter/material.dart';

class VerifySuccessfulScreen extends StatelessWidget {
  const VerifySuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isPasswordReset = args?['mode'] == 'password_reset';

    final isSignup = args?['mode'] == 'signup_success';

    String title = 'Verify Successful';
    String message = 'Successfully verified your account';

    if (isPasswordReset) {
      title = 'Email Sent';
      message = 'Please check your email for the password reset link.';
    } else if (isSignup) {
      title = 'Registration Successful';
      message = 'Please check your email for the verification link to activate your account.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const SizedBox(height: 120),
              const SizedBox(height: 40),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A7774),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to Sign In (LoginScreen)
                  // Remove routes until welcome, and then push /login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2C2A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
