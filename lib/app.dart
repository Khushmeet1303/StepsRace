// Root widget: handles auth state routing + bottom navigation shell
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding/permission_screen.dart';
import 'screens/onboarding/auth_screen.dart';
import 'screens/track/track_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/profile/profile_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Race',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) return const _Splash();
    if (auth.user == null) return const AuthScreen();
    if (!auth.permissionGranted) return const PermissionScreen();
    return const MainNav();
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Step', style: AppText.fredoka(36, AppColors.coralDark)),
            Text('Race', style: AppText.fredoka(36, AppColors.leafDark)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  static const _screens = [
    TrackScreen(),
    LeaderboardScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.coralLight,
        destinations: const [
          NavigationDestination(icon: Text('🏁', style: TextStyle(fontSize: 20)), label: 'Track'),
          NavigationDestination(icon: Text('🏆', style: TextStyle(fontSize: 20)), label: 'Leaderboard'),
          NavigationDestination(icon: Text('📅', style: TextStyle(fontSize: 20)), label: 'History'),
          NavigationDestination(icon: Text('⚙️', style: TextStyle(fontSize: 20)), label: 'Profile'),
        ],
      ),
    );
  }
}
