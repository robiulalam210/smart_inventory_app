import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '/feature/products/brand/data/model/brand_model.dart';
import '/feature/products/brand/presentation/bloc/brand/brand_bloc.dart';
import '/feature/products/categories/data/model/categories_model.dart';
import '/feature/products/categories/presentation/bloc/categories/categories_bloc.dart';
import '/feature/products/groups/data/model/groups.dart';
import '/feature/products/groups/presentation/bloc/groups/groups_bloc.dart';
import '/feature/products/soruce/data/model/source_model.dart';
import '/feature/products/soruce/presentation/bloc/source/source_bloc.dart';
import '/feature/products/unit/data/model/unit_model.dart';
import '/feature/products/unit/presentation/bloc/unit/unti_bloc.dart';
import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/product_model.dart';
import '../bloc/products/products_bloc.dart';

class MobileProductCreate extends StatefulWidget {
  final ProductModel? product;
  final String? productId;

  const MobileProductCreate({super.key, this.product, this.productId});

  @override
  State<MobileProductCreate> createState() => _ProductsFormState();
}

class _ProductsFormState extends State<MobileProductCreate> {
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
      groupsBloc = context.read<GroupsBloc>();
      sourceBloc = context.read<SourceBloc>();
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
    productsBloc.productDiscountValueController.text = "0";
    productsBloc.selectedDiscountType = "fixed";
    productsBloc.isDiscountApplied = false;

