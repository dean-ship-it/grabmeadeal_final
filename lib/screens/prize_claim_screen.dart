// lib/screens/prize_claim_screen.dart

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:grabmeadeal_final/providers/puzzle_provider.dart";

class PrizeClaimScreen extends StatefulWidget {
  final String prize;
  const PrizeClaimScreen({super.key, required this.prize});

  @override
  State<PrizeClaimScreen> createState() => _PrizeClaimScreenState();
}

class _PrizeClaimScreenState extends State<PrizeClaimScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  bool _verified = false;
  String? _error;
  String? _verificationId;
  String _selectedMethod = "gift";

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── Phone Verification ────────────────────────────────────────────────────

  Future<void> _sendCode() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = "Please enter your phone number.");
      return;
    }
    setState(() { _loading = true; _error = null; });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneCtrl.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) setState(() {
          _error = "Verification failed: ${e.message}";
          _loading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _loading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyCode() async {
    if (_codeCtrl.text.trim().isEmpty) {
      setState(() => _error = "Please enter the verification code.");
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeCtrl.text.trim(),
      );
      await _signInWithCredential(credential);
    } catch (e) {
      if (mounted) setState(() {
        _error = "Invalid code. Please try again.";
        _loading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential) ??
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) setState(() {
        _verified = true;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = "Verification error. Please try again.";
        _loading = false;
      });
    }
  }

  // ── Redemption ────────────────────────────────────────────────────────────

  Future<void> _confirmRedemption() async {
    setState(() => _loading = true);
    final puzzle = context.read<PuzzleProvider>();
    await puzzle.recordSpin(0); // Already recorded — just confirm method
    if (mounted) {
      setState(() => _loading = false);
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "\u{1F389} Prize Confirmed!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.prize,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0075C9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Redeemed as: ${_selectedMethod == "gift" ? "Gift Certificate" : "% Off Future Purchase"}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              "Our team will contact you at your verified phone number within 24 hours to process your reward.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0075C9),
            ),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Claim Your Prize"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0075C9),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Prize Display ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004A8D), Color(0xFF0075C9)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("\u{1F3C6}", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text(
                    "You Won!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.prize,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (!_verified) ...[
              // ── Phone Verification ──
              const Text(
                "Verify Your Phone Number",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "To claim your prize we need to verify your identity with a one-time SMS code.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              if (!_codeSent) ...[
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "+1 281 555 0000",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _loading ? null : _sendCode,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0075C9),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Verification Code"),
                  ),
                ),
              ] else ...[
                const Text(
                  "Enter the 6-digit code sent to your phone:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: "Verification Code",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _loading ? null : _verifyCode,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0075C9),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verify Code"),
                  ),
                ),
                TextButton(
                  onPressed: _loading ? null : _sendCode,
                  child: const Text("Resend code"),
                ),
              ],
            ] else ...[
              // ── Redemption Choice ──
              const Text(
                "\u{2705} Phone Verified!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "How would you like to redeem your prize?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _redemptionOption(
                value: "gift",
                title: "\u{1F4B3} Gift Certificate",
                subtitle: "Receive a gift certificate by email",
              ),
              const SizedBox(height: 12),
              _redemptionOption(
                value: "discount",
                title: "\u{1F3F7} Percentage Off",
                subtitle: "Convert to % off your next purchase",
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _loading ? null : _confirmRedemption,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFA6CE39),
                    foregroundColor: Colors.black,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Confirm & Claim Prize",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _redemptionOption({
    required String value,
    required String title,
    required String subtitle,
  }) {
    final selected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0075C9).withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF0075C9)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
              activeColor: const Color(0xFF0075C9),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
