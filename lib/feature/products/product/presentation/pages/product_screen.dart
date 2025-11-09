


import 'package:smart_inventory/feature/products/product/data/model/product_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/custom_filter_ui.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../categories/presentation/bloc/categories/categories_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    context
        .read<ProductsBloc>()
        .filterTextController
        .clear();
    context.read<CategoriesBloc>().add(
      FetchCategoriesList(
        context,
      ),
    );
    _fetchProductList(pageNumber: 1);
  }

  void _fetchProductList({
    String filterText = '',
    String state = '',
    String category = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    context.read<ProductsBloc>().add(
      FetchProductsList(
        context,
        filterText: filterText,
        category: category,
        state: state,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  // ... other widget methods remain unchanged ...

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          spacing: 0,
          runSpacing: 0,
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }
  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0,
      sm: 1,
      md: 1,
      lg: 2,
      xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          _fetchProductList();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<ProductsBloc, ProductsState>(
            listener: (context, state) {
              // keep existing listener code
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 400,
                        child: CustomSearchTextFormField(
                          controller:
                          context
                              .read<ProductsBloc>()
                              .filterTextController,
                          onChanged: (value) {
                            _fetchProductList(
                              filterText: value,
                            );
                          },
                          isRequiredLabel: false,
                          onClear: () {
                            context
                                .read<ProductsBloc>()
                                .filterTextController
                                .clear();
                            _fetchProductList();
                          },
                          hintText: "Name",
                        )),

                    gapW16,
                    AppButton(
                      name: "Create Product",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 500,
                                // height: MediaQuery.of(context).size.height * 0.6,
                                child: const ProductsForm(),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  ],
                ),
                gapH8,
                SizedBox(
                  child: BlocBuilder<ProductsBloc, ProductsState>(
                    builder: (context, state) {
                      if (state is ProductsListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ProductsListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );
                        } else {
                          // Show table + pagination bar
                          return Column(
                            children: [
                              ProductDataTableWidget(products: state.list,

                                onEdit: (v) {
                                  _showEditDialog(context, v);
                                },
                                onDelete: (v) async {
                                  bool shouldDelete =
                                  await showDeleteConfirmationDialog(
                                    context,
                                  );
                                  if (!shouldDelete) return;

                                  context.read<ProductsBloc>().add(
                                    DeleteProducts(id: v.id.toString()),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              PaginationBar(
                                count: state.count,
                                totalPages: state.totalPages,
                                currentPage: state.currentPage,
                                pageSize: state.pageSize,
                                from: state.from,
                                to: state.to,
                                onPageChanged: (page) {
                                  _fetchProductList(
                                      pageNumber: page,
                                      pageSize: state.pageSize);
                                },
                                onPageSizeChanged: (newPageSize) {
                                  // reset to page 1 when page size changes
                                  _fetchProductList(
                                      pageNumber: 1, pageSize: newPageSize);
                                },
                              ),
                            ],
                          );
                        }
                      } else if (state is ProductsListFailed) {
                        return Center(child: Text(
                            'Failed to load : ${state.content}'));
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            child: ProductsForm(
              productId: product.id.toString(),
              product: product,
            ),
          ),
        );
      },
    );
  }


  void _showFilterMenu(BuildContext context, Offset offset) async {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final left = offset.dx;
    final top = offset.dy;
    final right = screenSize.width - left;
    final bottom = screenSize.height - top;

    await showMenu(
      color: const Color.fromARGB(255, 248, 248, 248),
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, bottom),
      items: [
        PopupMenuItem(
          padding: const EdgeInsets.all(0),
          enabled: false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                      // borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 248, 248, 248),
                    ),
                    child: Text(
                        'Filter', style: AppTextStyle.cardLevelText(context)),
                  ),


                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              context.read<ProductsBloc>().add(
                                FetchProductsList(context,),
                              );
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(
                              'Clear',
                              style: AppTextStyle.errorTextStyle(context)
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close', style: AppTextStyle
                              .cardLevelText(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

}