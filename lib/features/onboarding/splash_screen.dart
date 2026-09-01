import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_info.dart';

/// شاشة البداية — نفس ألوان وتوقيتات النسخة الأصلية (1700ms ثم تلاشٍ).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.licensed});

  final bool licensed;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) setState(() => _opacity = 0);
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.go(widget.licensed ? '/dashboard' : '/license');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final logoSize = (w * 0.56).clamp(120.0, 230.0);

    final pop = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 0.95,
              colors: [Color(0xFF16225C), Color(0xFF0D1639), Color(0xFF0A1130)],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: Tween(begin: 0.7, end: 1.0).animate(pop),
                        child: FadeTransition(
                          opacity: _ctrl,
                          // الشعار — كما هو تمامًا
                          child: Image.asset(
                            'assets/images/logo_splash.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _FadeUp(
                        controller: _ctrl,
                        delay: 0.15,
                        child: ShaderMask(
                          shaderCallback: (rect) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF5DA7B),
                              Color(0xFFE7C65A),
                              Color(0xFFCAA12F),
                            ],
                          ).createShader(rect),
                          child: const Text(
                            'فواتير الكهرباء',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _FadeUp(
                        controller: _ctrl,
                        delay: 0.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BlinkDot(),
                            const SizedBox(width: 9),
                            const Text(
                              'جاري التحميل...',
                              style: TextStyle(
                                color: Color(0xFF9FB0E0),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 26,
                  left: 0,
                  right: 0,
                  child: _FadeUp(
                    controller: _ctrl,
                    delay: 0.45,
                    child: const Text(
                      AppInfo.developer,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7AA8), fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({
    required this.controller,
    required this.delay,
    required this.child,
  });

  final AnimationController controller;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - anim.value)),
          child: child,
        ),
      ),
    );
  }
}

class _BlinkDot extends StatefulWidget {
  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xFFE7C65A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
