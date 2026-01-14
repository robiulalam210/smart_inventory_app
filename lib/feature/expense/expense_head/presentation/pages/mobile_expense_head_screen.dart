import '/core/core.dart';

import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../bloc/expense_head/expense_head_bloc.dart';
import '../widget/widget.dart';
import 'expense_head_create.dart';

class MobileExpenseHeadScreen extends StatefulWidget {
  const MobileExpenseHeadScreen({super.key});

  @override
  State<MobileExpenseHeadScreen> createState() => _ExpenseHeadScreenState();
}

class _ExpenseHeadScreenState extends State<MobileExpenseHeadScreen> {
  late ExpenseHeadBloc dataBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataBloc = context.read<ExpenseHeadBloc>();
      _fetchApiData();
    });
  }

  @override
  void dispose() {
    // _searchController.dispose();
    // if (dataBloc.filterTextController != null) {
    //   dataBloc.filterTextController!.dispose();
    // }
    super.dispose();
  }

  void _fetchApiData({String filterText = '', int pageNumber = 0}) {
    if (!mounted) return;

    context.read<ExpenseHeadBloc>().add(
      FetchExpenseHeadList(
        context,
        filterText: filterText,
        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCreateDialog(context),
      ),
      appBar: AppBar(
        title: Text("Expense Head", style: AppTextStyle.titleMedium(context)),
      ),
      body: SafeArea(child: _buildContentArea()),
    );
  }

  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: SizedBox(
        child: RefreshIndicator(
          color: AppColors.primaryColor(context),
          onRefresh: () async {
            _fetchApiData();
          },
          child: Container(
            padding: AppTextStyle.getResponsivePaddingBody(context),
            child: BlocConsumer<ExpenseHeadBloc, ExpenseHeadState>(
              listener: (context, state) {
                _handleBlocState(state);
              },
              builder: (context, state) {
                return Column(
                  children: [
                    _buildMobileHeader(context),
                    const SizedBox(height: 8),
                    _buildExpenseHeadList(state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleBlocState(ExpenseHeadState state) {
    if (state is ExpenseHeadAddLoading) {
      appLoader(context, "Creating Expense Head, please wait...");
    } else if (state is ExpenseHeadAddSuccess) {
      Navigator.pop(context); // Close loader dialog
      Navigator.pop(context); // Close loader dialog
      _fetchApiData(); // Reload expense head list
    } else if (state is ExpenseHeadAddFailed) {
      if (context.mounted) {
        Navigator.pop(context); // Close loader dialog
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

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color:AppColors.bottomNavBg(context),
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
                    isRequiredLabel: false,
                    controller: context
                        .read<ExpenseHeadBloc>()
                        .filterTextController,
                    onChanged: (value) {
                      _fetchApiData(filterText: value);
                    },
                    onClear: () {
                      context
                          .read<ExpenseHeadBloc>()
                          .filterTextController
                          .clear();
                      _searchController.clear();
                      _fetchApiData();
                    },
                    hintText: "Search expense head...",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.filter, color: AppColors.primaryColor(context)),
                onPressed: () => _showMobileFilterOptions(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseHeadList(ExpenseHeadState state) {
    if (state is ExpenseHeadListLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    } else if (state is ExpenseHeadListSuccess) {
      if (state.list.isEmpty) {
        return Expanded(child: Center(child: Lottie.asset(AppImages.noData)));
      } else {
        return SizedBox(
          child: ExpenseHeadTableCard(
            expenseHeads: state.list,
            onExpenseHeadTap: () {
              // Handle expense head tap if needed
            },
          ),
        );
      }
    } else if (state is ExpenseHeadListFailed) {
      return Expanded(
        child: Center(
          child: Text(
            'Failed to load: ${state.content}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Expanded(child: Center(child: Lottie.asset(AppImages.noData)));
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(AppSizes.radius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.isMobile(context)
                    ? AppSizes.width(context)
                    : AppSizes.width(context) * 0.5,
                maxHeight: AppSizes.height(context) * 0.7,
              ),
              child: const ExpenseHeadCreate(),
            ),
          ),
        );
      },
    );
  }

  void _showMobileFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
