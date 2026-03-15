import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/pages/home/sections/ai_assistant_section.dart';
import 'package:p2f/pages/home/sections/home_section.dart';
import 'package:p2f/pages/home/sections/nutrition_section.dart';
import 'package:p2f/pages/home/sections/profile_section.dart';
import 'package:p2f/pages/nutrition_capture_page.dart';
import 'package:p2f/providers/ai_coach_provider.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/providers/motivation_quote_provider.dart';
import 'package:p2f/providers/nutrition_provider.dart';
import 'package:p2f/providers/user_profile_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedNavIndex = 0;
  final List<int> _tabHistory = [0];

  void _selectNavItem(int index) {
    if (index == _selectedNavIndex) return;

    setState(() {
      _selectedNavIndex = index;
      if (index == 0) {
        _tabHistory
          ..clear()
          ..add(0);
        return;
      }

      _tabHistory.remove(index);
      _tabHistory.add(index);
    });
  }

  void _handleBackNavigation() {
    if (_selectedNavIndex == 2) {
      final aiState = ref.read(aiCoachProvider);
      if (aiState.hasCompanion) {
        ref.read(aiCoachProvider.notifier).clearCompanion();
        return;
      }
    }

    if (_selectedNavIndex == 0) return;

    setState(() {
      if (_tabHistory.length > 1) {
        _tabHistory.removeLast();
        _selectedNavIndex = _tabHistory.last;
      } else {
        _selectedNavIndex = 0;
        _tabHistory
          ..clear()
          ..add(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width < 420 ? 20.0 : 24.0;

    return PopScope<void>(
      canPop: _selectedNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        floatingActionButton: _selectedNavIndex == 1
            ? _LogMealFab(
                onTap: () async {
                  final result = await Navigator.of(context).push<bool>(
                    SlidePageRoute(
                      child: const NutritionCapturePage(),
                      direction: AxisDirection.up,
                    ),
                  );
                  if (result == true) {
                    ref.read(nutritionProvider.notifier).loadHistory();
                  }
                },
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _FloatingNavBar(
          selectedIndex: _selectedNavIndex,
          onSelected: _selectNavItem,
        ),
        body: SafeArea(
          child: _selectedNavIndex == 2 && !profileState.isLoading
              ? Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          32,
                          horizontalPadding,
                          0,
                        ),
                        child: AiAssistantSection(profile: profileState.profile),
                      ),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      32,
                      horizontalPadding,
                      112,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: profileState.isLoading
                          ? const _LoadingState()
                          : AnimatedSwitcher(
                              duration: AppTheme.normalDuration,
                              switchInCurve: AppTheme.primaryEasing,
                              switchOutCurve: Curves.easeInCubic,
                              child: KeyedSubtree(
                                key: ValueKey<int>(_selectedNavIndex),
                                child: _buildActiveSection(
                                  profileState: profileState,
                                  profileNotifier: profileNotifier,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildActiveSection({
    required UserProfileState profileState,
    required UserProfileNotifier profileNotifier,
  }) {
    switch (_selectedNavIndex) {
      case 0:
        return HomeSection(
          onOpenProfile: () => _selectNavItem(3),
        );
      case 1:
        return const NutritionSection();
      case 2:
        return AiAssistantSection(profile: profileState.profile);
      case 3:
        return ProfileSection(
          profile: profileState.profile,
          onLogout: () => _confirmLogout(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogoutConfirmSheet(),
    );

    if (shouldLogout != true) return;
    await ref.read(aiCoachProvider.notifier).resetConversation();
    await ref.read(motivationQuoteProvider.notifier).reset();
    await ref.read(userProfileProvider.notifier).clearProfile();
    await ref.read(nutritionProvider.notifier).clearSessionData();
    await ref.read(loginProvider.notifier).logout();
  }
}

// ── Floating Nav Bar ──────────────────────────────────────────────────────────

class _FloatingNavBar extends StatefulWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar>
    with SingleTickerProviderStateMixin {
  static const _items = [
    (icon: Icons.home_rounded, label: 'HOME'),
    (icon: Icons.local_fire_department_rounded, label: 'NUTRITION'),
    (icon: Icons.smart_toy_rounded, label: 'AI'),
    (icon: Icons.person_rounded, label: 'PROFILE'),
  ];

  late final AnimationController _ctrl;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 340),
      vsync: this,
    );
    _slideAnim = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      final from = _slideAnim.value;
      _slideAnim = Tween<double>(
        begin: from,
        end: widget.selectedIndex.toDouble(),
      ).chain(CurveTween(curve: AppTheme.primaryEasing)).animate(_ctrl);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xCC030303),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderHover, width: 1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemW = constraints.maxWidth / _items.length;
                    return Stack(
                      children: [
                        // Sliding white pill indicator
                        AnimatedBuilder(
                          animation: _slideAnim,
                          builder: (context, _) => Positioned(
                            left: _slideAnim.value * itemW + 5,
                            top: 5,
                            bottom: 5,
                            width: itemW - 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.foreground,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22FFFFFF),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Nav items sit above the pill
                        Row(
                          children: List.generate(
                            _items.length,
                            (i) => _NavItem(
                              icon: _items[i].icon,
                              label: _items[i].label,
                              selected: widget.selectedIndex == i,
                              width: itemW,
                              onTap: () => widget.onSelected(i),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                icon,
                key: ValueKey<bool>(selected),
                size: 21,
                color: selected ? AppColors.background : AppColors.subtle,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: AppTypography.overline.copyWith(
                color: selected ? AppColors.background : AppColors.faint,
                fontSize: 8.5,
                letterSpacing: 0.6,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log Meal FAB ──────────────────────────────────────────────────────────────

class _LogMealFab extends StatefulWidget {
  const _LogMealFab({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LogMealFab> createState() => _LogMealFabState();
}

class _LogMealFabState extends State<_LogMealFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.foreground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: AppColors.background,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ── Logout Confirm Sheet ──────────────────────────────────────────────────────

class _LogoutConfirmSheet extends StatelessWidget {
  const _LogoutConfirmSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.overlayFade,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A0505),
                      border: Border.all(color: const Color(0x55FF4444)),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Color(0xFFFF4444),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Log out?', style: AppTypography.headlineSmall),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Body
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFFF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will clear your API key, profile, and all saved data from this device. You will be returned to the login screen.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.subtle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          color: AppColors.surface,
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.subtle,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF1A0505),
                          border: Border.all(
                            color: const Color(0x55FF4444),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'LOG OUT',
                            style: AppTypography.labelLarge.copyWith(
                              color: const Color(0xFFFF4444),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading State ─────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.foreground),
        ),
      ),
    );
  }
}
