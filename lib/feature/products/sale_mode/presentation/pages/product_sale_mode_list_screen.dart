// features/products/sale_mode/presentation/screens/product_sale_mode_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_scaffold.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/product_sale_mode/product_sale_mode_bloc.dart';

import '../bloc/sale_mode_bloc.dart';
import 'product_sale_mode_config_screen.dart';
import 'widgets/product_sale_mode_table_card.dart';

class ProductSaleModeListScreen extends StatefulWidget {
  final String productId;
  final String? productName;

  const ProductSaleModeListScreen({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  State<ProductSaleModeListScreen> createState() => _ProductSaleModeListScreenState();
}

class _ProductSaleModeListScreenState extends State<ProductSaleModeListScreen> {
  late var productSaleModeBloc = context.read<ProductSaleModeBloc>();
  late var saleModeBloc = context.read<SaleModeBloc>();

  @override
  void initState() {
    _fetchApi();
    context.read<SaleModeBloc>().add(
      FetchSaleModeList(
        context,

      ),
    );
    super.initState();
  }

  void _fetchApi({String filterText = '', int pageNumber = 0}) {
    context.read<ProductSaleModeBloc>().add(
      FetchProductSaleModeList(
        context,
        productId: widget.productId,
        filterText: filterText,
        pageNumber: pageNumber,
      ),
    );
  }

  void _fetchAvailableSaleModes() {
    context.read<ProductSaleModeBloc>().add(
      FetchAvailableSaleModes(
        context,
        productId: widget.productId,
      ),
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
              _fetchApi();
              _fetchAvailableSaleModes();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showBulkConfigDialog(context),
        child: const Icon(Icons.settings),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchApi();
            _fetchAvailableSaleModes();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductSaleModeBloc, ProductSaleModeState>(
          listener: (context, state) {
            if (state is ProductSaleModeAddLoading) {
              appLoader(context, "Configuring sale mode, please wait...");
            } else if (state is ProductSaleModeDeleteLoading) {
              appLoader(context, "Deleting configuration, please wait...");
            } else if (state is ProductSaleModeBulkUpdateLoading) {
              appLoader(context, "Updating configurations, please wait...");
            } else if (state is ProductSaleModeAddSuccess) {
              Navigator.pop(context);
              _fetchApi();
              showCustomToast(
                context: context,
                title: 'Success!',
                description: 'Sale mode configured successfully',
                icon: Icons.check_circle,
                primaryColor: Colors.green,
              );
            } else if (state is ProductSaleModeDeleteSuccess) {
              showCustomToast(
                context: context,
                title: 'Success!',
                description: state.message,
                icon: Icons.check_circle,
                primaryColor: Colors.green,
              );
              Navigator.pop(context);
              _fetchApi();
            } else if (state is ProductSaleModeBulkUpdateSuccess) {
              Navigator.pop(context);
              _fetchApi();
              showCustomToast(
                context: context,
                title: 'Success!',
                description: 'Sale modes updated successfully',
                icon: Icons.check_circle,
                primaryColor: Colors.green,
              );
            } else if (state is ProductSaleModeAddFailed) {
              Navigator.pop(context);
              appAlertDialog(
                context,
                state.content,
                title: state.title,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Dismiss"),
                  ),
                ],
              );
            }
          },
        ),
      ],
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          _buildAvailableModesSection(),
          const SizedBox(height: 16),
          _buildConfiguredModesList(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomSearchTextFormField(
          controller: productSaleModeBloc.filterTextController,
          onClear: () {
            productSaleModeBloc.filterTextController.clear();
            _fetchApi();
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            _fetchApi(filterText: value);
          },
          hintText: "Search configured sale modes...",
          isRequiredLabel: false,
        ),
      ],
    );
  }

  Widget _buildAvailableModesSection() {
    return BlocBuilder<ProductSaleModeBloc, ProductSaleModeState>(
      builder: (context, state) {
        if (state is AvailableSaleModesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AvailableSaleModesSuccess) {
          final availableModes = state.availableModes;
          if (availableModes.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.greyColor(context)),
              ),
              child: const Text(
                "No sale modes available for this product's unit",
                textAlign: TextAlign.center,
              ),
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
                    final isConfigured = mode['configured'] == true;
                    final isActive = mode['is_active'] == true;

                    return Chip(
                      label: Text(mode['name'] ?? ''),
                      backgroundColor: isConfigured
                          ? (isActive ? Colors.green[100] : Colors.grey[300])
                          : Colors.blue[100],
                      labelStyle: TextStyle(
                        color: isConfigured
                            ? (isActive ? Colors.green[900] : Colors.grey[700])
                            : Colors.blue[900],
                        fontWeight: isConfigured ? FontWeight.bold : FontWeight.normal,
                      ),
                      avatar: isConfigured
                          ? Icon(
                        isActive ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isActive ? Colors.green : Colors.grey,
                      )
                          : const Icon(Icons.add_circle, size: 16, color: Colors.blue),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        } else if (state is AvailableSaleModesFailed) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.errorColor(context)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Failed to load available modes: ${state.content}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildConfiguredModesList() {
    return BlocBuilder<ProductSaleModeBloc, ProductSaleModeState>(
      builder: (context, state) {
        if (state is ProductSaleModeListLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ProductSaleModeListSuccess) {
          if (state.list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset(AppImages.noData, width: 150, height: 150),
                    const SizedBox(height: 16),
                    const Text(
                      'No sale modes configured for this product',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchAvailableSaleModes,
                      child: const Text('View Available Modes'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ProductSaleModeTableCard(
              productSaleModes: state.list,
              onRefresh: _fetchApi,
            );
          }
        } else if (state is ProductSaleModeListFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Failed to load: ${state.content}'),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _showBulkConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: SizedBox(
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.7,
              child: ProductSaleModeConfigScreen(productId: widget.productId),
            ),
          ),
        );
      },
    );
  }
}