import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/cart_provider.dart';
import 'package:nexmart/providers/product_provider.dart';
import 'package:nexmart/providers/user_provider.dart';
import 'package:nexmart/shared/widgets/product_card.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int currentBanner = 0;
  Timer? _timer;
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Summer Sale',
      'subtitle': 'Up to 50% off on selected items',
      'gradient': [AppColors.primary, Color(0xFF1A3A6E)],
      'icon': Icons.local_offer_rounded,
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Check out the latest drops',
      'gradient': [AppColors.secondary, Color(0xFF00A89D)],
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'title': 'Free Shipping',
      'subtitle': 'On all orders over \$50',
      'gradient': [AppColors.success, Color(0xFF00A876)],
      'icon': Icons.local_shipping_rounded,
    },
    {
      'title': 'Flash Deals',
      'subtitle': 'Limited time, grab it fast',
      'gradient': [Color(0xFFFF7A45), Color(0xFFE85D2A)],
      'icon': Icons.bolt_rounded,
    },
    {
      'title': 'Top Rated',
      'subtitle': 'Loved by thousands of shoppers',
      'gradient': [Color(0xFF6C5CE7), Color(0xFF4834D4)],
      'icon': Icons.star_rounded,
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Clothing', 'icon': Icons.checkroom},
    {'name': 'Shoes', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Accessories', 'icon': Icons.watch},
  ];

  Future<void> _openWhatsApp() async {
    final phoneNumber = '923367158264';
    final message = Uri.encodeComponent('Hi, I need help with my order');
    final url = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WhatsApp')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _autoScroll();
  }

  void _autoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted || !_bannerController.hasClients) return;

      final position = _bannerController.position;
      if (position.isScrollingNotifier.value) return;

      final actualPage = _bannerController.page?.round() ?? 0;
      final nextPage = (actualPage + 1) % _banners.length;

      _bannerController.animateToPage(nextPage, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.primary, toolbarHeight: 0, elevation: 0),
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusXl),
                bottomRight: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                        ),
                        SizedBox(height: AppSizes.xs),
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                context.push('/cart');
                              },
                              icon: Icon(Icons.shopping_cart_outlined, size: AppSizes.iconLg, color: AppColors.white),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: cart.isEmpty
                                  ? Container()
                                  : Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                      child: Center(
                                        child: Text(
                                          cartNotifier.totalItems.toString(),
                                          style: TextStyle(
                                            fontSize: AppSizes.fontXs,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const ProfileIconButton(),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.lg),
                GestureDetector(
                  onTap: () {
                    context.push('/search');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.white, size: AppSizes.iconMd),
                        SizedBox(width: AppSizes.sm),
                        Text(
                          'Search products',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.md),
          SizedBox(
            height: 160,
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  currentBanner = index;
                });
              },
              itemCount: _banners.length,
              controller: _bannerController,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: banner['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Stack(
                    children: [
                      // DECORATIVE BACKGROUND ICON
                      Positioned(
                        right: -2,
                        bottom: -6,
                        child: Icon(banner['icon'], size: 100, color: Colors.white.withValues(alpha: 0.2)),
                      ),

                      // MAIN CONTENT
                      Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title'],
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: AppSizes.xs),
                            Text(
                              banner['subtitle'],
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Text('Categories', style: Theme.of(context).textTheme.titleMedium),
          ),
          SizedBox(height: AppSizes.sm),

          SizedBox(
            height: AppSizes.categoryCardSize + 30,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Row(
                children: _categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: AppSizes.md),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state = category['name'];
                        context.push('/search');
                      },
                      child: Column(
                        children: [
                          Container(
                            width: AppSizes.categoryCardSize,
                            height: AppSizes.categoryCardSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                              color: AppColors.surface,
                              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 4))],
                            ),
                            child: Center(
                              child: Icon(category['icon'], color: AppColors.primary, size: AppSizes.iconLg),
                            ),
                          ),
                          SizedBox(height: AppSizes.xs),
                          Text(category['name'], style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Text('All Products', style: Theme.of(context).textTheme.titleMedium),
          ),

          SizedBox(height: AppSizes.sm),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: AppSizes.iconLg),
                          SizedBox(height: AppSizes.sm),
                          Text(AppStrings.noProductsFound, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.md,
                    mainAxisSpacing: AppSizes.md,
                    childAspectRatio: AppSizes.productCardWidth / AppSizes.productCardHeight,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
              error: (error, stack) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.iconLg),
                        SizedBox(height: AppSizes.sm),
                        Text(AppStrings.somethingWentWrong, style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(height: AppSizes.sm),
                        ElevatedButton(
                          onPressed: () => ref.refresh(productsProvider),
                          child: Text(AppStrings.tryAgain),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF25D366),
        onPressed: () => _openWhatsApp(),
        child: FaIcon(FontAwesomeIcons.whatsapp, size: AppSizes.iconLg, color: Colors.white),
      ),
    );
  }
}

class ProfileIconButton extends ConsumerWidget {
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider).value;

    return IconButton(
      onPressed: () => context.push('/profile'),
      icon: user != null && user.photoUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 150),
                imageUrl: user.photoUrl,
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Icon(Icons.account_circle, size: AppSizes.iconLg, color: AppColors.white);
                },
                errorWidget: (context, url, error) =>
                    Icon(Icons.account_circle, size: AppSizes.iconLg, color: AppColors.white),
              ),
            )
          : Icon(Icons.account_circle, size: AppSizes.iconLg, color: AppColors.white),
    );
  }
}
