import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../app_info.dart';

/// عنصر في الشريط السفلي
class NavSpec {
  const NavSpec({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}

const kNavItems = <NavSpec>[
  NavSpec(label: 'الرئيسية', icon: Icons.home_rounded, route: '/dashboard'),
  NavSpec(
    label: 'المشتركون',
    icon: Icons.people_alt_rounded,
    route: '/subscribers',
  ),
  NavSpec(
    label: 'الأرشيف',
    icon: Icons.inventory_2_rounded,
    route: '/invoices/archive',
  ),
  NavSpec(label: 'الإعدادات', icon: Icons.settings_rounded, route: '/settings'),
];

/// عناصر الدرج الجانبي — الإعدادات ومعلومات التطبيق كما طُلب.
const kDrawerItems = <NavSpec>[
  NavSpec(label: 'الرئيسية', icon: Icons.home_rounded, route: '/dashboard'),
  NavSpec(
    label: 'المشتركون',
    icon: Icons.people_alt_rounded,
    route: '/subscribers',
  ),
  NavSpec(
    label: 'فاتورة جديدة',
    icon: Icons.receipt_long_rounded,
    route: '/invoices/new',
  ),
  NavSpec(
    label: 'أرشيف الفواتير',
    icon: Icons.inventory_2_rounded,
    route: '/invoices/archive',
  ),
  NavSpec(
    label: 'الإعدادات والنسخ الاحتياطي',
    icon: Icons.settings_rounded,
    route: '/settings',
  ),
  NavSpec(
    label: 'المطوّر والتواصل',
    icon: Icons.support_agent_rounded,
    route: AppInfo.aboutRoute,
  ),
];

/// الهيكل العام للتطبيق: شريط علوي كحلي بالشعار + محتوى + شريط سفلي عائم
/// + درج جانبي يُفتح من اليمين (لأن اتجاه التطبيق RTL).
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
      // في اتجاه RTL يعتبر Flutter الـ `drawer` هو درج «البداية» أي
      // اليمين تلقائياً، فلا حاجة لـ `endDrawer`.
      drawer: AppDrawer(currentRoute: currentRoute, onNavigate: onNavigate),
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
              // ── زر الدرج الجانبي ─────────────────────────────────
              // نبنيه يدوياً (لا `AppBar`) لأن الشريط العلوي مخصّص.
              // `Builder` ضروري ليحصل `Scaffold.of` على السياق الذي
              // يقع **تحت** الـ Scaffold وليس فوقه.
              Builder(
                builder: (ctx) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        size: 22,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
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
                    ? [const Shadow(color: Color(0x99E7C65A), blurRadius: 10)]
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

/// ═══ الدرج الجانبي ══════════════════════════════════════════════════
///
/// يُفتح من اليمين (اتجاه التطبيق RTL)، ويضمّ: ترويسة بالشعار واسم
/// التطبيق، ثم روابط التنقّل كاملةً بما فيها الإعدادات، ثم صفحة المطوّر
/// والتواصل، ويُذيَّل باسم المطوّر ورقم الإصدار.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.navy,
      width: 292,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── الترويسة ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [AppColors.navy2, AppColors.navy],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5),
                            ),
                          ),
                          // الشعار كما هو تمامًا
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppInfo.appName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'نظام الفواتير',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.gold, Color(0x00C9A227)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── الروابط ──────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final item in kDrawerItems)
                  _DrawerTile(
                    spec: item,
                    active: currentRoute == item.route,
                    onTap: () {
                      // نُغلق الدرج أولاً ثم ننقل، وإلا بقي الدرج مفتوحاً
                      // فوق الصفحة الجديدة على بعض الأجهزة.
                      Navigator.of(context).pop();
                      if (currentRoute != item.route) onNavigate(item.route);
                    },
                  ),
              ],
            ),
          ),

          // ── التذييل ──────────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppInfo.developer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.goldLight.withValues(alpha: 0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppInfo.versionLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navText.withValues(alpha: 0.75),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.spec,
    required this.active,
    required this.onTap,
  });

  final NavSpec spec;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.gold.withValues(alpha: 0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? AppColors.gold.withValues(alpha: 0.45)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  spec.icon,
                  size: 21,
                  color: active ? AppColors.goldLight : AppColors.navText,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    spec.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active ? Colors.white : AppColors.navText,
                    ),
                  ),
                ),
                if (active)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
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

/// حشوة سفلية لتفادي تغطية الشريط السفلي للمحتوى
const kBottomNavPadding = EdgeInsets.only(bottom: 104);
