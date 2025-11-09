import 'package:smart_inventory/feature/products/brand/data/model/brand_model.dart';
import 'package:smart_inventory/feature/products/brand/presentation/bloc/brand/brand_bloc.dart';
import 'package:smart_inventory/feature/products/categories/data/model/categories_model.dart';
import 'package:smart_inventory/feature/products/categories/presentation/bloc/categories/categories_bloc.dart';
import 'package:smart_inventory/feature/products/groups/data/model/groups.dart';
import 'package:smart_inventory/feature/products/groups/presentation/bloc/groups/groups_bloc.dart';
import 'package:smart_inventory/feature/products/soruce/data/model/source_model.dart';
import 'package:smart_inventory/feature/products/soruce/presentation/bloc/source/source_bloc.dart';
import 'package:smart_inventory/feature/products/unit/data/model/unit_model.dart';
import 'package:smart_inventory/feature/products/unit/presentation/bloc/unit/unti_bloc.dart';
import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../data/model/product_model.dart';
import '../bloc/products/products_bloc.dart';

class ProductsForm extends StatefulWidget {
  final ProductModel? product;
  final String? productId;

  const ProductsForm({
    super.key,
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
  late GroupsBloc groupsBloc;
  late SourceBloc sourceBloc;

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
      groupsBloc = context.read<GroupsBloc>(); // <- initialize
      sourceBloc = context.read<SourceBloc>(); // <- initialize
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
    sourceBloc.add(FetchSourceList(context));
    groupsBloc.add(FetchGroupsList(context));
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



    return SafeArea(child: _buildDialogContent());
  }

  Widget _buildDialogContent() {
    return Container(
   
      decoration: BoxDecoration(
        color: AppColors.bg,
        
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 10),
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
                      Row(
                        children: [
                          Expanded(child: _buildCategoryDropdown()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildUnitDropdown()),
                        ],
                      ),
                      // _buildCategoryDropdown(),
                      // const SizedBox(height: 8),
                      // _buildProductNameField(),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Expanded(child: _buildGroupsDropdown()),
                          const SizedBox(width: 5),
                          Expanded(child: _buildBrandDropdown()),

                          const SizedBox(width: 5),
                          Expanded(child: _buildSourceDropdown()),
                        ],
                      ),
                      // const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildProductNameField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildOpeningStockField()),
                        ],
                      ),
                      const SizedBox(height: 8), Row(
                        children: [
                          Expanded(child: _buildPurchasePriceField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSellingPriceField()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Expanded(child: _buildOpeningStockField()),
                          // const SizedBox(width: 10),
                          Expanded(child: _buildAlertQuantityField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDescriptionField()),
                        ],
                      ),
                      const SizedBox(height: 8),


                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(
                          width: 150,
                          child: AppButton(
                            name: _isEditMode ? "Update Product" : "Create Product",
                            onPressed: _submitProduct,
                          ),
                        ),
                        const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: AppButton(
                              name: "Cancel",
                              color: Colors.grey,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                      ],),

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
      // if (widget.isDialog) {
        Navigator.pop(context);
      // } else {
      //   context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 7));
      // }
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
  Widget _buildGroupsDropdown() {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        final selectedGroup = groupsBloc.selectedState;
        final groupsList = groupsBloc.list;

        return AppDropdown(
          context: context,
          label: "Groups ",
          hint: selectedGroup.isEmpty ? "Select Groups" : selectedGroup,
          isLabel: false,
          isNeedAll: false,
          isRequired: false,
          isSearch: true,
          value: selectedGroup.isEmpty ? null : selectedGroup,
          itemList: groupsList.map((e) => e.name ?? "").toList(),
          onChanged: (newVal) {
            setState(() {
              groupsBloc.selectedState = newVal.toString();
              final matchingUnit = groupsList.firstWhere(
                    (unit) => unit.name.toString() == newVal.toString(),
                orElse: () => GroupsModel(),
              );
              groupsBloc.selectedIdState = matchingUnit.id?.toString() ?? "";
            });
          },
          // validator: (value) => value == null ? 'Please select Unit' : null,
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(item.toString()),
          ),
        );
      },
    );
  }
  Widget _buildSourceDropdown() {
    return BlocBuilder<SourceBloc, SourceState>(
      builder: (context, state) {
        final selectedSource = sourceBloc.selectedState;
        final sourceList = sourceBloc.list;

        return AppDropdown(
          context: context,
          label: "Source ",
          hint: selectedSource.isEmpty ? "Select Source" : selectedSource,
          isLabel: false,
          isNeedAll: false,
          isRequired: false,
          isSearch: true,
          value: selectedSource.isEmpty ? null : selectedSource,
          itemList: sourceList.map((e) => e.name ?? "").toList(),
          onChanged: (newVal) {
            setState(() {
              sourceBloc.selectedState = newVal.toString();
              final matchingUnit = sourceList.firstWhere(
                    (unit) => unit.name.toString() == newVal.toString(),
                orElse: () => SourceModel(),
              );
              sourceBloc.selectedIdState = matchingUnit.id?.toString() ?? "";
            });
          },
          // validator: (value) => value == null ? 'Please select Source' : null,
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
    if (sourceBloc.selectedId.isNotEmpty) {
      body["source"] = sourceBloc.selectedId;
    } if (groupsBloc.selectedId.isNotEmpty) {
      body["groups"] = groupsBloc.selectedId;
    } if (brandBloc.selectedId.isNotEmpty) {
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