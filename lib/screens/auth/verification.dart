import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState
    extends State<VerificationScreen> {
  final _codeControllers =
      List.generate(
          6,
          (_) =>
              TextEditingController());

  final _focusNodes =
      List.generate(
          6,
          (_) => FocusNode());

  final _authService =
      AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    for (final c
        in _codeControllers) {
      c.dispose();
    }

    for (final f
        in _focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code =
        _codeControllers
            .map(
                (e) =>
                    e.text)
            .join();

    setState(() {
      _isLoading = true;
    });

    try {
      final verified = await _authService.verifyRegistrationCode(code);

      if (!mounted)
        return;

      setState(() {
        _isLoading =
            false;
      });

      if (verified) {
        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          const SnackBar(
            content:
                Text(
                    'Verification successful!'),
            backgroundColor:
                Colors
                    .green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/verify_successful',
          (_) => false,
        );
      } else {
        final user =
            _authService
                .currentUser;

        String errMsg =
            'Verification failed. Please check the code.';

        if (user !=
                null &&
            !user
                .isVerified) {
          errMsg =
              'Your email has not been verified yet.';
        }

        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          SnackBar(
            content:
                Text(
                    errMsg),
            backgroundColor:
                Colors
                    .orange,
            duration:
                const Duration(
                    seconds:
                        5),
          ),
        );
      }
    } catch (e) {
      if (!mounted)
        return;

      setState(() {
        _isLoading =
            false;
      });

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
                  e.toString()),
          backgroundColor:
              Colors
                  .redAccent,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await _authService.resendEmailVerification();

      if (!mounted)
        return;

      setState(() {
        _isLoading =
            false;
      });

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
                  res['message'] ?? ''),
          backgroundColor:
              res['success'] ==
                      true
                  ? Colors
                      .green
                  : Colors
                      .redAccent,
        ),
      );
    } catch (e) {
      if (!mounted)
        return;

      setState(() {
        _isLoading =
            false;
      });

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
                  e.toString()),
          backgroundColor:
              Colors
                  .redAccent,
        ),
      );
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F2EE),

    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.center,

              children: [

                const Text(
                  'Verification',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                const Text(
                  'We have sent code to your email',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Color(
                      0xFF7A7774,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 64,
                ),

                // OTP
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children:
                      List.generate(
                    6,
                    (index) {
                      return SizedBox(
                        width: 48,
                        height: 60,

                        child:
                            CustomTextField(
                          controller:
                              _codeControllers[index],

                          focusNode:
                              _focusNodes[index],

                          keyboardType:
                              TextInputType.number,

                          maxLength: 1,

                          textAlign:
                              TextAlign.center,

                          hintText: '',

                          contentPadding:
                              EdgeInsets.zero,

                          onChanged:
                              (value) {
                            if (value
                                .isNotEmpty) {
                              if (index <
                                  5) {
                                FocusScope.of(
                                        context)
                                    .requestFocus(
                                  _focusNodes[
                                      index +
                                          1],
                                );
                              } else {
                                _focusNodes[
                                        index]
                                    .unfocus();
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 52,
                ),

                // VERIFY BUTTON
                SizedBox(
                  width:
                      double.infinity,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleVerify,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF2E2C2A,
                      ),

                      foregroundColor:
                          Colors.white,

                      minimumSize:
                          const Size(
                        double.infinity,
                        56,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),
                      ),

                      elevation: 0,
                    ),

                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                'Verify',

                                style:
                                    TextStyle(
                                  fontSize:
                                      16,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // RESEND
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    const Text(
                      "Didn't receive code? ",

                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF7A7774,
                        ),

                        fontSize:
                            15,
                      ),
                    ),

                    GestureDetector(
                      onTap:
                          _isLoading
                              ? null
                              : _handleResend,

                      child:
                          const Text(
                        'Resend',

                        style:
                            TextStyle(
                          color:
                              Colors.black,

                          fontWeight:
                              FontWeight.bold,

                          fontSize:
                              15,

                          decoration:
                              TextDecoration
                                  .underline,
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