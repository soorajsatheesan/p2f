import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/pages/home/sections/home_section.dart';
import 'package:p2f/pages/home/sections/ai_assistant_section.dart';
import 'package:p2f/pages/home/sections/nutrition_section.dart';
import 'package:p2f/pages/home/sections/profile_section.dart';
import 'package:p2f/pages/nutrition_capture_page.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/providers/user_profile_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF9EBEFF) : AppColors.primary;
    final horizontalPadding = width < 420 ? 20.0 : 24.0;
    final profileState = ref.watch(userProfileProvider);
    final profileNotifier = ref.read(userProfileProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A74E0), Color(0xFFE88AB7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x553A74E0),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const NutritionCapturePage()),
            );
            if (result == true && mounted) {
              setState(() {
                _selectedNavIndex = 1;
              });
            }
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Meal'),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                32,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1060),
                  child: StaggeredListAnimation(
                    animation: _animationController,
                    itemDelay: 0.1,
                    children: [
                      _TopBar(accent: accent),
                      const SizedBox(height: 16),
                      if (profileState.isLoading)
                        const _LoadingCard()
                      else
                        _buildActiveSection(
                          profile: profileState.profile,
                          isSaving: profileState.isSaving,
                          onSave: profileNotifier.saveProfile,
                          onLogout: () => _confirmLogout(context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSection({
    required UserProfile? profile,
    required bool isSaving,
    required ValueChanged<UserProfile> onSave,
    required VoidCallback onLogout,
  }) {
    switch (_selectedNavIndex) {
      case 0:
        return HomeSection(
          profile: profile,
          isSavingProfile: isSaving,
          onSaveProfile: onSave,
          onOpenProfile: () {
            setState(() {
              _selectedNavIndex = 3;
            });
          },
        );
      case 1:
        return const NutritionSection();
      case 2:
        return AiAssistantSection(profile: profile);
      case 3:
        return ProfileSection(
          profile: profile,
          isSaving: isSaving,
          onSave: onSave,
          onLogout: onLogout,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.gray800 : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
          title: Text(
            'Log out from P2F?',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          content: Text(
            'This removes your API key from this device and sends you to login.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ZenPrimaryButton(
              label: 'Log out',
              onPressed: () => Navigator.of(dialogContext).pop(true),
              height: 44,
            ),
          ],
          actionsAlignment: MainAxisAlignment.end,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );

    if (shouldLogout != true) return;
    await ref.read(loginProvider.notifier).logout();
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ZenCard(
      radius: 24,
      backgroundColor: isDark ? const Color(0xFF1A2438) : AppColors.surface,
      borderColor: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF111A2B)
            : const Color(0xFFF8FAFF),
        indicatorColor: isDark
            ? const Color(0x333A74E0)
            : const Color(0x223A74E0),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isDark ? const Color(0xFF9EBEFF) : AppColors.primary,
              size: 22,
            );
          }
          return IconThemeData(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            size: 20,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.labelSmall.copyWith(
            color: selected
                ? (isDark ? const Color(0xFF9EBEFF) : AppColors.primary)
                : (isDark ? AppColors.gray500 : AppColors.gray600),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_rounded),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'AI Assistant - Joe',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark ? const Color(0xFF1A2438) : const Color(0xFFF8FAFF),
            border: Border.all(
              color: isDark ? const Color(0xFF2D3E61) : const Color(0xFFD8E2F8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'P2F / WORKSPACE',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
