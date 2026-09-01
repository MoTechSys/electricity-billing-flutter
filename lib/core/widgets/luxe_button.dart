import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum LuxeVariant { blue, gold, danger, ghost, success }

/// زر فاخر محسّن: تدرّج متعدد المراحل + لمعة داخلية عليا + ظل طبقي
/// + تأثير ضغط (scale) + حالة تحميل + ارتفاع لمس 48px.
class LuxeButton extends StatefulWidget {
  const LuxeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = LuxeVariant.blue,
    this.expanded = false,
    this.loading = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LuxeVariant variant;
  final bool expanded;
  final bool loading;
  final bool compact;

  @override
  State<LuxeButton> createState() => _LuxeButtonState();
}

class _LuxeButtonState extends State<LuxeButton> {
  bool _down = false;

  bool get _disabled => widget.onPressed == null || widget.loading;

  _Palette get _palette {
    switch (widget.variant) {
      case LuxeVariant.blue:
        return const _Palette(
          colors: [AppColors.btnBlue1, AppColors.btnBlue2, AppColors.btnBlue3],
          fg: Colors.white,
          glow: Color(0x452563EB),
        );
      case LuxeVariant.gold:
        return const _Palette(
          colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
          fg: Color(0xFF2A2102),
          glow: Color(0x45C9A227),
        );
      case LuxeVariant.danger:
        return const _Palette(
          colors: [AppColors.btnRed1, AppColors.btnRed2, AppColors.btnRed3],
          fg: Colors.white,
          glow: Color(0x45DC2626),
        );
      case LuxeVariant.success:
        return const _Palette(
          colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)],
          fg: Colors.white,
          glow: Color(0x4510B981),
        );
      case LuxeVariant.ghost:
        return const _Palette(
          colors: [Colors.white, Color(0xFFF3F6FB), Color(0xFFE9EEF7)],
          fg: AppColors.navy,
          glow: Color(0x1A0F1B3D),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    final h = widget.compact ? 42.0 : 50.0;

    final child = AnimatedScale(
      scale: _down ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: _disabled ? 0.55 : 1,
        child: Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: p.colors,
              stops: const [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: widget.variant == LuxeVariant.ghost
                ? Border.all(color: const Color(0xFFD3DBE8))
                : Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: _disabled
                ? null
                : [
                    BoxShadow(
                      color: p.glow,
                      blurRadius: _down ? 8 : 16,
                      offset: Offset(0, _down ? 2 : 7),
                    ),
                    const BoxShadow(
                      color: Color(0x140F1B3D),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // لمعة داخلية أعلى الزر
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: h * 0.45,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.button - 1),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: widget.expanded
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.loading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(p.fg),
                        ),
                      )
                    else if (widget.icon != null)
                      Icon(widget.icon, size: 19, color: p.fg),
                    if (widget.loading || widget.icon != null)
                      const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.fg,
                          fontSize: widget.compact ? 13.5 : 15,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final tappable = GestureDetector(
      onTapDown: _disabled ? null : (_) => setState(() => _down = true),
      onTapUp: _disabled ? null : (_) => setState(() => _down = false),
      onTapCancel: _disabled ? null : () => setState(() => _down = false),
      onTap: _disabled ? null : widget.onPressed,
      child: child,
    );

    return widget.expanded
        ? SizedBox(width: double.infinity, child: tappable)
        : tappable;
  }
}

class _Palette {
  const _Palette({required this.colors, required this.fg, required this.glow});
  final List<Color> colors;
  final Color fg;
  final Color glow;
}

/// زر أيقونة دائري بنفس الهوية
class LuxeIconButton extends StatelessWidget {
  const LuxeIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color = AppColors.navy,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE1E7F1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0F1B3D),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.48, color: color),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
