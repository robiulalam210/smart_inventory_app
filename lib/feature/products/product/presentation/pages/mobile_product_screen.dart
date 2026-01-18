import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../brand/data/model/brand_model.dart';
import '../../../brand/presentation/bloc/brand/brand_bloc.dart';
import '../../../categories/data/model/categories_model.dart';
import '../../../categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../groups/data/model/groups.dart';
import '../../../groups/presentation/bloc/groups/groups_bloc.dart';
import '../../../soruce/data/model/source_model.dart';
import '../../../soruce/presentation/bloc/source/source_bloc.dart';
import '../../../unit/data/model/unit_model.dart';
import '../../../unit/presentation/bloc/unit/unti_bloc.dart';
import '../../data/model/product_model.dart';
import '../bloc/products/products_bloc.dart';
import '../widget/pagination.dart';
import '../widget/widget.dart';
import 'mobile_product_create.dart';

class MobileProductScreen extends StatefulWidget {
  const MobileProductScreen({super.key});

  @override
  State<MobileProductScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<MobileProductScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize blocs
      context.read<CategoriesBloc>().add(FetchCategoriesList(context));
      context.read<BrandBloc>().add(FetchBrandList(context));
      context.read<UnitBloc>().add(FetchUnitList(context));
      context.read<SourceBloc>().add(FetchSourceList(context));
      context.read<GroupsBloc>().add(FetchGroupsList(context));

      final productsBloc = context.read<ProductsBloc>();
      productsBloc.filterTextController.clear();

