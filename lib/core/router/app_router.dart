import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:nexmart/features/admin/add_product_screen.dart';
import 'package:nexmart/features/admin/admin_dashboard_screen.dart';
import 'package:nexmart/features/admin/manage_orders_screen.dart';
import 'package:nexmart/features/admin/manage_products_screen.dart';
import 'package:nexmart/features/cart/cart_screen.dart';
import 'package:nexmart/features/checkout/checkout_screen.dart';
import 'package:nexmart/features/orders/order_detail_screen.dart';
import 'package:nexmart/features/orders/orders_screen.dart';
import 'package:nexmart/features/products/product_detail_screen.dart';
import 'package:nexmart/features/profile/edit_profile_screen.dart';
import 'package:nexmart/features/profile/profile_screen.dart';
import 'package:nexmart/features/search/search_screen.dart';
import 'package:nexmart/features/splash/splash_screen.dart';
import 'package:nexmart/features/onboarding/onboarding_screen.dart';
import 'package:nexmart/features/auth/auth_screen.dart';
import 'package:nexmart/features/home/home_screen.dart';

CustomTransitionPage buildPageWithTransition(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final myAppRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, SplashScreen());
      },
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, OnboardingScreen());
      },
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, AuthScreen());
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, HomeScreen());
      },
    ),
    GoRoute(
      path: '/product/:productId',
      pageBuilder: (BuildContext context, state) {
        final id = state.pathParameters['productId'];
        return buildPageWithTransition(context, state, ProductDetailScreen(productId: id!));
      },
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, SearchScreen());
      },
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, CartScreen());
      },
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, CheckoutScreen());
      },
    ),
    GoRoute(
      path: '/orders',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, OrdersScreen());
      },
    ),
    GoRoute(
      path: '/order/:orderId',
      pageBuilder: (BuildContext context, state) {
        final id = state.pathParameters['orderId'];
        return buildPageWithTransition(context, state, OrderDetailScreen(orderId: id!));
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, ProfileScreen());
      },
    ),
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, EditProfileScreen());
      },
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return '/auth';
        }
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        final role = doc.data()?['role'] ?? 'customer';
        if (role != 'admin') {
          return '/home';
        }
        return null; // null means "allow navigation, no redirect needed"
      },
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, AdminDashboardScreen());
      },
    ),
    GoRoute(
      path: '/admin/add-product',
      redirect: (context, state) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return '/auth';

        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        final role = doc.data()?['role'] ?? 'customer';
        if (role != 'admin') {
          return '/home';
        }

        return null;
      },
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, AddProductScreen());
      },
    ),
    GoRoute(
      path: '/admin/manage-orders',
      redirect: (context, state) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return '/auth';

        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        final role = doc.data()?['role'] ?? 'customer';
        if (role != 'admin') {
          return '/home';
        }

        return null;
      },
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, ManageOrdersScreen());
      },
    ),
    GoRoute(
      path: '/admin/manage-products',
      redirect: (context, state) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return '/auth';

        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        final role = doc.data()?['role'] ?? 'customer';
        if (role != 'admin') {
          return '/home';
        }

        return null;
      },
      pageBuilder: (BuildContext context, state) {
        return buildPageWithTransition(context, state, ManageProductsScreen());
      },
    ),
    GoRoute(
      path: '/admin/edit-product/:productId',
      redirect: (context, state) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return '/auth';

        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        final role = doc.data()?['role'] ?? 'customer';
        if (role != 'admin') {
          return '/home';
        }

        return null;
      },
      builder: (BuildContext context, state) {
        final productId = state.pathParameters['productId']!;
        return AddProductScreen(productId: productId);
      },
    ),
  ],
);
