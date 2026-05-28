import 'package:flutter/material.dart';

import '../../../../config/theme/app_radius.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import 'home_section_title.dart';

/// Bosh sahifada zakazlar umumiy ko'rinishi (owner/manager uchun).
class HomeOrdersSection extends StatelessWidget {
  const HomeOrdersSection({super.key, required this.orders});

  final List<WorkshopOrder> orders;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeSectionTitle(title: s.ordersOverview),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          _OrdersEmpty(s: s)
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: orders.take(3).map((o) => _OrderCard(order: o)).toList(),
          ),
      ],
    );
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BrandSurface(
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 36, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              s.ordersEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              s.ordersEmptyHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final WorkshopOrder order;

  Color _barColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (order.isDone) return Colors.green;
    if (order.isOverdue) return Colors.red;
    if (order.isUrgent) return Colors.orange;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final barColor = _barColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String statusLabel;
    Color statusColor;
    if (order.isDone) {
      statusLabel = s.orderDone;
      statusColor = Colors.green;
    } else if (order.isOverdue) {
      statusLabel = s.orderOverdue;
      statusColor = Colors.red;
    } else if (order.isUrgent) {
      statusLabel = s.orderDaysLeft(order.daysLeft);
      statusColor = Colors.orange;
    } else {
      statusLabel = s.orderDaysLeft(order.daysLeft);
      statusColor = scheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrandSurface(
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.productName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: order.progress,
                      backgroundColor:
                          scheme.onSurface.withValues(alpha: 0.08),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  s.orderProgress(order.producedQty, order.orderedQty),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              s.orderRemaining(order.remaining),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
