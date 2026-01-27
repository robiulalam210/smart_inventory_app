import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../sale_mode/presentation/pages/product_sale_mode_list_screen.dart';
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

  Widget _buildContent() {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "Product Details",
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductsBloc>().add(
                FetchProductDetails(
                  productId: widget.productId,
                 context,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Header Card
              _buildProductHeaderCard(),
              const SizedBox(height: 20),

              // Basic Information
              _buildSectionTitle("Basic Information"),
              _buildBasicInfoCard(),
              const SizedBox(height: 20),

              // Pricing Information
              _buildSectionTitle("Pricing & Stock"),
              _buildPricingStockCard(),
              const SizedBox(height: 20),

              // Sale Modes Section
              _buildSaleModesSection(),
              const SizedBox(height: 20),

              // Metadata
              _buildSectionTitle("Metadata"),
              _buildMetadataCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToSaleModes(context),
        icon: const Icon(Iconsax.money_change),
        label: const Text("Manage Sale Modes"),
        backgroundColor: AppColors.primaryColor(context),
      ),
    );
  }

  // Loading screen
  Widget _buildLoadingScreen() {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "Product Details",
          style: AppTextStyle.titleMedium(context),
        ),
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
      appBar: AppBar(
        title: Text(
          "Product Details",
          style: AppTextStyle.titleMedium(context),
        ),
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
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                "Failed to load product",
                style: AppTextStyle.titleMedium(context).copyWith(
                  color: Colors.red,
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

  Widget _buildProductHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor(context).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.greyColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.greyColor(context).withOpacity(0.3),
              ),
            ),
            child: _product.image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _product.image.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Iconsax.box,
                    size: 40,
                    color: AppColors.greyColor(context),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
                : Icon(
              Iconsax.box,
              size: 40,
              color: AppColors.greyColor(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product.name ?? "Unnamed Product",
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _product.sku ?? "No SKU",
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColors.greyColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_product.isActive != null)
                      _buildStatusBadge(_product.isActive!),
                    const Spacer(),
                    if (_product.finalPrice != null)
                      Text(
                        "৳${_product.finalPrice}",
                        style: AppTextStyle.titleMedium(context).copyWith(
                          color: AppColors.primaryColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyle.titleMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyColor(context).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Iconsax.category,
            label: "Category",
            value: _product.categoryInfo?.name ?? "Not set",
          ),
          const Divider(),
          _buildInfoRow(
            icon: Iconsax.ruler,
            label: "Unit",
            value: _product.unitInfo?.name ?? "Not set",
          ),
          const Divider(),
          _buildInfoRow(
            icon: Iconsax.building,
            label: "Brand",
            value: _product.brandInfo?.name ?? "Not set",
          ),
          const Divider(),
          _buildInfoRow(
            icon: Iconsax.people,
            label: "Group",
            value: _product.groupInfo?.name ?? "Not set",
          ),
          const Divider(),
          _buildInfoRow(
            icon: Iconsax.import,
            label: "Source",
            value: _product.sourceInfo?.name ?? "Not set",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryColor(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColors.greyColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyle.body(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStockCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyColor(context).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  title: "Purchase Price",
                  price: _product.purchasePrice?.toString() ?? "0.00",
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceCard(
                  title: "Selling Price",
                  price: _product.sellingPrice?.toString() ?? "0.00",
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_product.discountApplied ?? false)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.discount_shape, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Discount Applied",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${_product.discountType ?? 'N/A'}: ${_product.discountValue ?? '0'}",
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Final: ৳${_product.finalPrice ?? _product.sellingPrice ?? '0.00'}",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildStockInfo(),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String price,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "৳$price",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo() {
    final stockQty = _product.stockQty ?? 0;
    final alertQty = _product.alertQuantity ?? 0;
    final openingStock = _product.openingStock ?? 0;
    final isLowStock = stockQty <= alertQty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stock Information",
          style: AppTextStyle.bodyLarge(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStockMetric(
                label: "Current Stock",
                value: "$stockQty",
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStockMetric(
                label: "Opening Stock",
                value: "$openingStock",
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStockMetric(
                label: "Alert Level",
                value: "$alertQty",
                color: isLowStock ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLowStock ? Colors.red : Colors.green,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLowStock ? Iconsax.warning_2 : Iconsax.tick_circle,
                color: isLowStock ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLowStock
                      ? "Low Stock Alert! Current stock ($stockQty) is at or below alert level ($alertQty)"
                      : "Stock is sufficient",
                  style: TextStyle(
                    color: isLowStock ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSaleModesSection() {
    final saleModes = _product.saleModes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle("Sale Modes"),
            if (saleModes.isNotEmpty)
              TextButton.icon(
                onPressed: () => _navigateToSaleModes(context),
                icon: Icon(
                  Iconsax.eye,
                  size: 16,
                  color: AppColors.primaryColor(context),
                ),
                label: Text(
                  "View All",
                  style: TextStyle(
                    color: AppColors.primaryColor(context),
                  ),
                ),
              ),
          ],
        ),

        if (saleModes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Iconsax.money_2,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  "No Sale Modes Configured",
                  style: AppTextStyle.body(context).copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add sale modes to enable different pricing options",
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppButton(
                  name: "Add Sale Mode",
                  onPressed: () => _navigateToSaleModes(context),
                ),
              ],
            ),
          )
        else
          ...saleModes.take(3).map((saleMode) => _buildSaleModeCard(saleMode)),

        if (saleModes.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "+ ${saleModes.length - 3} more sale modes",
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColors.greyColor(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaleModeCard(SaleMode saleMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.greyColor(context).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  saleMode.saleModeName ?? "Unnamed Mode",
                  style: AppTextStyle.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSaleModeChip(
                "Type: ${saleMode.priceType?.toUpperCase() ?? 'N/A'}",
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildSaleModeChip(
                saleMode.isActive ?? false ? "Active" : "Inactive",
                color: (saleMode.isActive ?? false) ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (saleMode.unitPrice != null)
            Text(
              "Unit Price: ৳${saleMode.unitPrice}",
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColors.primaryColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          if (saleMode.tiers?.isNotEmpty ?? false)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "Tier Pricing:",
                  style: AppTextStyle.bodySmall(context),
                ),
                ...saleMode.tiers!.map((tier) {
                  final min = tier.minQuantity ?? "0";
                  final max = tier.maxQuantity ?? "∞";
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      "• ${min}-${max}: ৳${tier.price}",
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColors.greyColor(context),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSaleModeChip(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyColor(context).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            label: "Created By",
            value: _product.createdByInfo?.username ?? "Unknown",
          ),
          const Divider(),
          _buildMetadataRow(
            label: "Created At",
            value: _formatDate(_product.createdAt),
          ),
          const Divider(),
          _buildMetadataRow(
            label: "Last Updated",
            value: _formatDate(_product.updatedAt),
          ),
          if (_product.description?.isNotEmpty ?? false) ...[
            const Divider(),
            _buildMetadataRow(
              label: "Description",
              value: _product.description ?? "",
              isMultiLine: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColors.greyColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyle.body(context),
                  maxLines: isMultiLine ? null : 1,
                  overflow: isMultiLine ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}