      _fetchProductList(pageNumber: 1);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProductList({
    String filterText = '',
    String state = '',
    String category = '',
    String brand = '',
    String unit = '',
    String group = '',
    String source = '',
    String minPrice = '',
    String maxPrice = '',
    String minStock = '',
    String maxStock = '',
    String productName = '',
    String sku = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<ProductsBloc>().add(
      FetchProductsList(
        context,
        filterText: filterText,
        category: category,
        state: state,
        brand: brand,
        unit: unit,
        group: group,
        source: source,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minStock: minStock,
        maxStock: maxStock,
        productName: productName,
        sku: sku,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text("Product", style: AppTextStyle.titleMedium(context)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showCreateProductBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: RefreshIndicator(
            color: AppColors.primaryColor(context),
            onRefresh: () async {
              _fetchProductList();
            },
            child: Container(
              padding: AppTextStyle.getResponsivePaddingBody(context),
              child: BlocConsumer<ProductsBloc, ProductsState>(
                listener: (context, state) {
                  _handleBlocState(state);
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMobileHeader(),
                        const SizedBox(height: 8),
                        SizedBox(child: _buildProductList(state)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBlocState(ProductsState state) {
    if (state is ProductsDeleteLoading) {
      appLoader(context, "Deleting product, please wait...");
    } else if (state is ProductsDeleteSuccess) {
      if (context.mounted) {
        Navigator.pop(context);
        showCustomToast(
          context: context,
          title: 'Success!',
          description: state.message,
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
        _fetchProductList();
      }
    } else if (state is ProductsDeleteFailed) {
      if (context.mounted) {
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
    }
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomSearchTextFormField(
                    controller: context.read<ProductsBloc>().filterTextController,
                    onChanged: (value) {
                      _fetchProductList(filterText: value);
                    },
                    isRequiredLabel: false,
                    onClear: () {
                      context.read<ProductsBloc>().filterTextController.clear();
                      _fetchProductList();
                    },
                    hintText: "products...",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.filter,
                  color: AppColors.primaryColor(context),
                ),
                onPressed: () => _showMobileFilterSheet(context),
              ),
            ],
          ),
        ),
        // Filter indicator (optional)
        BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsListSuccess && _hasActiveFilters()) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, size: 16, color: AppColors.primaryColor(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Filters Applied',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Clear all filters
                        context.read<ProductsBloc>().filterTextController.clear();
                        _fetchProductList();
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.errorColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    final productsBloc = context.read<ProductsBloc>();
    final hasSearchText = productsBloc.filterTextController.text.isNotEmpty;
    // Add more filter checks as needed
    return hasSearchText;
  }

  Widget _buildProductList(ProductsState state) {
    if (state is ProductsListLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is ProductsListSuccess) {
      if (state.list.isEmpty) {
        return Center(
          child: Lottie.asset(AppImages.noData),
        );
      } else {
        return Column(
          children: [
            SizedBox(
              child: ProductDataTableWidget(
                products: state.list,
                onEdit: (v) => _showEditBottomSheet(context, v),
                onDelete: (v) async {
                  final shouldDelete = await showDeleteConfirmationDialog(context);
                  if (!shouldDelete) return;

                  if (context.mounted) {
                    context.read<ProductsBloc>().add(
                      DeleteProducts(id: v.id.toString()),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            PaginationBar(
              count: state.count,
              totalPages: state.totalPages,
              currentPage: state.currentPage,
              pageSize: state.pageSize,
              from: state.from,
              to: state.to,
              onPageChanged: (page) {
                _fetchProductList(pageNumber: page, pageSize: state.pageSize);
              },
              onPageSizeChanged: (newPageSize) {
                _fetchProductList(pageNumber: 1, pageSize: newPageSize);
              },
            ),
          ],
        );
      }
    } else if (state is ProductsListFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.content,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(name: "Retry", onPressed: () => _fetchProductList()),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  void _showCreateProductBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final height = AppSizes.height(context) * 0.9;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const MobileProductCreate(),
          ),
        );
      },
    );
  }

  void _showEditBottomSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final height = AppSizes.height(context) * 0.9;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: MobileProductCreate(
              productId: product.id.toString(),
              product: product,
            ),
          ),
        );
      },
    );
  }

  void _showMobileFilterSheet(BuildContext context) {
    // Store current filter values
    String? selectedCategory = '';
    String? selectedStatus = '';
    String? minPrice = '';
    String? maxPrice = '';
    String? minStock = '';
    String? maxStock = '';
    String? selectedBrand = '';
    String? selectedUnit = '';
    String? selectedGroup = '';
    String? selectedSource = '';
    String? productName = '';
    String? sku = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                color: AppColors.bottomNavBg(context),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter Products",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor(context),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Clear all filters
                                  setState(() {
                                    selectedCategory = '';
                                    selectedStatus = '';
                                    minPrice = '';
                                    maxPrice = '';
                                    minStock = '';
                                    maxStock = '';
                                    selectedBrand = '';
                                    selectedUnit = '';
                                    selectedGroup = '';
                                    selectedSource = '';
                                    productName = '';
                                    sku = '';
                                  });
                                },
                                child: Text(
                                  "Clear All",
                                  style: TextStyle(
                                    color: AppColors.errorColor(context),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),

                      // Filter options
                      _buildFilterSection(
                        title: "Basic Filters",
                        children: [
                          // Product Name
                          _buildTextFieldFilter(
                            "Product Name",
                            productName,
                                (value) => setState(() => productName = value),
                            hintText: "Enter product name",
                          ),
                          const SizedBox(height: 10),

                          // SKU
                          _buildTextFieldFilter(
                            "SKU/Barcode",
                            sku,
                                (value) => setState(() => sku = value),
                            hintText: "Enter SKU or barcode",
                          ),
                          const SizedBox(height: 10),

                          // Category Dropdown
                          BlocBuilder<CategoriesBloc, CategoriesState>(
                            builder: (context, state) {
                              final categories = context.read<CategoriesBloc>().list;
                              return _buildDropdownFilter(
                                "Category",
                                selectedCategory,
                                categories.map((c) => c.name ?? "").toList(),
                                    (value) => setState(() => selectedCategory = value),
                                includeEmpty: true,
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Status Dropdown
                          _buildDropdownFilter(
                            "Status",
                            selectedStatus,
                            ["All", "Active", "Inactive"],
                                (value) => setState(() => selectedStatus = value),
                            includeEmpty: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Price Range
                      _buildFilterSection(
                        title: "Price Range",
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextFieldFilter(
                                  "Min Price",
                                  minPrice,
                                      (value) => setState(() => minPrice = value),
                                  hintText: "Min",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text("-", style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextFieldFilter(
                                  "Max Price",
                                  maxPrice,
                                      (value) => setState(() => maxPrice = value),
                                  hintText: "Max",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stock Range
                      _buildFilterSection(
                        title: "Stock Range",
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextFieldFilter(
                                  "Min Stock",
                                  minStock,
                                      (value) => setState(() => minStock = value),
                                  hintText: "Min",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text("-", style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextFieldFilter(
                                  "Max Stock",
                                  maxStock,
                                      (value) => setState(() => maxStock = value),
                                  hintText: "Max",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Advanced Filters (Collapsible)
                      ExpansionTile(
                        title: Text(
                          "Advanced Filters",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor(context),
                          ),
                        ),
                        children: [
                          const SizedBox(height: 10),

                          // Brand Dropdown
                          BlocBuilder<BrandBloc, BrandState>(
                            builder: (context, state) {
                              final brands = context.read<BrandBloc>().brandModel;
                              return _buildDropdownFilter(
                                "Brand",
                                selectedBrand,
                                brands.map((b) => b.name ?? "").toList(),
                                    (value) => setState(() => selectedBrand = value),
                                includeEmpty: true,
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Unit Dropdown
                          BlocBuilder<UnitBloc, UnitState>(
                            builder: (context, state) {
                              final units = context.read<UnitBloc>().list;
                              return _buildDropdownFilter(
                                "Unit",
                                selectedUnit,
                                units.map((u) => u.name ?? "").toList(),
                                    (value) => setState(() => selectedUnit = value),
                                includeEmpty: true,
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Group Dropdown
                          BlocBuilder<GroupsBloc, GroupsState>(
                            builder: (context, state) {
                              final groups = context.read<GroupsBloc>().list;
                              return _buildDropdownFilter(
                                "Group",
                                selectedGroup,
                                groups.map((g) => g.name ?? "").toList(),
                                    (value) => setState(() => selectedGroup = value),
                                includeEmpty: true,
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // Source Dropdown
                          BlocBuilder<SourceBloc, SourceState>(
                            builder: (context, state) {
                              final sources = context.read<SourceBloc>().list;
                              return _buildDropdownFilter(
                                "Source",
                                selectedSource,
                                sources.map((s) => s.name ?? "").toList(),
                                    (value) => setState(() => selectedSource = value),
                                includeEmpty: true,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              name: "Cancel",
                              isOutlined: true,
                              onPressed: () => Navigator.pop(context),
                              color: Colors.grey,
                              textColor: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              name: "Apply Filters",
                              onPressed: () {
                                // Prepare filter parameters
                                final Map<String, String> filters = {};

                                if (selectedCategory != null &&
                                    selectedCategory!.isNotEmpty &&
                                    selectedCategory != 'All') {
                                  // Find category ID
                                  final categories = context.read<CategoriesBloc>().list;
                                  final category = categories.firstWhere(
                                        (c) => c.name == selectedCategory,
                                    orElse: () => CategoryModel(),
                                  );
                                  if (category.id != null) {
                                    filters['category'] = category.id.toString();
                                  }
                                }

                                if (selectedStatus != null &&
                                    selectedStatus!.isNotEmpty &&
                                    selectedStatus != 'All') {
                                  filters['state'] = selectedStatus!;
                                }

                                if (productName != null && productName!.isNotEmpty) {
                                  filters['productName'] = productName!;
                                }

                                if (sku != null && sku!.isNotEmpty) {
                                  filters['sku'] = sku!;
                                }

                                if (minPrice != null && minPrice!.isNotEmpty) {
                                  filters['minPrice'] = minPrice!;
                                }

                                if (maxPrice != null && maxPrice!.isNotEmpty) {
                                  filters['maxPrice'] = maxPrice!;
                                }

                                if (minStock != null && minStock!.isNotEmpty) {
                                  filters['minStock'] = minStock!;
                                }

                                if (maxStock != null && maxStock!.isNotEmpty) {
                                  filters['maxStock'] = maxStock!;
                                }

                                // Advanced filters
                                if (selectedBrand != null &&
                                    selectedBrand!.isNotEmpty &&
                                    selectedBrand != 'All') {
                                  final brands = context.read<BrandBloc>().brandModel;
                                  final brand = brands.firstWhere(
                                        (b) => b.name == selectedBrand,
                                    orElse: () => BrandModel(),
                                  );
                                  if (brand.id != null) {
                                    filters['brand'] = brand.id.toString();
                                  }
                                }

                                if (selectedUnit != null &&
                                    selectedUnit!.isNotEmpty &&
                                    selectedUnit != 'All') {
                                  final units = context.read<UnitBloc>().list;
                                  final unit = units.firstWhere(
                                        (u) => u.name == selectedUnit,
                                    orElse: () => UnitsModel(),
                                  );
                                  if (unit.id != null) {
                                    filters['unit'] = unit.id.toString();
                                  }
                                }

                                if (selectedGroup != null &&
                                    selectedGroup!.isNotEmpty &&
                                    selectedGroup != 'All') {
                                  final groups = context.read<GroupsBloc>().list;
                                  final group = groups.firstWhere(
                                        (g) => g.name == selectedGroup,
                                    orElse: () => GroupsModel(),
                                  );
                                  if (group.id != null) {
                                    filters['group'] = group.id.toString();
                                  }
                                }

                                if (selectedSource != null &&
                                    selectedSource!.isNotEmpty &&
                                    selectedSource != 'All') {
                                  final sources = context.read<SourceBloc>().list;
                                  final source = sources.firstWhere(
                                        (s) => s.name == selectedSource,
                                    orElse: () => SourceModel(),
                                  );
                                  if (source.id != null) {
                                    filters['source'] = source.id.toString();
                                  }
                                }

                                // Close bottom sheet
                                Navigator.pop(context);

                                // Apply filters
                                _applyFilters(filters);
                              },
                            ),
                          ),
                          SizedBox(height: 20,)
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
    );
  }

  // Helper method to build filter sections
  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.text(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  // Helper method to build text field filters
  Widget _buildTextFieldFilter(
      String label,
      String? value,
      Function(String) onChanged, {
        String hintText = '',
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: TextEditingController(text: value ?? ''),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: value != null && value.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onChanged(''),
              )
                  : null,
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Helper method to build dropdown filters
  Widget _buildDropdownFilter(
      String label,
      String? selectedValue,
      List<String> options,
      Function(String?) onChanged, {
        bool includeEmpty = true,
      }) {
    List<String> allOptions = includeEmpty ? ['All', ...options] : options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue?.isEmpty ?? true
                  ? (includeEmpty ? 'All' : null)
                  : selectedValue,
              isExpanded: true,
              items: allOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option.isEmpty ? null : option,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      option.isEmpty ? 'All' : option,
                      style: AppTextStyle.body(context),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Select $label',
                  style: AppTextStyle.body(context),
                ),
              ),
              style: AppTextStyle.body(context),
            ),
          ),
        ),
      ],
    );
  }

  // Method to apply filters
  void _applyFilters(Map<String, String> filters) {
    // Get current search text
    final searchText = context.read<ProductsBloc>().filterTextController.text;

    // Apply all filters
    _fetchProductList(
      filterText: searchText,
      category: filters['category'] ?? '',
      state: filters['state'] ?? '',
      brand: filters['brand'] ?? '',
      unit: filters['unit'] ?? '',
      group: filters['group'] ?? '',
      source: filters['source'] ?? '',
      minPrice: filters['minPrice'] ?? '',
      maxPrice: filters['maxPrice'] ?? '',
      minStock: filters['minStock'] ?? '',
      maxStock: filters['maxStock'] ?? '',
      productName: filters['productName'] ?? '',
      sku: filters['sku'] ?? '',
      pageNumber: 1,
    );
  }
}