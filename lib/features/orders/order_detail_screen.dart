import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/models/order_model.dart';
import 'package:nexmart/providers/order_provider.dart';
import 'package:nexmart/services/order_service.dart';
import 'package:go_router/go_router.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  void _showCancelDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancel Order'),
          content: Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                context.pop();
                await OrderService().updateOrderStatus(order.orderId, 'cancelled');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order cancelled successfully')));
                }
              },
              child: Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildStatusTracker(BuildContext context, String status) {
    final steps = [
      AppStrings.orderPlaced,
      AppStrings.orderConfirmed,
      AppStrings.orderShipped,
      AppStrings.orderDelivered,
    ];

    final currentStep = switch (status) {
      'pending' => 0,
      'confirmed' => 1,
      'shipped' => 2,
      'delivered' => 3,
      _ => 0,
    };

    List<Widget> children = [];

    for (int index = 0; index < steps.length; index++) {
      final isCompleted = index <= currentStep;
      final isLast = index == steps.length - 1;

      // CIRCLE + LABEL COLUMN — fixed width, same for every step
      children.add(
        SizedBox(
          width: 60,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.success : AppColors.shimmer,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: AppSizes.iconSm,
                  color: isCompleted ? AppColors.white : Colors.transparent,
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(color: isCompleted ? AppColors.success : AppColors.textSecondary, fontSize: 9),
              ),
            ],
          ),
        ),
      );

      // CONNECTOR LINE — only between steps, never after the last one
      if (!isLast) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 13.0),
              child: Container(height: 3, color: index < currentStep ? AppColors.success : AppColors.shimmer),
            ),
          ),
        );
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  @override
  Widget build(BuildContext context, ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          AppStrings.orderDetails,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.lg),
        child: orderAsync.when(
          data: (order) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1 - ORDER ID AND STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildStatusBadge(context, order.status),
                  ],
                ),

                SizedBox(height: AppSizes.xs),

                Text(
                  DateFormat('MMM dd, yyyy – hh:mm a').format(order.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),

                SizedBox(height: AppSizes.lg),

                // SECTION 2 - ORDER STATUS TRACKER
                _buildStatusTracker(context, order.status),

                SizedBox(height: AppSizes.lg),

                // SECTION 3 - DELIVERY ADDRESS
                Text(
                  AppStrings.deliveryAddress,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),

                SizedBox(height: AppSizes.md),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 4))],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.fullName,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        order.phoneNumber,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        '${order.address}, ${order.city}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.lg),

                // SECTION 4 - ORDER ITEMS
                Text(
                  AppStrings.orderSummary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),

                SizedBox(height: AppSizes.md),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 4))],
                  ),

                  padding: EdgeInsets.all(AppSizes.md),
                  child: Column(
                    children: [
                      ...order.items.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Text(
                                formatter.format(item.totalPrice),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),

                      Divider(color: AppColors.divider, height: AppSizes.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.total,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatter.format(order.totalAmount),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (order.status == 'pending') ...[
                  SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context, ref, order),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        side: BorderSide(color: AppColors.error),
                      ),
                      child: Text(
                        'Cancel Order',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ],
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
                      onPressed: () => ref.refresh(orderByIdProvider(orderId)),
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
    );
  }
}
