import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/user_provider.dart';
import 'package:nexmart/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary),
        ),
        trailing: isDestructive ? null : Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.logout),
          content: Text(AppStrings.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                context.pop();
                await AuthService().signOut();
                if (!context.mounted) {
                  return;
                }
                context.go('/auth');
              },
              child: Text(AppStrings.logout, style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final userDataAsync = ref.watch(userDataProvider);
    final isAdmin = ref.watch(isAdminProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          AppStrings.profile,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null) {
            return Container();
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.xl),
                CircleAvatar(
                  radius: AppSizes.avatarLg / 2,
                  backgroundColor: AppColors.shimmer,
                  backgroundImage: user.photoUrl.isEmpty ? null : CachedNetworkImageProvider(user.photoUrl),
                  child: user.photoUrl.isEmpty
                      ? Icon(Icons.person, size: AppSizes.iconLg, color: AppColors.textSecondary)
                      : null,
                ),

                SizedBox(height: AppSizes.md),

                Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),

                SizedBox(height: AppSizes.xs),

                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),

                SizedBox(height: AppSizes.xl),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.phone_outlined,
                          AppStrings.phoneNumber,
                          user.phone.isEmpty ? 'Not set' : user.phone,
                        ),
                        Divider(color: AppColors.divider, height: 1),
                        _buildInfoRow(
                          context,
                          Icons.location_on_outlined,
                          AppStrings.address,
                          user.address.isEmpty ? 'Not set' : user.address,
                        ),
                        Divider(color: AppColors.divider, height: 1),
                        _buildInfoRow(
                          context,
                          Icons.calendar_today_outlined,
                          AppStrings.memberSince,
                          DateFormat('MMM dd, yyyy').format(user.createdAt),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.lg),

                // MENU OPTIONS SECTION
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  child: Column(
                    children: [
                      if (isAdmin)
                        _buildMenuTile(
                          context,
                          Icons.admin_panel_settings_outlined,
                          'Admin Dashboard',
                          () => context.push('/admin'),
                        ),
                      _buildMenuTile(
                        context,
                        Icons.edit_outlined,
                        AppStrings.editProfile,
                        () => context.push('/edit-profile'),
                      ),
                      _buildMenuTile(
                        context,
                        Icons.receipt_long_outlined,
                        AppStrings.myOrders,
                        () => context.push('/orders'),
                      ),
                      _buildMenuTile(
                        context,
                        Icons.logout_rounded,
                        AppStrings.logout,
                        () => _showLogoutDialog(context, ref),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.xl),
              ],
            ),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: () => ref.refresh(userDataProvider),
                      child: Text(AppStrings.tryAgain),
                    ),
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
    );
  }
}
