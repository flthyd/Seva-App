import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinput/pinput.dart';
import 'dashboard.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  String? _errorMessage;

  Timer? _resendTimer;
  int _timerSeconds = 30;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    setState(() => _timerSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _timerSeconds = 0);
      } else {
        if (mounted) setState(() => _timerSeconds--);
      }
    });
  }

  void _showError(String msg) {
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showError("దయచేసి సరైన 10 అంకెల మొబైల్ నంబర్‌ను నమోదు చేయండి");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToNext();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError(e.message ?? "ధృవీకరణ విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _otpSent = true;
            _verificationId = verificationId;
            _isLoading = false;
          });
          _startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || _verificationId == null) {
      _showError("దయచేసి 6 అంకెల OTP నమోదు చేయండి");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      _navigateToNext();
    } catch (e) {
      _showError("నమోదు చేసిన OTP సరైనది కాదు. దయచేసి మళ్లీ చూడండి.");
    }
  }

  Future<void> _navigateToNext() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final name = data?['name'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
              );
            }
            return;
          }
        }
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      }
    } catch (e) {
      debugPrint("Error checking user profile: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE), // Authentic devotional cream
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Artwork Banner with Arch
            _otpSent ? _buildOtpHeader() : _buildLoginHeader(),

            // Error banner if any
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),

            // Form Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: !_otpSent ? _buildPhoneInput() : _buildOtpInput(),
            ),
          ],
        ),
      ),
    );
  }

  // SCREEN 1 HEADER: Seva App Devotional Arch & Temple with Hanging Bells
  Widget _buildLoginHeader() {
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/auth/login_header_artwork.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6A1B29)),
          ),
        ],
      ),
    );
  }

  // SCREEN 2 HEADER: Golden Temple with Mobile Icon Badge & Back Arrow
  Widget _buildOtpHeader() {
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/auth/otp_header_artwork.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6A1B29)),
          ),
          Positioned(
            top: 45,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.25),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                onPressed: () => setState(() => _otpSent = false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 1 BODY: Phone Input exactly as per Mockup
  Widget _buildPhoneInput() {
    return Column(
      children: [
        const SizedBox(height: 10),

        // Small decorative golden motif
        const Icon(Icons.spa_rounded, color: Color(0xFFC49A45), size: 18),
        const SizedBox(height: 8),

        // Title in Maroon Telugu Font
        const Text(
          "మొబైల్ నంబర్ ఎంటర్ చేయండి",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7A1B29),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "మీ మొబైల్ నంబర్ ద్వారా లాగిన్ అవ్వండి",
          style: TextStyle(
            fontSize: 13,
            color: Colors.brown.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        // Rounded Phone Input Box (India Flag + +91 dropdown + Phone textfield)
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2D6C5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Text(
                "+91",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black45, size: 20),
              const SizedBox(width: 12),
              Container(width: 1, height: 26, color: const Color(0xFFE2D6C5)),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Color(0xFF2C3E50),
                  ),
                  decoration: const InputDecoration(
                    hintText: "98765 43210",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.5,
                      color: Color(0xFFB0A294),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // "OTP పంపండి →" Premium Maroon Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1B29),
              elevation: 4,
              shadowColor: const Color(0x407A1B29),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "OTP పంపండి",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // "లేదా" divider
        Row(
          children: [
            Expanded(child: Container(height: 0.8, color: const Color(0xFFE0D5C3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "లేదా",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: Container(height: 0.8, color: const Color(0xFFE0D5C3))),
          ],
        ),
        const SizedBox(height: 18),

        // "గెస్ట్‌గా కొనసాగండి" Pill Button with Maroon Crest Icon
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEADBCE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A1B29),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 14),
                const Text(
                  "గెస్ట్‌గా కొనసాగండి",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D131F),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF7A1B29)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),

        // Terms and Privacy Telugu Caption
        Text(
          "కొనసాగించడం ద్వారా మీరు మా\nనియమాలు & గోప్యతా విధానాన్ని అంగీకరిస్తున్నారు.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.brown.shade500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // SCREEN 2 BODY: OTP Verification exactly as per Mockup
  Widget _buildOtpInput() {
    final defaultTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xFF7A1B29),
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2D6C5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF7A1B29), width: 2),
      ),
    );

    return Column(
      children: [
        const SizedBox(height: 10),

        // Title in Maroon Telugu Font
        const Text(
          "OTP ను నమోదు చేయండి",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7A1B29),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "+91 ${_phoneController.text} కి పంపిన 6 అంకెల OTPని\nనమోదు చేయండి",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.brown.shade700,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        // 6-digit Pinput Boxes
        Pinput(
          length: 6,
          controller: _otpController,
          defaultPinTheme: defaultTheme,
          focusedPinTheme: focusedTheme,
          separatorBuilder: (index) => const SizedBox(width: 8),
          onCompleted: (pin) => _verifyOTP(),
        ),
        const SizedBox(height: 18),

        // Timer Row: "⏱ OTP 00:28 లో ముగుస్తుంది"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF5D131F)),
            const SizedBox(width: 6),
            Text(
              "OTP 00:${_timerSeconds.toString().padLeft(2, '0')} లో ముగుస్తుంది",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D131F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // "ధృవీకరించండి →" Maroon Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1B29),
              elevation: 4,
              shadowColor: const Color(0x407A1B29),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ధృవీకరించండి",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // "OTP రాలేదా? మళ్లీ పంపండి"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "OTP రాలేదా? ",
              style: TextStyle(
                fontSize: 13,
                color: Colors.brown.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: (_timerSeconds == 0 && !_isLoading) ? _sendOTP : null,
              child: Text(
                "మళ్లీ పంపండి",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _timerSeconds == 0 ? const Color(0xFF7A1B29) : Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