    categoriesBloc.selectedState = "";
    categoriesBloc.selectedStateId = "";
    unitBloc.selectedState = "";
    unitBloc.selectedIdState = "";
    brandBloc.selectedState = "";
    brandBloc.selectedId = "";
    groupsBloc.selectedState = "";
    groupsBloc.selectedIdState = "";
    sourceBloc.selectedState = "";
    sourceBloc.selectedIdState = "";
  }

  void _prefillFormData(ProductModel product) {
    productsBloc.productNameController.text = product.name ?? "";
    productsBloc.productDescriptionController.text = product.description ?? "";
    productsBloc.productPurchasePriceController.text =
        product.purchasePrice?.toString() ?? "0";
    productsBloc.productSellingPriceController.text =
        product.sellingPrice?.toString() ?? "0";
    productsBloc.productOpeningStockController.text =
        product.openingStock?.toString() ?? "0";
    productsBloc.productAlertQuantityController.text =
        product.alertQuantity?.toString() ?? "5";
    productsBloc.productDiscountValueController.text =
        product.discountValue?.toString() ?? "0";
    productsBloc.selectedDiscountType = product.discountType ?? "fixed";
    productsBloc.isDiscountApplied = product.discountApplied ?? false;

    productsBloc.selectedState = product.isActive == true ? "Active" : "Inactive";

    // Set selected category, unit, brand if available
    if (product.categoryInfo?.name != null) {
      categoriesBloc.selectedState = product.categoryInfo!.name!;
      categoriesBloc.selectedStateId =
          product.categoryInfo!.id?.toString() ?? "";
    }

    if (product.unitInfo?.name != null) {
      unitBloc.selectedState = product.unitInfo!.name!;
      unitBloc.selectedIdState = product.unitInfo!.id?.toString() ?? "";
    }

    if (product.brandInfo?.name != null) {
      brandBloc.selectedState = product.brandInfo!.name!;
      brandBloc.selectedId = product.brandInfo!.id?.toString() ?? "";
    }

    if (product.groupInfo?.name != null) {
      groupsBloc.selectedState = product.groupInfo!.name!;
      groupsBloc.selectedIdState = product.groupInfo!.id?.toString() ?? "";
    }

    if (product.sourceInfo?.name != null) {
      sourceBloc.selectedState = product.sourceInfo!.name!;
      sourceBloc.selectedIdState = product.sourceInfo!.id?.toString() ?? "";
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
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(12),
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
                      // First Row: Category and Unit
                      Row(
                        children: [
                          Expanded(child: _buildCategoryDropdown()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildUnitDropdown()),
                        ],
                      ),

                      // Second Row: Groups, Brand, Source
                      Row(
                        children: [
                          Expanded(child: _buildGroupsDropdown()),
                          const SizedBox(width: 5),
                          Expanded(child: _buildBrandDropdown()),
                          const SizedBox(width: 5),
                          Expanded(child: _buildSourceDropdown()),
                        ],
                      ),

                      // Third Row: Product Name and Opening Stock
                      Row(
                        children: [
                          Expanded(child: _buildProductNameField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildOpeningStockField()),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Fourth Row: Purchase Price and Selling Price
                      Row(
                        children: [
                          Expanded(child: _buildPurchasePriceField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildSellingPriceField()),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Fifth Row: Discount Toggle
                      Row(
                        children: [
                          Expanded(child: _buildDiscountAppliedToggle()),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BlocBuilder<ProductsBloc, ProductsState>(
                              builder: (context, state) {
                                return Visibility(
                                  visible: productsBloc.isDiscountApplied,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: _buildDiscountValueField(),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: _buildDiscountTypeDropdown(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      // Sixth Row: Discount Value and Type
                      const SizedBox(height: 8),

                      // Seventh Row: Alert Quantity and Description
                      Row(
                        children: [
                          Expanded(child: _buildAlertQuantityField()),
                          const SizedBox(width: 10),

                          Expanded(child: _buildDescriptionField()),
                        ],
                      ),

                      const SizedBox(height: 10),
                      if (widget.productId != null) ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 600;

                            return SizedBox(
                              width: isSmallScreen
                                  ? double.infinity
                                  : constraints.maxWidth * 0.5,
                              child: AppDropdown(
                                label: "Status",
                                hint:
                                    context
                                        .read<ProductsBloc>()
                                        .selectedState
                                        .isEmpty
                                    ? "Select Status"
                                    : context.read<ProductsBloc>().selectedState,
                                isLabel: false,
                                value:
                                    context
                                        .read<ProductsBloc>()
                                        .selectedState
                                        .isEmpty
                                    ? null
                                    : context.read<ProductsBloc>().selectedState,
                                itemList: ["Active", "Inactive"],
                                onChanged: (newVal) {
                                  setState(() {
                                    context.read<ProductsBloc>().selectedState =
                                        newVal.toString();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.height(context) * 0.01),
                      ],

                      const SizedBox(height: 20),

                      // Buttons Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: AppButton(
                              name: _isEditMode
                                  ? "Update Product"
                                  : "Create Product",
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
                        ],
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

  void _handleProductState(ProductsState state) {
    if (state is ProductsAddLoading) {
      appLoader(
        context,
        _isEditMode
            ? "Updating Product..."
            : "Creating Product, please wait...",
      );
    } else if (state is ProductsAddSuccess) {
      Navigator.pop(context); // Close loader dialog

      // Refresh product list
      context.read<ProductsBloc>().add(
        FetchProductsList(context, pageNumber: 1, pageSize: 20),
      );
      showCustomToast(
        context: context,
        title: 'Success!',
        description:
              _isEditMode
                  ? 'Product updated successfully!'
                  : 'Product created successfully!',
        icon: Icons.check_circle,
        primaryColor: Colors.green,
      );


      Navigator.pop(context);
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

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final selectedCategory = categoriesBloc.selectedState;
        final categoryList = categoriesBloc.list;

        return AppDropdown(
          label: "Category",
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
              categoriesBloc.selectedStateId =
                  matchingCategory.id?.toString() ?? "";
            });
          },
          validator: (value) => value == null ? 'Please select Category' : null,

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
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
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
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
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

  Widget _buildDiscountAppliedToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Apply Discount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 5),

          Transform.scale(
            scale: 0.7,
            child:     BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                return Switch(
                  padding: EdgeInsets.zero,
                  value: productsBloc.isDiscountApplied,
                  activeThumbColor: Colors.orange,
                  onChanged: (value) {
                    setState(() {
                      productsBloc.isDiscountApplied = value;
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDiscountValueField() {
    return CustomInputField(
      isRequiredLable: false,
      isRequired: false,
      controller: productsBloc.productDiscountValueController,
      labelText: 'Discount Value',
      hintText: '0.00',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      keyboardType: TextInputType.number,
      // prefixIcon: const Icon(Icons.discount, size: 20),
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return SizedBox(
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              return CupertinoSegmentedControl<String>(
                padding: EdgeInsets.zero,
                children: {
                  'fixed': Text(
                    'TK',
                    style: TextStyle(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      color: productsBloc.selectedDiscountType == 'fixed'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  'percentage': Text(
                    '%',
                    style: TextStyle(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      color: productsBloc.selectedDiscountType == 'percentage'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                },
                onValueChanged: (val) {
                  setState(() {
                    productsBloc.selectedDiscountType = val;
                  });
                },
                groupValue: productsBloc.selectedDiscountType,
                unselectedColor: Colors.grey[300],
                selectedColor: AppColors.primaryColor(context),
                borderColor: AppColors.primaryColor(context),
              );
            },
          ),
        );

        // return AppDropdown(
        //   context: context,
        //   label: "",
        //
        //   hint: "Type",
        //   isLabel: true,
        //   isNeedAll: false,
        //   isRequired: false,
        //   isSearch: false,
        //   value: productsBloc.selectedDiscountType,
        //   itemList: const ['fixed', 'percentage'],
        //   onChanged: (newVal) {
        //     setState(() {
        //       productsBloc.selectedDiscountType = newVal.toString();
        //     });
        //   },
        //   itemBuilder: (item) => DropdownMenuItem(
        //     value: item,
        //     child: Text(
        //       item.toString().toUpperCase(),
        //       style: const TextStyle(fontSize: 12),
        //     ),
        //   ),
        // );
      },
    );
  }

  void _submitProduct() {
    if (!formKey.currentState!.validate()) return;

    if (categoriesBloc.selectedStateId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (unitBloc.selectedIdState.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a unit')));
      return;
    }

    Map<String, dynamic> body = {
      "category": categoriesBloc.selectedStateId,
      "unit": unitBloc.selectedIdState,
      "name": productsBloc.productNameController.text,
    };

    // Add optional fields
    if (sourceBloc.selectedIdState.isNotEmpty) {
      body["source"] = sourceBloc.selectedIdState;
    }
    if (groupsBloc.selectedIdState.isNotEmpty) {
      body["groups"] = groupsBloc.selectedIdState;
    }
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

    if (widget.productId != null &&
        context.read<ProductsBloc>().selectedState.trim().isNotEmpty) {
      body["is_active"] =
      context.read<ProductsBloc>().selectedState == "Active"
          ? true
          : false;
    }
    // Add discount fields
    if (productsBloc.isDiscountApplied) {
      if (productsBloc.productDiscountValueController.text.isNotEmpty &&
          productsBloc.productDiscountValueController.text != "0") {
        body["discount_value"] =
            productsBloc.productDiscountValueController.text;
        body["discount_type"] = productsBloc.selectedDiscountType;
        body["discount_applied_on"] = "true";
      }
    } else {
      // Ensure discount is not applied
      body["discount_applied_on"] = "false";
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
