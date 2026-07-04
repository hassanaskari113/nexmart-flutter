import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Google sign-in timed out');
          return null;
        },
      );
      if (user != null) {
        if (mounted) {
          context.go('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Center(child: Text("SignIn Cancelled..."))));
        }
      }
    } catch (e) {
      debugPrint('Error in SignIn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Center(child: Text("Error in Signing in..."))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_rounded, size: 80, color: AppColors.primary),

                SizedBox(height: AppSizes.lg),

                Text(
                  AppStrings.signInTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppSizes.sm),

                Text(
                  AppStrings.signInSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppSizes.xxl),

                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : OutlinedButton(
                          onPressed: () async {
                            await _handleGoogleSignIn();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata, size: 28),
                              SizedBox(width: AppSizes.sm),
                              Text(AppStrings.signInWithGoogle),
                            ],
                          ),
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
