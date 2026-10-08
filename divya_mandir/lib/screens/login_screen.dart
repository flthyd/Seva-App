import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showError(String msg) {
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
    // Clear error after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showError("Please enter a valid 10-digit mobile number");
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
          _showError(e.message ?? "Verification Failed. Please try again.");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _otpSent = true;
            _verificationId = verificationId;
            _isLoading = false;
          });
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
      _showError("Please enter the 6-digit OTP");
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
      _showError("Invalid OTP. Please check and try again.");
    }
  }

  void _navigateToNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Premium Header / Image placeholder
              if (!_otpSent)
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8D5C4),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.temple_hindu, size: 80, color: Color(0xFF6A1B29)),
                      SizedBox(height: 16),
                      Text("Pavitra Seva", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29), fontFamily: 'Serif')),
                      Text("Your Divine Connection", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                )
              else
                const SizedBox(height: 60),
              
              const SizedBox(height: 40),
              
              // Animated Error Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _errorMessage != null ? 50 : 0,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Center(
                  child: Text(
                    _errorMessage ?? "",
                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              if (_errorMessage != null) const SizedBox(height: 16),

              // Login Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: !_otpSent ? _buildPhoneInput() : _buildOtpInput(defaultPinTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enter your Mobile Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
        const SizedBox(height: 8),
        const Text("We will send you a 6 digit OTP", style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: const [
                    Text("\u{1F1EE}\u{1F1F3}", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text("+91", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.2),
                  decoration: const InputDecoration(
                    hintText: "Enter mobile number",
                    hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: 0),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B29),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Send OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
              );
            },
            child: const Text("Continue as Guest", style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "By continuing, you agree to our\nTerms & Conditions and Privacy Policy",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black45, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput(PinTheme defaultPinTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _otpSent = false),
          child: const Icon(Icons.arrow_back, color: Color(0xFF6A1B29)),
        ),
        const SizedBox(height: 24),
        const Text("Verify OTP", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
        const SizedBox(height: 8),
        Text("We have sent a 6 digit code to\n+91 ${_phoneController.text}", style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        const SizedBox(height: 32),
        Center(
          child: Pinput(
            length: 6,
            controller: _otpController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyDecorationWith(
              border: Border.all(color: const Color(0xFF6A1B29), width: 2),
            ),
            onCompleted: (pin) => _verifyOTP(),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendOTP,
            child: const Text("Resend OTP", style: TextStyle(color: Color(0xFFC08B39), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B29),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Verify & Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}



