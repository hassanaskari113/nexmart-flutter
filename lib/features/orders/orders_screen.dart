import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

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

  @override
  Widget build(BuildContext context, ref) {
    final orderAsync = ref.watch(orderProvider);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          AppStrings.myOrders,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: orderAsync.when(
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
                  SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(onPressed: () => context.go('/home'), child: Text('Start Shopping')),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  onTap: () {
                    context.push('/order/${orders[index].orderId}');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${orders[index].orderId.substring(0, 8).toUpperCase()}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusBadge(context, orders[index].status),
                          ],
                        ),

                        SizedBox(height: AppSizes.sm),

                        Text(
                          '${orders[index].items.length} item${orders[index].items.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),

                        SizedBox(height: AppSizes.xs),

                        Text(
                          DateFormat('MMM dd, yyyy').format(orders[index].createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),

                        SizedBox(height: AppSizes.sm),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.total, style: Theme.of(context).textTheme.bodyMedium),
                            Text(
                              formatter.format(orders[index].totalAmount),
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: () => ref.refresh(orderProvider),
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
