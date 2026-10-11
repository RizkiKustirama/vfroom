import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'screens/onboarding_screen.dart';
import 'screens/stylist_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FitWardrobeApp()));
}

class FitWardrobeApp extends StatelessWidget {
  const FitWardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYRO FitWardrobe AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightBackgroundEnd,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryOrange,
          primary: AppColors.primaryOrange,
        ),
      ),
      home: const RootNavigator(),
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  bool _isOnboarded = false;

  @override
  Widget build(BuildContext context) {
    if (!_isOnboarded) {
      return OnboardingScreen(
        onGetStarted: () {
          setState(() {
            _isOnboarded = true;
          });
        },
      );
    }
    return const StylistScreen();
  }
}
