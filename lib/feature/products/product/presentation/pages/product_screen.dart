
import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
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
import 'product_create.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter state variables
  String _selectedCategory = '';
  String _selectedStatus = '';
  String _selectedBrand = '';
  String _selectedUnit = '';
  String _selectedGroup = '';
  String _selectedSource = '';
  String _minPrice = '';
  String _maxPrice = '';
  String _minStock = '';
  String _maxStock = '';
  String _productName = '';
  String _sku = '';

  // Filter drawer state
  bool _showFilterDrawer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsBloc = context.read<ProductsBloc>();
      productsBloc.filterTextController.clear();

      // Initialize all blocs
      context.read<CategoriesBloc>().add(FetchCategoriesList(context));
      context.read<BrandBloc>().add(FetchBrandList(context));
      context.read<UnitBloc>().add(FetchUnitList(context));
      context.read<GroupsBloc>().add(FetchGroupsList(context));
      context.read<SourceBloc>().add(FetchSourceList(context));

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
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: Row(
          children: [
            // Sidebar (if big screen)
            if (isBigScreen)
              Container(
                width: 250,
                decoration: const BoxDecoration(color: Colors.white),
                child: const Sidebar(),
              ),

            // Main content area
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor(context),
                onRefresh: () async {
                  _fetchProductList();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDesktopHeader(isBigScreen),
                      if (_hasActiveFilters()) _buildActiveFiltersIndicator(),
                      const SizedBox(height: 16),
                      SizedBox(
                        child: BlocConsumer<ProductsBloc, ProductsState>(
                          listener: (context, state) {
                            _handleBlocState(state);
                          },
                          builder: (context, state) {
                            return _buildProductList(state);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter drawer (animated)
            // if (isBigScreen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _showFilterDrawer ? 300 : 0,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                boxShadow: [
                  if (_showFilterDrawer)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(-3, 0),
                    ),
                ],
              ),
              child: _showFilterDrawer
                  ? _buildFilterPanel()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBlocState(ProductsState state) {
    if (state is ProductsDeleteLoading) {
      appLoader(context, "Deleting product, please wait...");
    } else if (state is ProductsDeleteSuccess) {
      if (context.mounted) {
        showCustomToast(
          context: context,
          title: 'Success!',
          description: state.message,
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
        Navigator.pop(context);
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

  Widget _buildDesktopHeader(bool isBigScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 400,
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
        const SizedBox(width: 16),
        Row(
          children: [
            // Filter Toggle Button
            IconButton(
              icon: Icon(
                Icons.filter_alt,
                color: _showFilterDrawer
                    ? AppColors.primaryColor(context)
                    : Colors.grey,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _showFilterDrawer = !_showFilterDrawer;
                });
              },
              tooltip: 'Toggle Filters',
            ),
            const SizedBox(width: 8),
            AppButton(
              name: "Create Product",
              onPressed: () => _showCreateProductDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveFiltersIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: AppColors.primaryColor(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _getActiveFilterChips(),
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
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

  List<Widget> _getActiveFilterChips() {
    final List<Widget> chips = [];

    if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
      chips.add(
        _buildFilterChip('Category: $_selectedCategory', () {
          setState(() => _selectedCategory = '');
          _applyFilters();
        }),
      );
    }

    if (_selectedStatus.isNotEmpty && _selectedStatus != 'All') {
      chips.add(
        _buildFilterChip('Status: $_selectedStatus', () {
          setState(() => _selectedStatus = '');
          _applyFilters();
        }),
      );
    }

    if (_selectedBrand.isNotEmpty && _selectedBrand != 'All') {
      chips.add(
        _buildFilterChip('Brand: $_selectedBrand', () {
          setState(() => _selectedBrand = '');
          _applyFilters();
        }),
      );
    }

    if (_minPrice.isNotEmpty) {
      chips.add(
        _buildFilterChip('Min Price: $_minPrice', () {
          setState(() => _minPrice = '');
          _applyFilters();
        }),
      );
    }

    if (_maxPrice.isNotEmpty) {
      chips.add(
        _buildFilterChip('Max Price: $_maxPrice', () {
          setState(() => _maxPrice = '');
          _applyFilters();
        }),
      );
    }

    if (_productName.isNotEmpty) {
      chips.add(
        _buildFilterChip('Name: $_productName', () {
          setState(() => _productName = '');
          _applyFilters();
        }),
      );
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primaryColor(context).withValues(alpha: 0.1),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory.isNotEmpty && _selectedCategory != 'All' ||
        _selectedStatus.isNotEmpty && _selectedStatus != 'All' ||
        _selectedBrand.isNotEmpty && _selectedBrand != 'All' ||
        _selectedUnit.isNotEmpty && _selectedUnit != 'All' ||
        _selectedGroup.isNotEmpty && _selectedGroup != 'All' ||
        _selectedSource.isNotEmpty && _selectedSource != 'All' ||
        _minPrice.isNotEmpty ||
        _maxPrice.isNotEmpty ||
        _minStock.isNotEmpty ||
        _maxStock.isNotEmpty ||
        _productName.isNotEmpty ||
        _sku.isNotEmpty;
  }

  Widget _buildFilterPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor(context),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showFilterDrawer = false;
                  });
                },
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Basic Filters
          _buildFilterSection(
            title: "Basic Filters",
            children: [
              _buildTextFieldFilter(
                "Product Name",
                _productName,
                (value) => setState(() => _productName = value),
                hintText: "Enter product name",
              ),
              const SizedBox(height: 6),

              _buildTextFieldFilter(
                "SKU/Barcode",
                _sku,
                (value) => setState(() => _sku = value),
                hintText: "Enter SKU or barcode",
              ),
              const SizedBox(height: 6),

              BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  final categories = context.read<CategoriesBloc>().list;
                  return _buildDropdownFilter(
                    "Category",
                    _selectedCategory,
                    categories.map((c) => c.name ?? "").toList(),
                    (value) => setState(() => _selectedCategory = value ?? ''),
                    includeEmpty: true,
                  );
                },
              ),
              const SizedBox(height: 6),

              _buildDropdownFilter(
                "Status",
                _selectedStatus,
                ["All", "Active", "Inactive"],
                (value) => setState(() => _selectedStatus = value ?? ''),
                includeEmpty: false,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Price Range
          _buildFilterSection(
            title: "Price Range",
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextFieldFilter(
                      "Min Price",
                      _minPrice,
                      (value) => setState(() => _minPrice = value),
                      hintText: "Min",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("-"),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextFieldFilter(
                      "Max Price",
                      _maxPrice,
                      (value) => setState(() => _maxPrice = value),
                      hintText: "Max",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Stock Range
          _buildFilterSection(
            title: "Stock Range",
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextFieldFilter(
                      "Min Stock",
                      _minStock,
                      (value) => setState(() => _minStock = value),
                      hintText: "Min",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("-"),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextFieldFilter(
                      "Max Stock",
                      _maxStock,
                      (value) => setState(() => _maxStock = value),
                      hintText: "Max",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Advanced Filters
          ExpansionTile(
            title: Text(
              "Advanced Filters",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor(context),
              ),
            ),
            children: [
              const SizedBox(height: 12),

              // Brand Dropdown
              BlocBuilder<BrandBloc, BrandState>(
                builder: (context, state) {
                  final brands = context.read<BrandBloc>().brandModel;
                  return _buildDropdownFilter(
                    "Brand",
                    _selectedBrand,
                    brands.map((b) => b.name ?? "").toList(),
                    (value) => setState(() => _selectedBrand = value ?? ''),
                    includeEmpty: true,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Unit Dropdown
              BlocBuilder<UnitBloc, UnitState>(
                builder: (context, state) {
                  final units = context.read<UnitBloc>().list;
                  return _buildDropdownFilter(
                    "Unit",
                    _selectedUnit,
                    units.map((u) => u.name ?? "").toList(),
                    (value) => setState(() => _selectedUnit = value ?? ''),
                    includeEmpty: true,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Group Dropdown
              BlocBuilder<GroupsBloc, GroupsState>(
                builder: (context, state) {
                  final groups = context.read<GroupsBloc>().list;
                  return _buildDropdownFilter(
                    "Group",
                    _selectedGroup,
                    groups.map((g) => g.name ?? "").toList(),
                    (value) => setState(() => _selectedGroup = value ?? ''),
                    includeEmpty: true,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Source Dropdown
              BlocBuilder<SourceBloc, SourceState>(
                builder: (context, state) {
                  final sources = context.read<SourceBloc>().list;
                  return _buildDropdownFilter(
                    "Source",
                    _selectedSource,
                    sources.map((s) => s.name ?? "").toList(),
                    (value) => setState(() => _selectedSource = value ?? ''),
                    includeEmpty: true,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),

          const SizedBox(height: 10),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  name: "Clear All",
                  isOutlined: true,
                  onPressed: _clearAllFilters,
                  color: Colors.grey,
                  textColor: AppColors.text(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  name: "Apply Filters",
                  onPressed: _applyFilters,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildTextFieldFilter(
      String label,
      String value,
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
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              ),
            ),
            textAlign: TextAlign.start,
            textDirection: TextDirection.ltr, // Force left-to-right for numbers
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: value.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  onChanged('');
                },
              )
                  : null,
            ),
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String selectedValue,
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
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          constraints: const BoxConstraints(minHeight: 35),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue.isEmpty
                  ? (includeEmpty ? 'All' : null)
                  : selectedValue,
              isExpanded: true,
              // This is important!
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
              ),
              items: allOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option.isEmpty ? null : option,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      option.isEmpty ? 'All' : option,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Select $label',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              dropdownColor: Colors.white,
              menuMaxHeight: 300,
            ),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    // Get current search text
    final searchText = context.read<ProductsBloc>().filterTextController.text;

    // Find IDs for selected values
    String categoryId = '';
    String brandId = '';
    String unitId = '';
    String groupId = '';
    String sourceId = '';

    if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
      final categories = context.read<CategoriesBloc>().list;
      final category = categories.firstWhere(
        (c) => c.name == _selectedCategory,
        orElse: () => CategoryModel(),
      );
      if (category.id != null) {
        categoryId = category.id.toString();
      }
    }

    if (_selectedBrand.isNotEmpty && _selectedBrand != 'All') {
      final brands = context.read<BrandBloc>().brandModel;
      final brand = brands.firstWhere(
        (b) => b.name == _selectedBrand,
        orElse: () => BrandModel(),
      );
      if (brand.id != null) {
        brandId = brand.id.toString();
      }
    }

    if (_selectedUnit.isNotEmpty && _selectedUnit != 'All') {
      final units = context.read<UnitBloc>().list;
      final unit = units.firstWhere(
        (u) => u.name == _selectedUnit,
        orElse: () => UnitsModel(),
      );
      if (unit.id != null) {
        unitId = unit.id.toString();
      }
    }

    if (_selectedGroup.isNotEmpty && _selectedGroup != 'All') {
      final groups = context.read<GroupsBloc>().list;
      final group = groups.firstWhere(
        (g) => g.name == _selectedGroup,
        orElse: () => GroupsModel(),
      );
      if (group.id != null) {
        groupId = group.id.toString();
      }
    }

    if (_selectedSource.isNotEmpty && _selectedSource != 'All') {
      final sources = context.read<SourceBloc>().list;
      final source = sources.firstWhere(
        (s) => s.name == _selectedSource,
        orElse: () => SourceModel(),
      );
      if (source.id != null) {
        sourceId = source.id.toString();
      }
    }

    // Apply filters
    _fetchProductList(
      filterText: searchText,
      category: categoryId,
      state: _selectedStatus == 'All' ? '' : _selectedStatus,
      brand: brandId,
      unit: unitId,
      group: groupId,
      source: sourceId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minStock: _minStock,
      maxStock: _maxStock,
      productName: _productName,
      sku: _sku,
      pageNumber: 1,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = '';
      _selectedStatus = '';
      _selectedBrand = '';
      _selectedUnit = '';
      _selectedGroup = '';
      _selectedSource = '';
      _minPrice = '';
      _maxPrice = '';
      _minStock = '';
      _maxStock = '';
      _productName = '';
      _sku = '';
    });

    // Clear search text and fetch without filters
    context.read<ProductsBloc>().filterTextController.clear();
    _fetchProductList();
  }

  Widget _buildProductList(ProductsState state) {
    if (state is ProductsListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProductsListSuccess) {
      if (state.list.isEmpty) {
        return Center(child: Lottie.asset(AppImages.noData));
      } else {
        return Column(
          children: [
            SizedBox(
              child: ProductDataTableWidget(
                products: state.list,
                onEdit: (v) => _showEditDialog(context, v, false),
                onDelete: (v) async {
                  final shouldDelete = await showDeleteConfirmationDialog(
                    context,
                  );
                  if (!shouldDelete) return;

                  if (context.mounted) {
                    context.read<ProductsBloc>().add(
                      DeleteProducts(id: v.id.toString()),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
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

  void _showCreateProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context)
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.6,
              maxHeight: Responsive.isMobile(context)
                  ? AppSizes.height(context) * 0.8
                  : 500,
            ),
            child: const ProductsForm(),
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    ProductModel product,
    bool isMobile,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.7,
              maxHeight: isMobile
                  ? AppSizes.height(context) * 0.9
                  : AppSizes.height(context) * 0.8,
            ),
            child: ProductsForm(
              productId: product.id.toString(),
              product: product,
            ),
          ),
        );
      },
    );
  }
}
