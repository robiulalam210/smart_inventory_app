import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/feature/products/sale_mode/presentation/pages/sale_mode_create_screen.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_scaffold.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';

import '../../../price_tier/presentation/bloc/price_tier_bloc.dart';
import '../../../price_tier/presentation/page/price_tier_management_dialog.dart';
import '../../data/product_sale_mode_model.dart';
import '../bloc/product_sale_mode/product_sale_mode_bloc.dart';
import '../bloc/sale_mode_bloc.dart';
import 'product_sale_mode_config_screen.dart';

class ProductSaleModeListScreen extends StatefulWidget {
  final String productId;
  final String? productName;

  const ProductSaleModeListScreen({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  State<ProductSaleModeListScreen> createState() =>
      _ProductSaleModeListScreenState();
}

class _ProductSaleModeListScreenState extends State<ProductSaleModeListScreen> {
  late final ProductSaleModeBloc productSaleModeBloc;
  late final PriceTierBloc priceTier;

  @override
  void initState() {
    super.initState();
    productSaleModeBloc = context.read<ProductSaleModeBloc>();
    priceTier = context.read<PriceTierBloc>();
    _fetchAvailableModes();
    _fetchConfiguredModes();
  }

  void _fetchConfiguredModes({String filterText = ''}) {
    productSaleModeBloc.add(
      FetchProductSaleModeList(
        context,
        productId: widget.productId,
        filterText: filterText,
      ),
    );
  }

  void _fetchAvailableModes() {
    priceTier.add(
      FetchAvailableSaleModes(context, productId: widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.productName != null
              ? "Sale Modes - ${widget.productName}"
              : "Product Sale Modes",
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchConfiguredModes();
              // _fetchAvailableModes();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showBulkConfigDialog(context),
        child:  Icon(Icons.settings,color: AppColors.whiteColor(context),),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchConfiguredModes();
            // _fetchAvailableModes();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildAvailableModesSection(),
                // const SizedBox(height: 16),
                _buildConfiguredModesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return CustomSearchTextFormField(
      controller: productSaleModeBloc.filterTextController,
      hintText: "configured sale modes...",
      isRequiredLabel: false,
      onClear: () {
        productSaleModeBloc.filterTextController.clear();
        _fetchConfiguredModes();
        FocusScope.of(context).unfocus();
      },
      onChanged: (value) => _fetchConfiguredModes(filterText: value),
    );
  }

  Widget _buildAvailableModesSection() {
    return BlocBuilder<PriceTierBloc, PriceTierState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is AvailableSaleModesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AvailableSaleModesFailed) {
          return _buildErrorContainer(
            'Failed to load: ${state.content}',
            Colors.red,
          );
        }

        if (state is AvailableSaleModesSuccess) {
          final availableModes = state.availableModes;

          if (availableModes.isEmpty) {
            return _buildInfoContainer(
              "No sale modes available for this product's unit",
            );
          }

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Available Sale Modes (${availableModes.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableModes.map((mode) {
                    final isConfigured = mode.configured == true;
                    final isActive = mode.isActive == true;

                    return Chip(
                      label: Text(mode.name ?? ''),
                      backgroundColor: isConfigured
                          ? (isActive ? Colors.green[100] : Colors.grey[300])
                          : Colors.blue[100],
                      labelStyle: TextStyle(
                        color: isConfigured
                            ? (isActive ? Colors.green[900] : Colors.grey[700])
                            : Colors.blue[900],
                        fontWeight: isConfigured
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isConfigured
                          ? Icon(
                              isActive ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: isActive ? Colors.green : Colors.grey,
                            )
                          : const Icon(
                              Icons.add_circle,
                              size: 16,
                              color: Colors.blue,
                            ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildConfiguredModesList() {
    return BlocBuilder<ProductSaleModeBloc, ProductSaleModeState>(
      // buildWhen: (previous, current) =>
      //     previous.runtimeType != current.runtimeType ||
      //     (previous is ProductSaleModeListSuccess &&
      //         current is ProductSaleModeListSuccess &&
      //         previous.list != current.list),
      builder: (context, state) {
        print(state);
        if (state is ProductSaleModeListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductSaleModeListFailed) {
          return Center(
            child: Text(
              'Failed to load: ${state.content}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is ProductSaleModeListSuccess) {
          print("ProductSaleModeListSuccess $ProductSaleModeListSuccess");
          final list = state.list;

          if (list.isEmpty) {
            return Column(
              children: [
                Lottie.asset(AppImages.noData, width: 150, height: 150),
                const SizedBox(height: 16),
                const Text(
                  'No sale modes configured for this product',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _fetchAvailableModes,
                  child: const Text('View Available Modes'),
                ),
              ],
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ProductSaleModeModel mode = list[index];

              return _buildModeCard(mode);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildModeCard(ProductSaleModeModel mode) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: BorderSide(color: AppColors.greyColor(context)),
      ),
      color: AppColors.bottomNavBg(context),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mode.saleModeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  mode.saleModeCode,
                  style:  TextStyle(fontSize: 14, color: AppColors.text(context)),
                ),
              ],
            ),
            // Prices & Conversion
            Wrap(
              spacing: 6,
              runSpacing: 2,
              children: [
                if (mode.unitPrice != null)
                  Chip(
                    label: Text(
                      'Unit: ${mode.unitPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                if (mode.flatPrice != null)
                  Chip(
                    label: Text(
                      'Flat: ${mode.flatPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                if (mode.conversionFactor != null)
                  Chip(
                    label: Text(
                      'Conv: ${mode.conversionFactor.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.purple,
                  ),
                Chip(
                  label: Text(
                    mode.isActive == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: mode.isActive == true ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: mode.isActive == true
                      ? Colors.green
                      : Colors.grey[300],
                ),
              ],
            ),
            if (mode.discountValue != null)
              Text(
                'Discount: ${mode.discountValue} (${mode.discountType ?? ''})',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),

            if (mode.tiers != null && mode.tiers.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Price Tiers:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              ...mode.tiers.map(
                (tier) => Text(
                  '${tier.minQuantity ?? 0} - ${tier.maxQuantity ?? 0}: ${tier.price?.toString() ?? 0}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // IconButton(
                //   icon: Icon(
                //     Icons.earbuds,
                //     color: AppColors.primaryColor(context),
                //   ),
                //   onPressed: () => _openPriceTierDialog(context, mode),
                // ),
                IconButton(
                  icon: Icon(
                    Iconsax.edit,
                    color: AppColors.primaryColor(context),
                  ),
                  onPressed: () => _showEditDialog(context, mode),
                ),
                IconButton(
                  icon: const Icon(  HugeIcons.strokeRoundedDeleteThrow, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, mode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyColor(context)),
      ),
      child: Text(message, textAlign: TextAlign.center),
    );
  }

  Widget _buildErrorContainer(String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _openPriceTierDialog(BuildContext context, ProductSaleModeModel mode) {
    debugPrint("object ${mode.toJson()}");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🔥 important for full height
      useSafeArea: true,
      backgroundColor: AppColors.bottomNavBg(context), // allows rounded corners
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95, // almost full screen
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: PriceTierManagementDialog(
                productId: widget.productId.toString(),
                productSaleModeId: mode.id,
                title: "Price Tier Management",
              ),
            );
          },
        );
      },
    );
  }
  void _showEditDialog(BuildContext context, ProductSaleModeModel mode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,

            child: ProductSaleModeConfigScreen(
              productId: widget.productId, // ✅ REQUIRED
              initialData: mode.toJson(),            // ✅ EDIT MODE DATA
            ),
          ),
        ),
      ),
    );
  }


  void _showDeleteDialog(BuildContext context, ProductSaleModeModel mode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale Mode'),
        content: Text(
          'Are you sure you want to delete "${mode.saleModeName}"?',
          style: AppTextStyle.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              productSaleModeBloc.add(
                DeleteProductSaleMode(id: mode.id.toString()),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBulkConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: SizedBox(
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.9
                : MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.5,
            child: ProductSaleModeConfigScreen(productId: widget.productId),
          ),
        ),
      ),
    );
  }
}
