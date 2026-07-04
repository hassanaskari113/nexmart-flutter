import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _slides = [
    {'title': AppStrings.onboarding1Title, 'desc': AppStrings.onboarding1Desc, 'icon': Icons.explore_rounded},
    {'title': AppStrings.onboarding2Title, 'desc': AppStrings.onboarding2Desc, 'icon': Icons.local_shipping_rounded},
    {'title': AppStrings.onboarding3Title, 'desc': AppStrings.onboarding3Desc, 'icon': Icons.shield_rounded},
  ];

  Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    if (mounted) {
      context.go('/auth');
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _onGetStarted();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_slides[index]['icon'], size: 120, color: AppColors.primary),
                    SizedBox(height: AppSizes.xl),
                    Text(_slides[index]['title'], style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: AppSizes.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                      child: Text(_slides[index]['desc'], style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _onGetStarted();
                  },
                  child: Text(AppStrings.skip),
                ),
                Row(
                  children: List.generate(_slides.length, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: AppSizes.xs),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primary : AppColors.divider,
                        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    onPressed: () {
                      _nextPage();
                    },
                    child: Center(
                      child: Text(
                        _currentPage == 2 ? AppStrings.getStarted : AppStrings.next,
                        textAlign: TextAlign.center,
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
