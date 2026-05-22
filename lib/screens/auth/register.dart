import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _usernameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _authService =
      AuthService();

  bool _obscurePassword = true;

  bool _isLoading = false;

  Future<void>
      _handleRegister() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _authService.register(
        username:
            _usernameController.text
                .trim(),

        email:
            _emailController.text
                .trim(),

        password:
            _passwordController.text,
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
                    'message']),
            backgroundColor:
                Colors.green,
          ),
        );

        Navigator.pushNamed(
          context,
          '/verification',
          arguments: {
            'email':
                _emailController.text
                    .trim(),
            'mode':
                'signup',
          },
        );
      } else {
        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          SnackBar(
            content:
                Text(result[
                    'message']),
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

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
                  Center(
                    child: Column(
                      children: const [
                        SizedBox(
                            height:
                                10),

                        BrandLogo(
                            fontSize:
                                100),

                        SizedBox(
                            height:
                                40),
                      ],
                    ),
                  ),

                  const Text(
                    'Username',
                    style:
                        TextStyle(
                      fontSize:
                          14,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          Colors
                              .black87,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  CustomTextField(
                    controller:
                        _usernameController,

                    hintText:
                        'enter your username',

                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Username is required';
                      }

                      if (value
                              .trim()
                              .length <
                          3) {
                        return 'Username must be at least 3 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  const Text(
                    'Email',
                    style:
                        TextStyle(
                      fontSize:
                          14,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          Colors
                              .black87,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

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
                      height: 20),

                  const Text(
                    'Password',
                    style:
                        TextStyle(
                      fontSize:
                          14,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          Colors
                              .black87,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  CustomTextField(
                    controller:
                        _passwordController,

                    hintText:
                        'Password',

                    obscureText:
                        _obscurePassword,

                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,

                        color:
                            Colors
                                .grey,
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
                        return 'Password is required';
                      }

                      if (value
                              .length <
                          6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 32),

                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleRegister,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF2E2C2A),

                      foregroundColor:
                          Colors
                              .white,

                      minimumSize:
                          const Size(
                        double
                            .infinity,
                        56,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                28),
                      ),

                      elevation:
                          0,
                    ),

                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                'Sign up',
                                style:
                                    TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),

                  const SizedBox(
                      height: 30),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      const Text(
                        "Have an account? ",
                        style:
                            TextStyle(
                          color:
                              Color(
                                  0xFF7A7774),
                          fontSize:
                              15,
                        ),
                      ),

                      GestureDetector(
                        onTap:
                            () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          );
                        },

                        child:
                            const Text(
                          'Log in',
                          style:
                              TextStyle(
                            color:
                                Colors.black,
                            fontWeight:
                                FontWeight.bold,
                            fontSize:
                                15,
                            decoration:
                                TextDecoration.underline,
                          ),
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