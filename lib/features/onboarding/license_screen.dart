import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../core/widgets/luxe_button.dart';

/// بصمة SHA-256 لرمز الترخيص — الرمز نفسه غير مخزّن نصًّا في الشيفرة.
const kLicenseDigest =
    'ba815a92c3a5680cfdf4179f7dd77bfba7117fd4ca35cb8f51f72a8c1a971de9';

/// التحقق من رمز الترخيص.
bool verifyLicense(String input) =>
    sha256.convert(utf8.encode(input.trim())).toString() == kLicenseDigest;

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final ok = verifyLicense(_controller.text);
    if (!ok) {
      setState(() {
        _busy = false;
        _error = 'رمز الترخيص غير صحيح. حاول مرة أخرى.';
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_licensed', true);
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.7, -1),
            end: Alignment(0.7, 1),
            colors: [Color(0xFF0B1437), Color(0xFF13205A), Color(0xFF1B2D7A)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(26, 34, 26, 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x8C000000),
                        blurRadius: 60,
                        offset: Offset(0, 24),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // الشعار — كما هو تمامًا
                      Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _step(true),
                          const SizedBox(width: 6),
                          _step(true),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'أدخل رمز الترخيص',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'هذا التطبيق محمي. الرجاء إدخال رمز الترخيص الخاص بك للمتابعة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFAEBBE6),
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) => _submit(),
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40),
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'License code',
                            hintStyle: const TextStyle(
                              color: Color(0xFF8A97C9),
                              letterSpacing: 0,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.goldLight,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFF9A9A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      LuxeButton(
                        label: 'دخول',
                        variant: LuxeVariant.gold,
                        expanded: true,
                        loading: _busy,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(bool on) => Container(
    width: 26,
    height: 5,
    decoration: BoxDecoration(
      color: on ? AppColors.goldLight : Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
