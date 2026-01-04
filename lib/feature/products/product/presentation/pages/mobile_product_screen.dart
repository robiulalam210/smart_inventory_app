
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../categories/presentation/bloc/categories/categories_bloc.dart';
import '../../data/model/product_model.dart';
import '../bloc/products/products_bloc.dart';
import '../widget/pagination.dart';
import '../widget/widget.dart';
import 'product_create.dart';

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
      final productsBloc = context.read<ProductsBloc>();
      productsBloc.filterTextController.clear();

      context.read<CategoriesBloc>().add(
        FetchCategoriesList(context),
      );
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
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Product",style: AppTextStyle.titleMedium(context),),),
floatingActionButton: FloatingActionButton( onPressed: () => _showCreateProductDialog(context),child: Icon(Icons.add),),
      body: SafeArea(
        child:  _buildContentArea(),
      ),
    );
  }


  Widget _buildContentArea() {
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
                    SizedBox(
                      child: _buildProductList(state),
                    ),
                  ],
                ),
              );
            },
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


  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
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
                    hintText: "Search products...",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.filter,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => _showMobileFilterSheet(context),
              ),
            ],
          ),
        ),
    
      ],
    );
  }

  Widget _buildProductList(ProductsState state) {
    if (state is ProductsListLoading) {
      return const Center(child: CircularProgressIndicator());
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
                onEdit: (v) => _showEditDialog(context, v, false),
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
                _fetchProductList(
                  pageNumber: page,
                  pageSize: state.pageSize,
                );
              },
              onPageSizeChanged: (newPageSize) {
                _fetchProductList(
                  pageNumber: 1,
                  pageSize: newPageSize,
                );
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
            Text(
              'Failed to load products',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.content,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              name: "Retry",
              onPressed: () => _fetchProductList(),
            ),
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

  void _showEditDialog(BuildContext context, ProductModel product, bool isMobile) {
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

  void _showMobileFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Products",
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
              // Add filter options here (status, category, etc.)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}