import '/core/core.dart';

import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../bloc/expense_head/expense_head_bloc.dart';
import '../widget/widget.dart';
import 'expense_head_create.dart';

class ExpenseHeadScreen extends StatefulWidget {
  const ExpenseHeadScreen({super.key});

  @override
  State<ExpenseHeadScreen> createState() => _ExpenseHeadScreenState();
}

class _ExpenseHeadScreenState extends State<ExpenseHeadScreen> {
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
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.bottomNavBg(context),
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
                    _buildDesktopHeader(context),
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

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 350,
          child: CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: context.read<ExpenseHeadBloc>().filterTextController,
            onChanged: (value) {
              _fetchApiData(filterText: value);
            },
            onClear: () {
              context.read<ExpenseHeadBloc>().filterTextController.clear();
              _searchController.clear();
              _fetchApiData();
            },
            hintText: "Search expense head...",
          ),
        ),
        gapW16,
        AppButton(
          name: "Create Expense Head",
          onPressed: () => _showCreateDialog(context),
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
      }
      return Expanded(
        child: ExpenseHeadTableCard(
          expenseHeads: state.list,
          onExpenseHeadTap: () {},
        ),
      );
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context)
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
              maxHeight: AppSizes.height(context) * 0.7,
            ),
            child: const ExpenseHeadCreate(),
          ),
        );
      },
    );
  }

}
