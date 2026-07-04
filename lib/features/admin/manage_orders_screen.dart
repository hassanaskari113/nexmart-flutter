import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/models/order_model.dart';
import 'package:nexmart/providers/order_provider.dart';
import 'package:nexmart/services/order_service.dart';

class ManageOrdersScreen extends ConsumerWidget {
  const ManageOrdersScreen({super.key});

  Widget _buildStatusBadge(BuildContext context, String status) {
    final color = switch (status) {
      'pending' => AppColors.star,
      'confirmed' => AppColors.primary,
      'shipped' => AppColors.secondary,
      'delivered' => AppColors.success,
      'cancelled' => AppColors.error,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showStatusPicker(BuildContext context, WidgetRef ref, OrderModel order) {
    final statuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
          child: Consumer(
            builder: (context, ref, child) {
              final ordersAsync = ref.watch(allOrderProvider);
              final currentStatus =
                  ordersAsync.value?.firstWhere((o) => o.orderId == order.orderId, orElse: () => order).status ??
                  order.status;

              return Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: statuses.map((status) {
                    final color = switch (status) {
                      'pending' => AppColors.star,
                      'confirmed' => AppColors.primary,
                      'shipped' => AppColors.secondary,
                      'delivered' => AppColors.success,
                      'cancelled' => AppColors.error,
                      _ => AppColors.textSecondary,
                    };
                    final isSelected = currentStatus == status;

                    return Container(
                      margin: EdgeInsets.only(bottom: AppSizes.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                        title: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                        trailing: isSelected ? Icon(Icons.check, color: color) : null,
                        onTap: () async {
                          await OrderService().updateOrderStatus(order.orderId, status);
                          if (context.mounted) context.pop();
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrderProvider);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          'Manage Orders',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: AppSizes.iconLg * 2,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),

                  SizedBox(height: AppSizes.md),

                  Text(
                    AppStrings.emptyOrders,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),

                  SizedBox(height: AppSizes.xs),

                  Text(
                    AppStrings.emptyOrdersSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                child: ListTile(
                  title: Text('Order #${orders[index].orderId.substring(0, 8).toUpperCase()}'),
                  subtitle: Text('${orders[index].fullName} • ${formatter.format(orders[index].totalAmount)}'),
                  trailing: _buildStatusBadge(context, orders[index].status),
                  onTap: () => _showStatusPicker(context, ref, orders[index]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
              );
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
                  ElevatedButton(onPressed: () => ref.refresh(allOrderProvider), child: Text(AppStrings.tryAgain)),
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
