import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/budget_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/error_handler.dart';
import 'services/isar_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await IsarService().init();
  await AuthService().init();
  runApp(const TraveloopApp());
}

class TraveloopApp extends StatelessWidget {
  const TraveloopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traveloop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: StreamBuilder(
        stream: AuthService().userStream,
        initialData: AuthService().currentUser,
        builder: (context, snap) {
          if (snap.data != null) return const MainNavigation();
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ItineraryScreen(),
    BudgetScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor:
                  AppColors.textSecondary.withValues(alpha: 0.5),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 26),
                  activeIcon: Icon(Icons.home_rounded, size: 26),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note_outlined, size: 26),
                  activeIcon: Icon(Icons.event_note_rounded, size: 26),
                  label: 'Itinerary',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined, size: 26),
                  activeIcon:
                      Icon(Icons.account_balance_wallet_rounded, size: 26),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 26),
                  activeIcon: Icon(Icons.person_rounded, size: 26),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
