


import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/custom_filter_ui.dart';
import '../../../categories/presentation/bloc/categories/categories_bloc.dart';
import '../bloc/products/products_bloc.dart';
import '../widget/widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().filterTextController.clear();
    context.read<CategoriesBloc>().add(
      FetchCategoriesList(
        context,
      ),
    );
    _fetchProductList();
  }

  void _fetchProductList(
      {String filterText = '',
        String state = '',
        String category = '',
        int pageNumber = 0}) {
    context.read<ProductsBloc>().add(
      FetchProductsList(context,
        filterText: filterText,
        category: category,
        state: state,
        pageNumber: pageNumber,
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
        child:    RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            _fetchProductList();
          },
          child: Container(
            padding:AppTextStyle.getResponsivePaddingBody(context),

            child: BlocListener<ProductsBloc, ProductsState>(
              listener: (context, state) {
                if (state is ProductsAddLoading) {
                  appLoader(context, "Product, please wait...");
                } else if (state is ProductsAddSuccess) {
                  Navigator.pop(context); // Close loader dialog
                  Navigator.pop(context); // Close loader dialog
                  _fetchProductList(); // Reload warehouse list
                }
                if (state is ProductsDeleteLoading) {
                  appLoader(context, "Delete Product, please wait...");
                } else if (state is ProductsDeleteSuccess) {
                  Navigator.pop(context); // Close loader dialog
                  Navigator.pop(context); // Close loader dialog
                  _fetchProductList(); // Reload warehouse list
                } else if (state is ProductsDeleteFailed) {
                  Navigator.pop(context); // Close loader dialog
                  // Navigator.pop(context); // Close loader dialog
                  _fetchProductList(); // Reload warehouse list
                } else if (state is ProductsAddFailed) {
                  Navigator.pop(context); // Close loader dialog
                  Navigator.pop(context); // Close loader dialog
                  _fetchProductList();
                  appAlertDialog(context, state.content,
                      title: state.title,
                      actions: [
                        TextButton(
                            onPressed: () => AppRoutes.pop(context),
                            child: const Text("Dismiss"))
                      ]);
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: CustomSearchTextFormField(
                            controller:
                            context.read<ProductsBloc>().filterTextController,
                            onChanged: (value) {
                              _fetchProductList(
                                filterText: value,
                              );
                            },
                            onClear: () {
                              context
                                  .read<ProductsBloc>()
                                  .filterTextController
                                  .clear();
                              _fetchProductList(); // R
                            },
                            hintText:
                            "Search Name", // Pass dynamic hintText if needed
                          )),
                      CustomFilterBox(
                        onTapDown: (TapDownDetails details) {
                          _showFilterMenu(context, details.globalPosition);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, state) {
                        print(state);
                        if (state is ProductsListLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ProductsListSuccess) {
                          if (state.list.isEmpty) {
                            return Center(
                              child: Lottie.asset(AppImages.noData),
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.list.length,
                              itemBuilder: (_, index) {
                                final product = state.list[index];
                                return InkWell(
                                  onTap: () {

                                  },
                                  child: ProductCard(
                                      product: product, index: index),
                                );
                              },
                            );
                          }
                        } else if (state is ProductsListFailed) {
                          return Center(
                              child: Text(
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
        )
      );
    }

  }

  void _showFilterMenu(BuildContext context, Offset offset) async {
    final screenSize = MediaQuery.of(context).size;
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
                    child:  Text('Filter',style:AppTextStyle.cardLevelText(context)),
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
                          child:  Text(
                              'Clear',
                              style:AppTextStyle.errorTextStyle(context)
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child:  Text('Close',style:AppTextStyle.cardLevelText(context)),
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

