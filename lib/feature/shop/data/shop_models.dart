/// Online Shop মডেল — server: /api/shop/… (টাকার মান string হিসেবে আসে)
double shopNum(dynamic v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

class ShopOrderItem {
  final int id;
  final int? productId;
  final String name;
  final double unitPrice;
  final int qty;
  final double lineTotal;

  const ShopOrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.qty,
    required this.lineTotal,
  });

  factory ShopOrderItem.fromJson(Map<String, dynamic> j) => ShopOrderItem(
        id: (j['id'] as num?)?.toInt() ?? 0,
        productId: (j['product_id'] as num?)?.toInt(),
        name: '${j['product_name'] ?? ''}',
        unitPrice: shopNum(j['unit_price']),
        qty: (j['qty'] as num?)?.toInt() ?? 0,
        lineTotal: shopNum(j['line_total']),
      );
}

class ShopOrder {
  final int id;
  final String orderNo, customerName, phone, address, note, status;
  final double deliveryCharge, total;
  final int itemCount;
  final bool stockDeducted;
  final bool canEdit;
  final int? saleId;
  final String? invoiceNo;
  final double? paidAmount, dueAmount;
  final DateTime? createdAt;
  final List<ShopOrderItem> items;

  const ShopOrder({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.note,
    required this.status,
    required this.deliveryCharge,
    required this.total,
    required this.itemCount,
    required this.stockDeducted,
    this.canEdit = true,
    required this.saleId,
    required this.invoiceNo,
    this.paidAmount,
    this.dueAmount,
    required this.createdAt,
    required this.items,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isOpen => isPending || isConfirmed;
  double get itemsTotal => total - deliveryCharge;

  factory ShopOrder.fromJson(Map<String, dynamic> j) => ShopOrder(
        id: (j['id'] as num?)?.toInt() ?? 0,
        orderNo: '${j['order_no'] ?? ''}',
        customerName: '${j['customer_name'] ?? ''}',
        phone: '${j['phone'] ?? ''}',
        address: '${j['address'] ?? ''}',
        note: '${j['note'] ?? ''}',
        status: '${j['status'] ?? 'pending'}',
        deliveryCharge: shopNum(j['delivery_charge']),
        total: shopNum(j['total']),
        itemCount: (j['item_count'] as num?)?.toInt() ?? 0,
        stockDeducted: j['stock_deducted'] == true,
        canEdit: j['can_edit'] != false,
        saleId: (j['sale_id'] as num?)?.toInt(),
        invoiceNo: j['invoice_no'] as String?,
        paidAmount: j['paid_amount'] == null ? null : shopNum(j['paid_amount']),
        dueAmount: j['due_amount'] == null ? null : shopNum(j['due_amount']),
        createdAt: DateTime.tryParse('${j['created_at'] ?? ''}')?.toLocal(),
        items: [
          for (final i in (j['items'] as List? ?? const []))
            if (i is Map) ShopOrderItem.fromJson(i.cast<String, dynamic>()),
        ],
      );
}

class ShopOrderPage {
  final List<ShopOrder> items;
  final int count, totalPages;
  final Map<String, int> counts;
  final bool shopIsOpen, canEdit;
  final String shopUrl;

  const ShopOrderPage({
    required this.items,
    required this.count,
    required this.totalPages,
    required this.counts,
    required this.shopIsOpen,
    required this.canEdit,
    this.shopUrl = '',
  });
}

class ShopSettingsData {
  final Map<String, dynamic> raw;
  const ShopSettingsData(this.raw);

  String text(String key) => '${raw[key] ?? ''}';
  bool get isOpen => raw['is_open'] != false;
}
