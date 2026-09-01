import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// عنصر في الشريط السفلي
class NavSpec {
  const NavSpec({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}

const kNavItems = <NavSpec>[
  NavSpec(label: 'الرئيسية', icon: Icons.home_rounded, route: '/dashboard'),
  NavSpec(label: 'المشتركون', icon: Icons.people_alt_rounded, route: '/subscribers'),
  NavSpec(label: 'الأرشيف', icon: Icons.inventory_2_rounded, route: '/invoices/archive'),
  NavSpec(label: 'الإعدادات', icon: Icons.settings_rounded, route: '/settings'),
];

/// الهيكل العام للتطبيق: شريط علوي كحلي بالشعار + محتوى + شريط سفلي عائم.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.onNavigate,
    this.title,
    this.actions,
    this.showNav = true,
  });

  final Widget child;
  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final String? title;
  final List<Widget>? actions;
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _TopBar(title: title, actions: actions),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: child),
                if (showNav)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: _BottomNav(
                          currentRoute: currentRoute,
                          onNavigate: onNavigate,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.title, this.actions});

  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.navy2, AppColors.navy],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F1B3D),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              // الشعار — كما هو تمامًا، لا يتغير
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.45),
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? 'فواتير الكهرباء',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'نظام الفواتير',
                      style: TextStyle(
                        color: AppColors.goldLight.withValues(alpha: 0.9),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentRoute, required this.onNavigate});

  final String currentRoute;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.navy2, AppColors.navy],
            ),
            borderRadius: BorderRadius.circular(AppRadius.nav),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            boxShadow: AppShadows.nav,
          ),
          child: Row(
            children: [
              _navItem(kNavItems[0]),
              _navItem(kNavItems[1]),
              _fab(),
              _navItem(kNavItems[2]),
              _navItem(kNavItems[3]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(NavSpec spec) {
    final active = currentRoute == spec.route;
    return Expanded(
      child: InkWell(
        onTap: () => onNavigate(spec.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                spec.icon,
                size: 21,
                color: active ? AppColors.goldLight : AppColors.navText,
                shadows: active
                    ? [
                        const Shadow(
                          color: Color(0x99E7C65A),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              const SizedBox(height: 3),
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.goldLight : AppColors.navText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab() {
    return SizedBox(
      width: 68,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -16),
          child: InkWell(
            onTap: () => onNavigate('/invoices/new'),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.4),
                  radius: 1.1,
                  colors: [
                    AppColors.goldLight,
                    AppColors.gold,
                    AppColors.goldDark,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
                border: Border.all(color: AppColors.navy, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 30,
                color: Color(0xFF2A2102),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// حشوة سفلية لتفادي تغطية الشريط السفلي للمحتوى
const kBottomNavPadding = EdgeInsets.only(bottom: 104);
