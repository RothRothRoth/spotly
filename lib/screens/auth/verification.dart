import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _codeControllers.map((e) => e.text).join();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'];
    final mode = args?['mode'];

    setState(() {
      _isLoading = true;
    });

    try {
      bool verified = false;

      if (mode == 'signup') {
        verified = await _authService.verifyRegistrationCode(code);
      } else {
        verified = await _authService.verifyPasswordResetCode(code);
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (mode == 'signup') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/verify_successful',
            (_) => false,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/reset_password',
            arguments: {'email': email},
          );
        }
      } else {
        // Provide a clearer message if it's Real Firebase
        final user = _authService.currentUser;
        String errMsg = 'Verification failed. Please check the code.';
        if (user != null && !user.isVerified) {
          errMsg = 'Your email has not been verified yet. Please click the link in the verification email sent to you, then tap Verify.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isLoading = true;
    });

    final res = await _authService.resendEmailVerification();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']),
        backgroundColor: res['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We have sent code to your email",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7A7774),
                  ),
                ),
                const SizedBox(height: 40),
                
                // 6 elegant individual code boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) {
                      return SizedBox(
                        width: 45,
                        height: 56,
                        child: CustomTextField(
                          controller: _codeControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          hintText: '',
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 5) {
                                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                              } else {
                                _focusNodes[index].unfocus();
                              }
                            } else {
                              if (index > 0) {
                                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2C2A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        color: Color(0xFF7A7774),
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleResend,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
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
    );
  }
}