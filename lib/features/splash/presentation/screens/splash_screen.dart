import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../widgets/animated_sync_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for the duration of the animation (3 seconds + small buffer)
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedSyncIcon(),
            const SizedBox(height: 40),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'FIRST SYNC',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 8.0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
