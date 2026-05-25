import 'package:flutter/material.dart';
import 'screens/auth/splash.dart';
import 'screens/auth/welcome.dart';
import 'screens/auth/login_email.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/auth/forgot_password.dart';
import 'screens/auth/verification.dart';
import 'screens/auth/verify_successful.dart';

class AuthNavigation {
  static Map<String, Widget Function(BuildContext)> routes() {
    return {
      '/splash': (context) => const SplashScreen(),
      '/welcome': (context) => const WelcomeScreen(),
      '/login_email': (context) => const LoginEmailScreen(),
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/forgot_password': (context) => const ForgotPasswordScreen(),
      '/verification': (context) => const VerificationScreen(),
      '/verify_successful': (context) => const VerifySuccessfulScreen(),
    };
  }

  static const String initial = '/splash';
}
