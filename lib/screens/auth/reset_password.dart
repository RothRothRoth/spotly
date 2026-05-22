import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  final _authService =
      AuthService();

  bool _obscurePassword = true;

  bool _obscureConfirmPassword =
      true;

  bool _isLoading = false;

  Future<void>
      _handleResetPassword()
      async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _authService
              .resetPassword(
        newPassword:
            _passwordController
                .text,

        confirmPassword:
            _confirmPasswordController
                .text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] ==
          true) {
        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          SnackBar(
            content:
                Text(result[
                        'message'] ??
                    'Password updated'),

            backgroundColor:
                Colors.green,
          ),
        );

        Navigator
            .pushNamedAndRemoveUntil(
          context,
          '/verify_successful',
          (_) => false,

          arguments: {
            'mode':
                'password_reset',
          },
        );
      } else {
        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          SnackBar(
            content:
                Text(result[
                        'message'] ??
                    'Reset failed'),

            backgroundColor:
                Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController
        .dispose();

    _confirmPasswordController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(
              0xFFF5F2EE),

      body: SafeArea(
        child:
            SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 24,
              vertical: 40,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  IconButton(
                    icon: const Icon(
                      Icons
                          .arrow_back_ios_new,
                    ),

                    onPressed:
                        () {
                      Navigator.pop(
                          context);
                    },
                  ),

                  const SizedBox(
                      height: 40),

                  const Text(
                    'Reset Password',
                    style:
                        TextStyle(
                      fontSize:
                          32,
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  CustomTextField(
                    controller:
                        _passwordController,

                    hintText:
                        'Enter new password',

                    obscureText:
                        _obscurePassword,

                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),

                      onPressed:
                          () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),

                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .isEmpty) {
                        return 'Required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  CustomTextField(
                    controller:
                        _confirmPasswordController,

                    hintText:
                        'Confirm password',

                    obscureText:
                        _obscureConfirmPassword,

                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),

                      onPressed:
                          () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),

                    validator:
                        (value) {
                      if (value !=
                          _passwordController
                              .text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 40),

                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleResetPassword,

                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Reset Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}