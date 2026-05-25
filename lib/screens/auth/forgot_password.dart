import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _authService =
      AuthService();

  bool _isLoading = false;

  Future<void>
      _handleForgotPassword() async {
    if (!_formKey
        .currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email =
          _emailController.text.trim();

      final result =
          await _authService
              .sendPasswordResetEmail(
                  email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

        if (result['success'] ==
            true) {
          ScaffoldMessenger.of(
                  context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Password reset email sent',
              ),
              backgroundColor:
                  Colors.green,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/verify_successful',
            (_) => false,
            arguments: {
              'mode': 'password_reset'
            },
          );
        } else {
          ScaffoldMessenger.of(
                  context)
              .showSnackBar(
            SnackBar(
              content: Text(
                result['message'],
              ),
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
              Text(
                  e.toString()),
          backgroundColor:
              Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(
              0xFFF5F2EE),

      body:
          SafeArea(
        child:
            SingleChildScrollView(
          child:
              Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  24,
              vertical:
                  40,
            ),

            child:
                Form(
              key:
                  _formKey,

              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const SizedBox(
                      height:
                          20),

                  const Text(
                    'Forgot Password',

                    style:
                        TextStyle(
                      fontSize:
                          32,

                      fontWeight:
                          FontWeight
                              .bold,

                      color:
                          Colors
                              .black,
                    ),
                  ),

                  const SizedBox(
                      height:
                          10),

                  const Text(
                    'Please enter your email to receive code',
                  ),

                  const SizedBox(
                      height:
                          40),

                  const Text(
                    'Email',
                  ),

                  const SizedBox(
                      height:
                          8),

                  CustomTextField(
                    controller:
                        _emailController,

                    hintText:
                        'enter your email',

                    keyboardType:
                        TextInputType
                            .emailAddress,

                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Email is required';
                      }

                      final emailRegex =
                          RegExp(
                        r'^[^@]+@[^@]+\.[^@]+',
                      );

                      if (!emailRegex
                          .hasMatch(
                              value
                                  .trim())) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height:
                          40),

                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleForgotPassword,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF2E2C2A),

                      foregroundColor:
                          Colors
                              .white,

                      minimumSize:
                          const Size(
                              double.infinity,
                              56),
                    ),

                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                'Continue',
                              ),
                  ),

                  const SizedBox(
                      height:
                          30),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      const Text(
                        'Remember Password? ',
                      ),

                      GestureDetector(
                        onTap:
                            () {
                          Navigator.pop(
                              context);
                        },

                        child:
                            const Text(
                          'Sign In',
                        ),
                      ),
                    ],
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