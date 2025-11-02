import 'package:smart_inventory/feature/products/brand/data/model/brand_model.dart';
import 'package:smart_inventory/feature/products/brand/presentation/bloc/brand/brand_bloc.dart';
import 'package:smart_inventory/feature/products/categories/data/model/categories_model.dart';
import 'package:smart_inventory/feature/products/categories/presentation/bloc/categories/categories_bloc.dart';
import 'package:smart_inventory/feature/products/unit/data/model/unit_model.dart';
import 'package:smart_inventory/feature/products/unit/presentation/bloc/unit/unti_bloc.dart';
import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../data/model/product_model.dart';
import '../bloc/products/products_bloc.dart';

class ProductsForm extends StatefulWidget {
  final bool isDialog;
  final ProductModel? product;
  final String? productId;

  const ProductsForm({
    super.key,
    this.isDialog = false,
    this.product,
    this.productId,
  });

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
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.product != null || widget.productId != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      productsBloc = context.read<ProductsBloc>();
      categoriesBloc = context.read<CategoriesBloc>();
      unitBloc = context.read<UnitBloc>();
      brandBloc = context.read<BrandBloc>();

      _initializeData();
      _isInitialized = true;
    }
  }

  void _initializeData() {
    // Clear existing data first
    _clearFormData();

    if (_isEditMode && widget.product != null) {
      _prefillFormData(widget.product!);
    }

    // Fetch initial data
    categoriesBloc.add(FetchCategoriesList(context));
    brandBloc.add(FetchBrandList(context));
    unitBloc.add(FetchUnitList(context));
  }

  void _clearFormData() {
    productsBloc.productNameController.clear();
    productsBloc.productBarCodeController.clear();
    productsBloc.productDescriptionController.clear();
    productsBloc.productPurchasePriceController.text = "0";
    productsBloc.productSellingPriceController.text = "0";
    productsBloc.productOpeningStockController.text = "0";
    productsBloc.productAlertQuantityController.text = "5";

    categoriesBloc.selectedState = "";
    categoriesBloc.selectedStateId = "";
    unitBloc.selectedState = "";
    unitBloc.selectedIdState = "";
    brandBloc.selectedState = "";
    brandBloc.selectedId = "";
  }

  void _prefillFormData(ProductModel product) {
    productsBloc.productNameController.text = product.name ?? "";
    // productsBloc.productBarCodeController.text = product.barCode ?? "";
    productsBloc.productDescriptionController.text = product.description ?? "";
    productsBloc.productPurchasePriceController.text = product.purchasePrice?.toString() ?? "0";
    productsBloc.productSellingPriceController.text = product.sellingPrice?.toString() ?? "0";
    productsBloc.productOpeningStockController.text = product.openingStock?.toString() ?? "0";
    productsBloc.productAlertQuantityController.text = product.alertQuantity?.toString() ?? "5";

    // Set selected category, unit, brand if available
    if (product.categoryInfo?.name != null) {
      categoriesBloc.selectedState = product.categoryInfo!.name!;
      categoriesBloc.selectedStateId = product.categoryInfo!.id?.toString() ?? "";
    }

    if (product.unitInfo?.name != null) {
      unitBloc.selectedState = product.unitInfo!.name!;
      unitBloc.selectedIdState = product.unitInfo!.id?.toString() ?? "";
    }

    if (product.brandInfo?.name != null) {
      brandBloc.selectedState = product.brandInfo!.name!;
      brandBloc.selectedId = product.brandInfo!.id?.toString() ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isDialog) {
      return _buildDialogContent();
    }

    return SafeArea(child: _buildMainContent());
  }

  Widget _buildDialogContent() {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditMode ? "Update Product" : "Create New Product",
                style: const TextStyle(
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
                          name: _isEditMode ? "Update Product" : "Create Product",
                          onPressed: _submitProduct,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (widget.isDialog)
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            name: "Cancel",
                            color: Colors.grey,
                            onPressed: () => Navigator.pop(context),
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
            child: BlocListener<ProductsBloc, ProductsState>(
              listener: (context, state) {
                _handleProductState(state);
              },
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? "Update Product" : "Create New Product",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ResponsiveRow(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 6, lg: 6, xl: 6,
                          child: _buildCategoryDropdown(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 6, lg: 6, xl: 6,
                          child: _buildProductNameField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 4, lg: 4, xl: 4,
                          child: _buildUnitDropdown(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 4, lg: 4, xl: 4,
                          child: _buildBrandDropdown(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 4, lg: 4, xl: 4,
                          child: _buildBarcodeField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 6, lg: 6, xl: 6,
                          child: _buildPurchasePriceField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 6, lg: 6, xl: 6,
                          child: _buildSellingPriceField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 6, lg: 6, xl: 6,
                          child: _buildOpeningStockField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 6, md: 6, lg: 6, xl: 6,
                          child: _buildAlertQuantityField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 12, md: 12, lg: 12, xl: 12,
                          child: _buildDescriptionField(),
                        ),
                        ResponsiveCol(
                          xs: 12, sm: 12, md: 12, lg: 12, xl: 12,
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
      appLoader(context, _isEditMode ? "Updating Product..." : "Creating Product, please wait...");
    } else if (state is ProductsAddSuccess) {
      Navigator.pop(context); // Close loader dialog

      // Refresh product list
      context.read<ProductsBloc>().add(
        FetchProductsList(context, pageNumber: 1, pageSize: 20),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Product updated successfully!' : 'Product created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Close dialog if in dialog mode
      if (widget.isDialog) {
        Navigator.pop(context);
      } else {
        context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 7));
      }
    } else if (state is ProductsAddFailed) {
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

  // ... (Keep all the _build methods as they are: _buildCategoryDropdown, _buildUnitDropdown, etc.)
  // These methods remain the same as in your original code

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final selectedCategory = categoriesBloc.selectedState;
        final categoryList = categoriesBloc.list;

        return AppDropdown(
          label: "Category",

          context: context,
          hint: selectedCategory.isEmpty ? "Select Category" : selectedCategory,
          isLabel: false,
          isNeedAll: false,
          isRequired: true,
          isSearch: true,
          value: selectedCategory.isEmpty ? null : selectedCategory,
          itemList: categoryList.map((e) => e.name ?? "").toList(),
          onChanged: (newVal) {
            setState(() {
              categoriesBloc.selectedState = newVal.toString();
              final matchingCategory = categoryList.firstWhere(
                    (category) => category.name.toString() == newVal.toString(),
                orElse: () => CategoryModel(),
              );
              categoriesBloc.selectedStateId = matchingCategory.id?.toString() ?? "";
            });
          },
          validator: (value) => value == null ? 'Please select Category' : null,
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(item.toString()),
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
          label: "Unit ",
          hint: selectedUnit.isEmpty ? "Select Unit" : selectedUnit,
          isLabel: false,
          isNeedAll: false,
          isRequired: true,
          isSearch: true,
          value: selectedUnit.isEmpty ? null : selectedUnit,
          itemList: unitList.map((e) => e.name ?? "").toList(),
          onChanged: (newVal) {
            setState(() {
              unitBloc.selectedState = newVal.toString();
              final matchingUnit = unitList.firstWhere(
                    (unit) => unit.name.toString() == newVal.toString(),
                orElse: () => UnitsModel(),
              );
              unitBloc.selectedIdState = matchingUnit.id?.toString() ?? "";
            });
          },
          validator: (value) => value == null ? 'Please select Unit' : null,
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(item.toString()),
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
          isLabel: false,
          isNeedAll: false,
          isSearch: true,
          isRequired: false,
          value: selectedBrand.isEmpty ? null : selectedBrand,
          itemList: brandList.map((e) => e.name ?? "").toList(),
          onChanged: (newVal) {
            setState(() {
              brandBloc.selectedState = newVal.toString();
              final matchingBrand = brandList.firstWhere(
                    (brand) => brand.name.toString() == newVal.toString(),
                orElse: () => BrandModel(),
              );
              brandBloc.selectedId = matchingBrand.id?.toString() ?? "";
            });
          },
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(item.toString()),
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
      labelText: 'Product Name ',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      keyboardType: TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Please enter Product Name' : null,
    );
  }

  Widget _buildPurchasePriceField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: productsBloc.productPurchasePriceController,
      labelText: 'Purchase Price',
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      keyboardType: TextInputType.number,
      hintText: '0.00',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
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
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      keyboardType: TextInputType.number,
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
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
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AppButton(
        name: _isEditMode ? "Update Product" : "Create Product",
        onPressed: _submitProduct,
      ),
    );
  }

  void _submitProduct() {
    if (!formKey.currentState!.validate()) return;

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

    Map<String, String> body = {
      "category": categoriesBloc.selectedStateId,
      "unit": unitBloc.selectedIdState,
      "name": productsBloc.productNameController.text,
    };

    // Add optional fields
    if (brandBloc.selectedId.isNotEmpty) {
      body["brand"] = brandBloc.selectedId;
    }
    if (productsBloc.productSellingPriceController.text.isNotEmpty && productsBloc.productSellingPriceController.text != "0") {
      body["selling_price"] = productsBloc.productSellingPriceController.text;
    }
    if (productsBloc.productPurchasePriceController.text.isNotEmpty && productsBloc.productPurchasePriceController.text != "0") {
      body["purchase_price"] = productsBloc.productPurchasePriceController.text;
    }
    if (productsBloc.productDescriptionController.text.isNotEmpty) {
      body["description"] = productsBloc.productDescriptionController.text;
    }
    if (productsBloc.productOpeningStockController.text.isNotEmpty && productsBloc.productOpeningStockController.text != "0") {
      body["opening_stock"] = productsBloc.productOpeningStockController.text;
    }
    if (productsBloc.productAlertQuantityController.text.isNotEmpty && productsBloc.productAlertQuantityController.text != "5") {
      body["alert_quantity"] = productsBloc.productAlertQuantityController.text;
    }
    if (productsBloc.productBarCodeController.text.isNotEmpty) {
      body["bar_code"] = productsBloc.productBarCodeController.text;
    }

    if (_isEditMode) {
      final productId = widget.product?.id?.toString() ?? widget.productId;
      if (productId != null) {
        productsBloc.add(UpdateProducts(body: body, id: productId));
      }
    } else {
      productsBloc.add(AddProducts(body: body));
    }
  }
}