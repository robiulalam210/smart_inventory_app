
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/web_ui.dart';
import '../../data/model/product_model.dart';
import '../shared/product_details.dart';
import 'package:meherinMart/core/widgets/app_network_img.dart';
import 'package:meherinMart/desktop/widgets/desk_kit.dart' show DeskCard;
import 'package:meherinMart/feature/lab_dashboard/presentation/widgets/dash_kit.dart' show DashColors;

class ProductDataTableWidget extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onEdit;
  final Function(ProductModel)? onDelete;

  const ProductDataTableWidget({
    super.key,
    required this.products,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _buildDesktopDataTable();
    }
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 8, vertical: 4),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildProductCard(products[index], context),
    );
  }

  /// স্টক অবস্থা: শেষ → লাল, কম → অ্যাম্বার, ঠিক আছে → সবুজ।
  ({String label, Color color}) _stockState(ProductModel p) {
    final stock = p.stockQty ?? 0;
    if (stock <= 0) return (label: 'Out of stock', color: AppColors.danger);
    if (stock <= (p.alertQuantity ?? 0)) {
      return (label: 'Low stock', color: AppColors.warning);
    }
    return (label: 'In stock', color: AppColors.success);
  }

  Widget _buildProductCard(ProductModel product, BuildContext context) {
    final textColor = W.ink(context);
    final muted = W.muted(context);
    final primary = AppColors.primaryColor(context);
    final stockState = _stockState(product);
    final active = product.isActive ?? false;
    final name = (product.name ?? '').trim();
    final sellPrice = AppTableMoney.parse(product.sellingPrice);
    final buyPrice = AppTableMoney.parse(product.purchasePrice);

    return Material(
      color: W.surface(context),
      borderRadius: BorderRadius.circular(W.rLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(W.rLg),
        onTap: () => AppRoutes.push(
          context,
          ProductDetailsScreen(productId: product.id.toString()),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(W.rLg),
            border: Border.all(color: W.line(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── উপরের অংশ: অক্ষর-আইকন, নাম, SKU, মেনু ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: W.blueWash(context),
                      borderRadius: BorderRadius.circular(W.rMd),
                    ),
                    child: Text(
                      name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: W.blueInk(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'N/A' : name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Iconsax.tag,
                              size: 13,
                              color: muted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                product.sku ?? 'N/A',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildMenu(context, product),
                ],
              ),

              const SizedBox(height: 10),

              // ── ট্যাগ: ক্যাটাগরি / ব্র্যান্ড / ইউনিট ──
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if ((product.categoryInfo?.name ?? '').isNotEmpty)
                    _tag(context, Iconsax.category, product.categoryInfo!.name!),
                  if ((product.brandInfo?.name ?? '').isNotEmpty)
                    _tag(context, Iconsax.building, product.brandInfo!.name!),
                  if ((product.unitInfo?.name ?? '').isNotEmpty)
                    _tag(context, Iconsax.ruler, product.unitInfo!.name!),
                ],
              ),

              const SizedBox(height: 12),

              // ── নিচের অংশ: দাম / স্টক / অবস্থা ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: W.soft(context),
                  border: Border.all(color: W.line(context)),
                  borderRadius: BorderRadius.circular(W.rMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _metric(
                        context,
                        label: 'Sell Price',
                        value: '৳ ${sellPrice.toStringAsFixed(2)}',
                        valueColor: primary,
                        sub: buyPrice > 0
                            ? 'Cost ৳ ${buyPrice.toStringAsFixed(2)}'
                            : null,
                      ),
                    ),
                    _divider(context),
                    Expanded(
                      child: _metric(
                        context,
                        label: 'Stock',
                        value: '${product.stockQty ?? 0}',
                        valueColor: stockState.color,
                        sub: stockState.label,
                        subColor: stockState.color,
                      ),
                    ),
                    _divider(context),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 5),
                          AppStatusPill(
                            active ? 'Active' : 'Inactive',
                            color: active ? AppColors.success : AppColors.danger,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, ProductModel product) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_rounded,
        color: W.muted(context),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
      onSelected: (v) {
        switch (v) {
          case 'view':
            AppRoutes.push(
              context,
              ProductDetailsScreen(productId: product.id.toString()),
            );
            break;
          case 'edit':
            onEdit?.call(product);
            break;
          case 'delete':
            _showDeleteConfirmation(context, product);
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem('view', Iconsax.eye, 'View details', AppColors.info),
        if (onEdit != null)
          _menuItem('edit', Iconsax.edit, 'Edit', AppColors.warning),
        _menuItem('delete', Iconsax.trash, 'Delete', AppColors.danger),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: W.tint(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: W.muted(context)),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: W.ink2(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    String? sub,
    Color? subColor,
  }) {
    final c = W.muted(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: c),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
              fontFeatures: W.tabular,
            ),
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 1),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: subColor ?? c,
            ),
          ),
        ],
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: W.line(context),
      );

  // Desktop টেবিল — AppDataTable
  // দাম আর stock যোগ করা হয়েছে — product list এ সবচেয়ে বেশি এগুলোই দেখা হয়।
  // stock alert quantity এর নিচে নামলে লাল।
  Widget _buildDesktopDataTable() {
    return Builder(builder: (context) {
      final c = DashColors(context);
      Widget th(String t, {int flex = 1, double? width, bool right = false}) {
        final w = Text(t.toUpperCase(),
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: .5, color: c.muted));
        return width != null ? SizedBox(width: width, child: w) : Expanded(flex: flex, child: w);
      }

      return DeskCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Row(children: [
              th('Product', flex: 5),
              th('Brand / Unit', flex: 2),
              th('Price', flex: 2, right: true),
              th('Stock', flex: 2, right: true),
              th('Status', width: 92, right: true),
              th('', width: 124, right: true),
            ]),
          ),
          Divider(height: 1, color: c.line),
          for (final p in products) _desktopRow(context, c, p),
        ]),
      );
    });
  }

  String _money(num v) {
    final s = v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
    final parts = s.split('.');
    final whole = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return parts.length > 1 ? '$whole.${parts[1]}' : whole;
  }

  Widget _thumb(DashColors c, ProductModel p) {
    final img = p.image is String ? (p.image as String).trim() : '';
    final box = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.line)),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: img.startsWith('http')
          ? AppNetworkImage(imageUrl: img, height: 44, icon: Icons.inventory_2_outlined, iconSize: 20)
          : Icon(Icons.inventory_2_outlined, size: 20, color: c.muted),
    );
    return box;
  }

  Widget _desktopRow(BuildContext context, DashColors c, ProductModel p) {
    final stock = p.stockQty ?? 0;
    final st = _stockState(p);
    final active = p.isActive ?? false;
    final sell = AppTableMoney.parse(p.sellingPrice);
    final fin = AppTableMoney.parse(p.finalPrice);
    final hasDiscount = (p.discountApplied ?? false) && fin > 0 && fin < sell;
    final cat = p.categoryInfo?.name ?? '';

    Widget action(IconData i, String tip, Color col, VoidCallback? t) => IconButton(
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          onPressed: t,
          icon: Icon(i, size: 19, color: col),
        );

    return InkWell(
      onTap: () => AppRoutes.push(context, ProductDetailsScreen(productId: p.id.toString())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
        child: Row(children: [
          Expanded(
            flex: 5,
            child: Row(children: [
              _thumb(c, p),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, color: c.ink)),
                  Text([if ((p.sku ?? '').isNotEmpty) p.sku!, if (cat.isNotEmpty) cat].join('  ·  '),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.muted)),
                ]),
              ),
            ]),
          ),
          Expanded(
            flex: 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.brandInfo?.name ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.ink2)),
              Text(p.unitInfo?.name ?? '—', style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ),
          Expanded(
            flex: 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('৳${_money(hasDiscount ? fin : sell)}', style: TextStyle(fontWeight: FontWeight.w800, color: c.ink)),
              if (hasDiscount)
                Text('৳${_money(sell)}',
                    style: TextStyle(fontSize: 12, color: c.muted, decoration: TextDecoration.lineThrough))
              else
                Text('Buy ৳${_money(AppTableMoney.parse(p.purchasePrice))}', style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ),
          Expanded(
            flex: 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$stock', style: TextStyle(fontWeight: FontWeight.w800, color: stock <= 0 ? st.color : c.ink)),
              Text(st.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: st.color)),
            ]),
          ),
          SizedBox(
            width: 92,
            child: Align(
              alignment: Alignment.centerRight,
              child: AppStatusPill(active ? 'Active' : 'Inactive', color: active ? AppColors.success : AppColors.danger),
            ),
          ),
          SizedBox(
            width: 124,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              action(Icons.visibility_outlined, 'View', c.blue,
                  () => AppRoutes.push(context, ProductDetailsScreen(productId: p.id.toString()))),
              if (onEdit != null) action(Icons.edit_outlined, 'Edit', c.amber, () => onEdit!(p)),
              action(Icons.delete_outline_rounded, 'Delete', c.red, () => _showDeleteConfirmation(context, p)),
            ]),
          ),
        ]),
      ),
    );
  }

  /// নিশ্চিতকরণ dialog দুই screen এর (desktop/mobile) onDelete এ আগে থেকেই আছে;
  /// তাই এখানে আবার না দেখিয়ে সরাসরি callback ডাকা হয় (আগে দুবার জিজ্ঞেস করত)।
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ProductModel product,
  ) async {
    onDelete?.call(product);
  }
}
