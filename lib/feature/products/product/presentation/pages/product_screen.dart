


import 'package:smart_inventory/feature/products/product/data/model/product_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
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
               if (state is ProductsDeleteLoading) {
                appLoader(context, "Deleted product, please wait...");
              }  else if (state is ProductsDeleteSuccess) {
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: state.message,
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );

                Navigator.pop(context); // Close loader dialog
                _fetchProductList(); // Reload warehouse list
              }
               else if (state is ProductsDeleteFailed) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
                _fetchProductList();
                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => AppRoutes.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
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



}