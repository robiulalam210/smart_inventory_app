import 'package:smart_inventory/feature/products/unit/data/model/unit_model.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../brand/data/model/brand_model.dart';
import '../../../brand/presentation/bloc/brand/brand_bloc.dart';
import '../../../categories/data/model/categories_model.dart';
import '../../../categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../unit/presentation/bloc/unit/unti_bloc.dart';
import '../bloc/products/products_bloc.dart';

class ProductsForm extends StatefulWidget {
  final bool isDialog;
  const ProductsForm({super.key, this.isDialog = false});

  @override
  State<ProductsForm> createState() => _ProductsFormState();
}

class _ProductsFormState extends State<ProductsForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ProductsBloc productsBloc;
  late CategoriesBloc categoriesBloc;
  late UnitBloc unitBloc;
  late BrandBloc brandBloc;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Initialize BLoCs here where context is available
      productsBloc = context.read<ProductsBloc>();
      categoriesBloc = context.read<CategoriesBloc>();
      unitBloc = context.read<UnitBloc>();
      brandBloc = context.read<BrandBloc>();

      _initializeData();
      _isInitialized = true;
    }
  }

  void _initializeData() {
    // Initialize controllers with default values
    productsBloc.productSellingPriceController = TextEditingController(text: "0");
    productsBloc.productPurchasePriceController = TextEditingController(text: "0");
    productsBloc.productOpeningStockController = TextEditingController(text: "0");
    productsBloc.productAlertQuantityController = TextEditingController(text: "5");
    productsBloc.productNameController = TextEditingController();
    productsBloc.productBarCodeController = TextEditingController();
    productsBloc.productDescriptionController = TextEditingController();

    // Fetch initial data
    categoriesBloc.add(FetchCategoriesList(context));
    brandBloc.add(FetchBrandList(context));
    unitBloc.add(FetchUnitList(context));
  }

  @override
  void dispose() {
    productsBloc.productSellingPriceController.dispose();
    productsBloc.productPurchasePriceController.dispose();
    productsBloc.productAlertQuantityController.dispose();
    productsBloc.productOpeningStockController.dispose();
    productsBloc.productNameController.dispose();
    productsBloc.productBarCodeController.dispose();
    productsBloc.productDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized yet, show loading
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isDialog) {
      return _buildDialogContent();
    }

    return SafeArea(child: _buildMainContent());
  }

  Widget _buildDialogContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Create New Product",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              child: BlocListener<ProductsBloc, ProductsState>(
                listener: (context, state) {
                  _handleProductState(state);
                },
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildProductNameField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildUnitDropdown()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildBrandDropdown()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildPurchasePriceField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSellingPriceField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildOpeningStockField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildAlertQuantityField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBarcodeField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          name: "Create Product",
                          onPressed: _createProduct,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen)
          ResponsiveCol(
            xs: 0,
            sm: 1,
            md: 1,
            lg: 2,
            xl: 2,
            child: Container(
              decoration: BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
            ),
          ),
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: BlocListener<ProductsBloc, ProductsState>(
              listener: (context, state) {
                _handleProductState(state);
              },
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create New Product",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main form fields in ResponsiveRow
                    ResponsiveRow(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // Category Dropdown
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: _buildCategoryDropdown(),
                        ),

                        // Product Name
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: _buildProductNameField(),
                        ),

                        // Unit Dropdown
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 4,
                          lg: 4,
                          xl: 4,
                          child: _buildUnitDropdown(),
                        ),

                        // Brand Dropdown
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 4,
                          lg: 4,
                          xl: 4,
                          child: _buildBrandDropdown(),
                        ),

                        // Barcode Field
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 4,
                          lg: 4,
                          xl: 4,
                          child: _buildBarcodeField(),
                        ),

                        // Purchase Price
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: _buildPurchasePriceField(),
                        ),

                        // Selling Price
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: _buildSellingPriceField(),
                        ),

                        // Opening Stock
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: _buildOpeningStockField(),
                        ),

                        // Alert Quantity
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: _buildAlertQuantityField(),
                        ),

                        // Description Field (Full Width)
                        ResponsiveCol(
                          xs: 12,
                          sm: 12,
                          md: 12,
                          lg: 12,
                          xl: 12,
                          child: _buildDescriptionField(),
                        ),

                        // Submit Button
                        ResponsiveCol(
                          xs: 12,
                          sm: 12,
                          md: 12,
                          lg: 12,
                          xl: 12,
                          child: _buildSubmitButton(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleProductState(ProductsState state) {
    if (state is ProductsAddLoading) {
      appLoader(context, "Creating Product, please wait...");
    } else if (state is ProductsAddSuccess) {
      Navigator.pop(context); // Close loader dialog

      context.read<ProductsBloc>().add(
          FetchProductsList(
            context,

            pageNumber: 1,
            pageSize: 20,
          ),);

      context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 7));

      // Navigate back or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully!')),
      );
      // Close dialog if in dialog mode
      if (widget.isDialog) {
        Navigator.pop(context);
      }
    } else if (state is ProductsAddFailed) {
      Navigator.pop(context); // Close loader dialog
      appAlertDialog(context, state.content,
          title: state.title,
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Dismiss"))
          ]);
    }
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final selectedCategory = categoriesBloc.selectedState;
        final categoryList = categoriesBloc.list;

        return AppDropdown(
          label: "Category *",
          context: context,
          hint: selectedCategory.isEmpty ? "Select Category" : selectedCategory,
          isLabel: true,
          isNeedAll: false,
          isRequired: true,
          isSearch: true,
          value: selectedCategory.isEmpty ? null : selectedCategory,
          itemList: categoryList,
          onChanged: (newVal) {
            setState(() {
              categoriesBloc.selectedState = newVal.toString();
              // Find and set the category ID
              final matchingCategory = categoryList.firstWhere(
                    (category) => category.name.toString() == newVal.toString(),
                orElse: () => CategoryModel(),
              );
              categoriesBloc.selectedStateId = matchingCategory.id?.toString() ?? "";
            });
          },
          validator: (value) {
            return value == null ? 'Please select Category' : null;
          },
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toString(),
              style: const TextStyle(
                color: AppColors.blackColor,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitDropdown() {
    return BlocBuilder<UnitBloc, UnitState>(
      builder: (context, state) {
        final selectedUnit = unitBloc.selectedState;
        final unitList = unitBloc.list;

        return AppDropdown(
          context: context,
          label: "Unit *",
          hint: selectedUnit.isEmpty ? "Select Unit" : selectedUnit,
          isRequired: true,
          isSearch: true,
          isNeedAll: false,
          value: selectedUnit.isEmpty ? null : selectedUnit,
          itemList: unitList,
          onChanged: (newVal) {
            setState(() {
              unitBloc.selectedState = newVal.toString();
              // Find and set the unit ID
              final matchingUnit = unitList.firstWhere(
                    (unit) => unit.name.toString() == newVal.toString(),
                orElse: () => UnitsModel(),
              );
              unitBloc.selectedIdState = matchingUnit.id?.toString() ?? "";
            });
          },
          validator: (value) {
            return value == null ? 'Please select Unit' : null;
          },
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toString(),
              style: const TextStyle(
                color: AppColors.blackColor,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandDropdown() {
    return BlocBuilder<BrandBloc, BrandState>(
      builder: (context, state) {
        final selectedBrand = brandBloc.selectedState;
        final brandList = brandBloc.brandModel;

        return AppDropdown(
          label: "Brand",
          context: context,
          hint: selectedBrand.isEmpty ? "Select Brand" : selectedBrand,
          isLabel: true,
          isNeedAll: false,
          isSearch: true,
          isRequired: false,
          value: selectedBrand.isEmpty ? null : selectedBrand,
          itemList: brandList,
          onChanged: (newVal) {
            setState(() {
              brandBloc.selectedState = newVal.toString();
              // Find and set the brand ID
              final matchingBrand = brandList.firstWhere(
                    (brand) => brand.name.toString() == newVal.toString(),
                orElse: () => BrandModel(),
              );
              brandBloc.selectedId = matchingBrand.id?.toString() ?? "";
            });
          },
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toString(),
              style: const TextStyle(
                color: AppColors.blackColor,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductNameField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: true,
      controller: productsBloc.productNameController,
      hintText: 'Product Name',
      labelText: 'Product Name *',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      keyboardType: TextInputType.text,
      validator: (value) {
        return value!.isEmpty ? 'Please enter Product Name' : null;
      },
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildPurchasePriceField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productPurchasePriceController,
      labelText: 'Purchase Price',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      keyboardType: TextInputType.number,
      hintText: '0.00',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildSellingPriceField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productSellingPriceController,
      labelText: 'Selling Price',
      hintText: '0.00',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildOpeningStockField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productOpeningStockController,
      labelText: 'Opening Stock',
      hintText: '0',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildAlertQuantityField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productAlertQuantityController,
      labelText: 'Alert Quantity',
      hintText: '5',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildBarcodeField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productBarCodeController,
      labelText: 'Product Barcode',
      hintText: 'Product Barcode',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildDescriptionField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productDescriptionController,
      labelText: 'Product Description',
      hintText: 'Product Description',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      keyboardType: TextInputType.multiline,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AppButton(
        name: "Create Product",
        onPressed: _createProduct,
      ),
    );
  }

  void _createProduct() {
    if (!formKey.currentState!.validate()) return;

    // Validate required fields
    if (categoriesBloc.selectedStateId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (unitBloc.selectedIdState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a unit')),
      );
      return;
    }

    if (productsBloc.productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    Map<String, String> body = {
      "category": categoriesBloc.selectedStateId,
      "unit": unitBloc.selectedIdState,
      "name": productsBloc.productNameController.text,
    };

    // Add optional fields if they have values
    if (brandBloc.selectedId.isNotEmpty) {
      body["brand"] = brandBloc.selectedId;
    }

    if (productsBloc.productSellingPriceController.text.isNotEmpty &&
        productsBloc.productSellingPriceController.text != "0") {
      body["selling_price"] = productsBloc.productSellingPriceController.text;
    }

    if (productsBloc.productPurchasePriceController.text.isNotEmpty &&
        productsBloc.productPurchasePriceController.text != "0") {
      body["purchase_price"] = productsBloc.productPurchasePriceController.text;
    }

    if (productsBloc.productDescriptionController.text.isNotEmpty) {
      body["description"] = productsBloc.productDescriptionController.text;
    }

    if (productsBloc.productOpeningStockController.text.isNotEmpty &&
        productsBloc.productOpeningStockController.text != "0") {
      body["opening_stock"] = productsBloc.productOpeningStockController.text;
    }

    if (productsBloc.productAlertQuantityController.text.isNotEmpty &&
        productsBloc.productAlertQuantityController.text != "5") {
      body["alert_quantity"] = productsBloc.productAlertQuantityController.text;
    }

    if (productsBloc.productBarCodeController.text.isNotEmpty) {
      body["bar_code"] = productsBloc.productBarCodeController.text;
    }

    // Add product
    productsBloc.add(AddProducts(
      body: body,
    ));
  }
}