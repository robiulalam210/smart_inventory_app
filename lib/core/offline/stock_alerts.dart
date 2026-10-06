import 'package:flutter/foundation.dart';

import 'local_store.dart';
import 'offline_config.dart';

class StockAlertItem {
  final int productId;
  final String name;
  final num available;
  final num alertQty;

  const StockAlertItem(this.productId, this.name, this.available, this.alertQty);

  bool get isOut => available <= 0;
}

/// Offline অবস্থায় কোন পণ্যের stock শেষ বা কম — server এর শেষ জানা stock থেকে
/// offline বিক্রি বাদ দিয়ে, offline ক্রয় যোগ করে হিসাব। UI banner ও Sync Center এটা দেখায়।
class StockAlerts {
  StockAlerts._();
  static final StockAlerts instance = StockAlerts._();

  final ValueNotifier<List<StockAlertItem>> outOfStock = ValueNotifier(const []);
  final ValueNotifier<List<StockAlertItem>> lowStock = ValueNotifier(const []);

  Future<void> refresh() async {
    if (!OfflineConfig.enabled || !LocalStore.instance.isOpen) return;
    try {
      final products = await LocalStore.instance.queryEntities('product', isActive: true);
      final delta = await LocalStore.instance.pendingStockDelta();
      final out = <StockAlertItem>[];
      final low = <StockAlertItem>[];
      for (final p in products) {
        final id = p['id'];
        if (id is! int) continue;
        final available = (num.tryParse('${p['stock_qty'] ?? 0}') ?? 0) + (delta[id] ?? 0);
        final alert = num.tryParse('${p['alert_quantity'] ?? 0}') ?? 0;
        final item = StockAlertItem(id, '${p['name'] ?? 'Product #$id'}', available, alert);
        if (available <= 0) {
          out.add(item);
        } else if (available <= alert) {
          low.add(item);
        }
      }
      out.sort((a, b) => a.name.compareTo(b.name));
      low.sort((a, b) => a.available.compareTo(b.available));
      outOfStock.value = out;
      lowStock.value = low;
    } catch (e) {
      debugPrint('StockAlerts.refresh failed: $e');
    }
  }
}
