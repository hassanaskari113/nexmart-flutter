import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget _buildAdminTile(BuildContext context, icon, title, subtitle, onTap) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(AppSizes.md),
        leading: Icon(icon, size: AppSizes.iconLg, color: AppColors.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            _buildAdminTile(
              context,
              Icons.add_box_outlined,
              'Add Product',
              'Create a new product listing',
              () => context.push('/admin/add-product'),
            ),
            SizedBox(height: AppSizes.md),
            _buildAdminTile(
              context,
              Icons.inventory_2_outlined,
              'Manage Products',
              'Edit existing product listings',
              () => context.push('/admin/manage-products'),
            ),
            SizedBox(height: AppSizes.md),
            _buildAdminTile(
              context,
              Icons.list_alt_outlined,
              'Manage Orders',
              'View and update order statuses',
              () => context.push('/admin/manage-orders'),
            ),
          ],
        ),
      ),
    );
  }
}
