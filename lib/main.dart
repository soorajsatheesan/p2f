import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/pages/home_page.dart';
import 'package:p2f/pages/login_page.dart';
import 'package:p2f/pages/tell_us_about_you_page.dart';
import 'package:p2f/providers/login_provider.dart';
import 'package:p2f/providers/user_profile_provider.dart';
import 'package:p2f/theme/theme.dart';
import 'package:p2f/widgets/global/global_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> _appNavigatorKey = GlobalKey<NavigatorState>();

abstract final class _AppRoute {
  static const splash = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/home';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P2F',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      navigatorKey: _appNavigatorKey,
      initialRoute: _AppRoute.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case _AppRoute.login:
            return MaterialPageRoute<void>(
              builder: (_) => const LoginPage(),
              settings: settings,
            );
          case _AppRoute.onboarding:
            return MaterialPageRoute<void>(
              builder: (_) => const TellUsAboutYouPage(),
              settings: settings,
            );
          case _AppRoute.home:
            return MaterialPageRoute<void>(
              builder: (_) => const HomePage(),
              settings: settings,
            );
          case _AppRoute.splash:
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const _LoadingScreen(),
              settings: const RouteSettings(name: _AppRoute.splash),
            );
        }
      },
      builder: (context, child) {
        return AuthWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isBootstrapping = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await ref.read(loginProvider.notifier).checkExistingLogin();
    if (!mounted) return;
    setState(() => _isBootstrapping = false);
    _syncInitialRoute();
  }

  void _withNavigator(void Function(NavigatorState navigator) action) {
    final navigator = _appNavigatorKey.currentState;
    if (navigator != null) {
      action(navigator);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final deferredNavigator = _appNavigatorKey.currentState;
      if (deferredNavigator != null) action(deferredNavigator);
    });
  }

  void _replaceStack(String routeName) {
    _withNavigator(
      (navigator) => navigator.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
      ),
    );
  }

  void _pushOnboardingFromLogin() {
    _withNavigator((navigator) => navigator.pushNamed(_AppRoute.onboarding));
  }

  void _syncInitialRoute() {
    final loginState = ref.read(loginProvider);
    final profileState = ref.read(userProfileProvider);

    if (!loginState.isSuccess) {
      _replaceStack(_AppRoute.login);
      return;
    }

    if (profileState.isLoading) {
      _replaceStack(_AppRoute.splash);
      return;
    }

    _replaceStack(profileState.hasProfile ? _AppRoute.home : _AppRoute.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginProvider, (previous, current) {
      final wasLoggedIn = previous?.isSuccess ?? false;
      final isLoggedIn = current.isSuccess;

      if (wasLoggedIn && !isLoggedIn) {
        _replaceStack(_AppRoute.login);
        return;
      }

      if (!wasLoggedIn && isLoggedIn && !_isBootstrapping) {
        final profileState = ref.read(userProfileProvider);
        if (profileState.isLoading) {
          _replaceStack(_AppRoute.splash);
          return;
        }

        if (profileState.hasProfile) {
          _replaceStack(_AppRoute.home);
        } else {
          _pushOnboardingFromLogin();
        }
      }
    });

    ref.listen<UserProfileState>(userProfileProvider, (previous, current) {
      final isLoggedIn = ref.read(loginProvider).isSuccess;
      if (!isLoggedIn || current.isLoading) return;

      final finishedLoading = previous?.isLoading == true && !current.isLoading;
      final gainedProfile = !(previous?.hasProfile ?? false) && current.hasProfile;

      if (gainedProfile) {
        _replaceStack(_AppRoute.home);
        return;
      }

      if (_isBootstrapping || finishedLoading) {
        _replaceStack(current.hasProfile ? _AppRoute.home : _AppRoute.onboarding);
      }
    });

    return widget.child;
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: const P2fLogo(size: 132, borderRadius: 28),
        ),
      ),
    );
  }
}
