import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/AppColors.dart';
import '../../Auth/LoginPage/view/LoginPage.dart';
import '../../MainPages/HomePage/view/HomePage.dart';
import '../../core/shared_prefs.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Check auth state after splash animation plays briefly
    Future.delayed(const Duration(milliseconds: 1500), _checkAuthAndNavigate);
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final hasStoredUser = AppPrefs.isLoggedIn;
    final hasActiveSession =
        Supabase.instance.client.auth.currentUser != null;

    if (hasStoredUser && hasActiveSession) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, animation, secondary) => const HomePage(),
          transitionsBuilder: (ctx, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Clear stale stored ID if Supabase session is gone
      if (hasStoredUser && !hasActiveSession) {
        await AppPrefs.clearUserId();
      }
      if (mounted) setState(() => _showButton = true);
    }
  }

  void _onGetStarted() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondary) => LoginPage(),
        transitionsBuilder: (ctx, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(


            children: [
              SizedBox(height: 100,),


              // ShopLux title
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Shop',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Lux',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Floating animated bag
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A1800),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🛍️',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Tagline
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: 'Shop ',
                      style: TextStyle(color: AppColors.white),
                    ),
                    TextSpan(
                      text: 'Smarter,\n',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(
                      text: 'Live Better',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Get Started button — shown only when not logged in
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: GestureDetector(
                  onTap: _showButton ? _onGetStarted : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 52,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
