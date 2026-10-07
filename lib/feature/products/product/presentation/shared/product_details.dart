import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../sale_mode/presentation/shared/product_sale_mode_list_screen.dart';
import '../../data/model/product_model.dart';

// Import your BLoC files
import '../bloc/products/products_bloc.dart'; // Adjust path as needed

class ProductDetailsScreen extends StatefulWidget {
  final String productId; // Change from ProductModel to productId
  final ProductModel? initialProduct; // Optional initial data

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct ?? ProductModel(id: int.parse(widget.productId));

    // Fetch product details if not provided initially
    if (widget.initialProduct == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductsBloc>().add(
          FetchProductDetails(
            productId: widget.productId,
             context,
          ),
        );
        context.read<ProductsBloc>().add(
          FetchProductsList(
            context,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is ProductDetailsSuccess) {
          setState(() {
            _product = state.product;
          });
        }
      },
      builder: (context, state) {
        if (state is ProductDetailsLoading && widget.initialProduct == null) {
          return _buildLoadingScreen();
        }

        if (state is ProductDetailsFailed && widget.initialProduct == null) {
          return _buildErrorScreen(state.content);
        }

        return _buildContent();
      },
    );
  }

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _money(dynamic v) => '৳${_num(v).toStringAsFixed(2)}';

  void _refresh() {
    context.read<ProductsBloc>().add(
          FetchProductDetails(productId: widget.productId, context),
        );
  }

  // ------------------------------------------------------------
  // নতুন layout (desktop):
  //   ১. উপরে hero — ছবি, নাম, SKU/status/category, ডানে দাম ও margin
  //   ২. ৪টা KPI — Current stock, Opening, Alert level, Stock value
  //   ৩. দুই column — বাঁয়ে Basic info + Sale modes, ডানে Pricing + Record
  // আগে সব card একটার নিচে আরেকটা পুরো চওড়া হয়ে বসত, বড় পর্দায় অনেক ফাঁকা
  // জায়গা থাকত, আর "Manage Sale Modes" FAB content ঢেকে দিত — এখন
  // বাটনটা উপরের bar এ।
  // ------------------------------------------------------------
  Widget _buildContent() {
    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: _product.name ?? 'Product Details',
        breadcrumb: const ['Products', 'Product Details'],
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
          const SizedBox(width: 6),
          PopoverButton(
            label: 'Manage Sale Modes',
            primary: true,
            icon: Iconsax.money_change,
            onPressed: () => _navigateToSaleModes(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 980;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 16),
                      _buildStats(wide),
                      const SizedBox(height: 16),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(children: [
                                _buildBasicInfoCard(),
                                _buildSaleModesSection(),
                              ]),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(children: [
                                _buildPricingCard(),
                                _buildMetadataCard(),
                              ]),
                            ),
                          ],
                        )
                      else ...[
                        _buildBasicInfoCard(),
                        _buildPricingCard(),
                        _buildSaleModesSection(),
                        _buildMetadataCard(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Loading screen
  Widget _buildLoadingScreen() {
    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: 'Product Details',
        breadcrumb: const ['Products'],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryColor(context),
            ),
            const SizedBox(height: 20),
            Text(
              "Loading product details...",
              style: AppTextStyle.body(context).copyWith(
                color: AppColors.greyColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error screen
  Widget _buildErrorScreen(String error) {
    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: 'Product Details',
        breadcrumb: const ['Products'],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.warning_2,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 20),
              Text(
                "Failed to load product",
                style: AppTextStyle.titleMedium(context).copyWith(
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                style: AppTextStyle.body(context).copyWith(
                  color: AppColors.greyColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              AppButton(
                name: "Retry",
                onPressed: () {
                  context.read<ProductsBloc>().add(
                    FetchProductDetails(
                      productId: widget.productId,
                      context,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Go Back",
                  style: TextStyle(
                    color: AppColors.primaryColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation Method
  void _navigateToSaleModes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSaleModeListScreen(
          productId: widget.productId,
          productName: _product.name,
        ),
      ),
    );
  }

  // ---------------- hero ----------------
  Widget _buildHero() {
    final bool active = _product.isActive ?? false;
    final double purchase = _num(_product.purchasePrice);
    final double selling = _num(_product.sellingPrice);
    final double margin =
        selling > 0 ? ((selling - purchase) / selling) * 100 : 0;
    final String? image =
        _product.image is String ? _product.image as String : null;
    final Color primary = AppColors.primaryColor(context);
    final Color text = AppColors.text(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: (image != null && image.startsWith('http'))
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Iconsax.box, size: 34, color: primary),
                  )
                : Icon(Iconsax.box, size: 34, color: primary),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product.name ?? 'Unnamed product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if ((_product.sku ?? '').isNotEmpty)
                      DetailPill(_product.sku!,
                          color: AppColors.greyColor(context),
                          icon: Icons.qr_code_2_rounded),
                    DetailPill(active ? 'Active' : 'Inactive',
                        color: active ? AppColors.success : AppColors.danger,
                        icon: active
                            ? Icons.check_circle_outline
                            : Icons.block_outlined),
                    if ((_product.categoryInfo?.name ?? '').isNotEmpty)
                      DetailPill(_product.categoryInfo!.name!,
                          color: AppColors.info,
                          icon: Icons.category_outlined),
                    if (_product.discountApplied == true)
                      DetailPill(
                          'Discount ${_product.discountValue ?? ''}${_product.discountType == 'percentage' ? '%' : ''}',
                          color: AppColors.warning,
                          icon: Icons.local_offer_outlined),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Selling Price',
                style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 2),
              Text(
                _money(selling),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cost ${_money(purchase)}  ·  Margin ${margin.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.5,
                  color: margin >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- KPI ----------------
  Widget _buildStats(bool wide) {
    final int stock = _product.stockQty ?? 0;
    final int alert = _product.alertQuantity ?? 0;
    final int opening = _product.openingStock ?? 0;
    final bool low = stock <= alert;
    final double value = stock * _num(_product.purchasePrice);

    final stats = [
      DetailStat(
        label: 'Current Stock',
        value: '$stock',
        icon: Iconsax.box,
        color: low ? AppColors.danger : AppColors.success,
        caption: low ? 'Low stock — restock soon' : 'In stock',
      ),
      DetailStat(
        label: 'Opening Stock',
        value: '$opening',
        icon: Iconsax.archive_1,
        color: AppColors.info,
      ),
      DetailStat(
        label: 'Alert Level',
        value: '$alert',
        icon: Iconsax.warning_2,
        color: AppColors.warning,
        caption: alert > 0 ? 'Warn when stock ≤ $alert' : null,
      ),
      DetailStat(
        label: 'Stock Value (cost)',
        value: _money(value),
        icon: Iconsax.wallet_money,
        color: AppColors.primaryColor(context),
      ),
    ];

    if (wide) {
      return Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: stats[i]),
          ],
        ],
      );
    }
    return Column(
      children: [
        Row(children: [
          Expanded(child: stats[0]),
          const SizedBox(width: 12),
          Expanded(child: stats[1]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: stats[2]),
          const SizedBox(width: 12),
          Expanded(child: stats[3]),
        ]),
      ],
    );
  }

  // ---------------- basic info ----------------
  Widget _buildBasicInfoCard() {
    return DetailSection(
      title: 'Basic Information',
      icon: Iconsax.info_circle,
      child: DetailGrid(
        items: [
          DetailItem('Category', _product.categoryInfo?.name,
              icon: Iconsax.category),
          DetailItem('Unit', _product.unitInfo?.name, icon: Iconsax.ruler),
          DetailItem('Brand', _product.brandInfo?.name, icon: Iconsax.tag),
          DetailItem('Group', _product.groupInfo?.name,
              icon: Iconsax.layer),
          DetailItem('Source', _product.sourceInfo?.name,
              icon: Iconsax.import),
          DetailItem('Stock Status',
              _product.stockStatusDisplay ?? _product.stockStatus,
              icon: Iconsax.chart_2),
        ],
      ),
    );
  }

  // ---------------- pricing ----------------
  Widget _buildPricingCard() {
    final double purchase = _num(_product.purchasePrice);
    final double selling = _num(_product.sellingPrice);
    final double profit = selling - purchase;
    final bool hasDiscount = _product.discountApplied == true;

    Widget row(String label, String value,
        {Color? color, bool strong = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.text(context).withValues(alpha: 0.7),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: strong ? 16 : 14,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                color: color ?? AppColors.text(context),
              ),
            ),
          ],
        ),
      );
    }

    return DetailSection(
      title: 'Pricing',
      icon: Iconsax.money_4,
      child: Column(
        children: [
          row('Purchase Price', _money(purchase)),
          row('Selling Price', _money(selling),
              color: AppColors.primaryColor(context)),
          row('Profit per unit', _money(profit),
              color: profit >= 0 ? AppColors.success : AppColors.danger),
          if (hasDiscount) ...[
            row(
              'Discount',
              '${_product.discountValue ?? '0'}${_product.discountType == 'percentage' ? ' %' : ' TK'}',
              color: AppColors.warning,
            ),
            const Divider(height: 18),
            row('Final Price', _money(_product.finalPrice ?? selling),
                strong: true, color: AppColors.primaryColor(context)),
          ],
        ],
      ),
    );
  }

  // ---------------- sale modes ----------------
  Widget _buildSaleModesSection() {
    final saleModes = _product.saleModes ?? [];

    return DetailSection(
      title: 'Sale Modes',
      icon: Iconsax.money_change,
      trailing: saleModes.isEmpty
          ? null
          : TextButton(
              onPressed: () => _navigateToSaleModes(context),
              child: Text('View all (${saleModes.length})'),
            ),
      child: saleModes.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Icon(Iconsax.money_2,
                      size: 34, color: AppColors.greyColor(context)),
                  const SizedBox(height: 8),
                  Text(
                    'No sale modes configured',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a sale mode (e.g. Dozen, Box) to sell this product in different units or tier prices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.text(context).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PopoverButton(
                    label: 'Add Sale Mode',
                    primary: true,
                    icon: Icons.add_rounded,
                    onPressed: () => _navigateToSaleModes(context),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                for (final m in saleModes.take(4)) _buildSaleModeTile(m),
              ],
            ),
    );
  }

  Widget _buildSaleModeTile(SaleMode m) {
    final bool active = m.isActive ?? false;
    final tiers = m.tiers ?? [];
    final Color text = AppColors.text(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  m.saleModeName ?? 'Unnamed mode',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: text),
                ),
              ),
              DetailPill((m.priceType ?? 'N/A').toUpperCase(),
                  color: AppColors.info),
              const SizedBox(width: 6),
              DetailPill(active ? 'Active' : 'Inactive',
                  color: active ? AppColors.success : AppColors.danger),
            ],
          ),
          if (m.unitPrice != null || m.conversionFactor != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (m.unitPrice != null) 'Unit price ${_money(m.unitPrice)}',
                if (m.conversionFactor != null)
                  '1 = ${m.conversionFactor} ${m.baseUnitName ?? ''}',
              ].join('   ·   '),
              style: TextStyle(fontSize: 12.5, color: text.withValues(alpha: 0.65)),
            ),
          ],
          if (tiers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in tiers)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor(context)
                          .withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${t.minQuantity ?? 0}–${t.maxQuantity ?? '∞'} : ${_money(t.price)}',
                      style: TextStyle(fontSize: 12, color: text),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- record ----------------
  Widget _buildMetadataCard() {
    return DetailSection(
      title: 'Record',
      icon: Iconsax.clock,
      child: DetailGrid(
        maxColumns: 2,
        items: [
          DetailItem('Created By', _product.createdByInfo?.username,
              icon: Iconsax.user),
          DetailItem('Created At',
              appWidgets.convertDateTimeDDMMYYYY(_product.createdAt),
              icon: Iconsax.calendar_1),
          DetailItem('Last Updated',
              appWidgets.convertDateTimeDDMMYYYY(_product.updatedAt),
              icon: Iconsax.refresh),
          DetailItem('Description', _product.description,
              icon: Iconsax.document_text, fullWidth: true),
        ],
      ),
    );
  }
}
