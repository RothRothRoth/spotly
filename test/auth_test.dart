import 'package:flutter_test/flutter_test.dart';
import 'package:spotly_fresh/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() async {
      // Get singleton instance
      authService = AuthService();
      // Enable mock mode explicitly for testing
      AuthService.forceMock = true;
      // Clear logged in user
      await authService.logout();
      // Ensure default user is present and verified
      final hasDefault = authService.debugUsersList.any((u) => u.email == 'user@spotly.com');
      if (!hasDefault) {
        final regResult = await authService.register(
          username: 'user',
          email: 'user@spotly.com',
          password: 'password123',
        );
        final code = regResult['code'] as String;
        await authService.verifyRegistrationCode(code);
      }
    });

    test('Login with default user success', () async {
      final result = await authService.login(
        usernameOrEmail: 'user@spotly.com',
        password: 'password123',
      );
      expect(result['success'], isTrue);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.username, 'user');
    });

    test('Login with username instead of email success', () async {
      final result = await authService.login(
        usernameOrEmail: 'user',
        password: 'password123',
      );
      expect(result['success'], isTrue);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.email, 'user@spotly.com');
    });

    test('Login with incorrect password fails', () async {
      final result = await authService.login(
        usernameOrEmail: 'user@spotly.com',
        password: 'wrongpassword',
      );
      expect(result['success'], isFalse);
      expect(authService.currentUser, isNull);
    });

    test('Login with unknown user fails', () async {
      final result = await authService.login(
        usernameOrEmail: 'unknown@example.com',
        password: 'password123',
      );
      expect(result['success'], isFalse);
    });

    test('Register new user registers as unverified', () async {
      final result = await authService.register(
        username: 'tester',
        email: 'tester@spotly.com',
        password: 'password999',
      );
      expect(result['success'], isTrue);
      expect(result['code'], isNotNull);
      expect(authService.pendingUser, isNotNull);
      expect(authService.pendingUser!.username, 'tester');
      expect(authService.pendingUser!.isVerified, isFalse);
    });

    test('Register user with duplicate email fails', () async {
      final result = await authService.register(
        username: 'newtester',
        email: 'user@spotly.com', // Duplicate email
        password: 'password999',
      );
      expect(result['success'], isFalse);
    });

    test('Register user with duplicate username fails', () async {
      final result = await authService.register(
        username: 'user', // Duplicate username
        email: 'newtester@spotly.com',
        password: 'password999',
      );
      expect(result['success'], isFalse);
    });

    test('Verify registration code successfully activates user', () async {
      final regResult = await authService.register(
        username: 'validguy',
        email: 'validguy@spotly.com',
        password: 'password888',
      );
      final code = regResult['code'] as String;

      final verifyResult = await authService.verifyRegistrationCode(code);
      expect(verifyResult, isTrue);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.username, 'validguy');
      expect(authService.currentUser!.isVerified, isTrue);
    });

    test('Verify registration code with incorrect code fails', () async {
      await authService.register(
        username: 'wrongguy',
        email: 'wrongguy@spotly.com',
        password: 'password888',
      );

      final verifyResult = await authService.verifyRegistrationCode('999999'); // Wrong code
      expect(verifyResult, isFalse);
    });

    test('Forgot password sends verification code', () async {
      final result = await authService.forgotPassword('user@spotly.com');
      expect(result['success'], isTrue);
      expect(result['code'], isNotNull);
    });

    test('Verify password reset code and change password successfully', () async {
      final forgotResult = await authService.forgotPassword('user@spotly.com');
      final code = forgotResult['code'] as String;

      final verifyReset = await authService.verifyPasswordResetCode(code);
      expect(verifyReset, isTrue);

      final resetResult = await authService.resetPassword(
        newPassword: 'newpassword777',
        confirmPassword: 'newpassword777',
      );
      expect(resetResult['success'], isTrue);

      // Verify that we can log in with new password
      await authService.logout();
      final loginResult = await authService.login(
        usernameOrEmail: 'user@spotly.com',
        password: 'newpassword777',
      );
      expect(loginResult['success'], isTrue);
    });
  });
}
