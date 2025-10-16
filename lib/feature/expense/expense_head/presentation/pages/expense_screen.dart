

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../bloc/expense_head/expense_head_bloc.dart';
import '../widget/widget.dart';

class ExpenseHeadScreen extends StatefulWidget {
  const ExpenseHeadScreen({super.key});

  @override
  State<ExpenseHeadScreen> createState() => _ExpenseHeadScreenState();
}

class _ExpenseHeadScreenState extends State<ExpenseHeadScreen> {
  late var dataBloc = context.read<ExpenseHeadBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sourceBloc here

    // Now, you can safely access the SourceBloc and initialize the filterTextController
    dataBloc.filterTextController = TextEditingController();
    _fetchApiData();
  }

  @override
  void dispose() {
    // Dispose of the filterTextController when the widget is disposed
    dataBloc.filterTextController.dispose();
    super.dispose();
  }

  void _fetchApiData({
    String filterText = '',
    String state = '',
    int pageNumber = 0,
  }) {
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
      child: SizedBox(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            _fetchApiData();
          },
          child: Container(
            padding: AppTextStyle.getResponsivePaddingBody(context),
            child: BlocListener<ExpenseHeadBloc, ExpenseHeadState>(
              listener: (context, state) {
                if (state is ExpenseHeadAddLoading) {
                  appLoader(context, "Expense Head, please wait...");
                } else if (state is ExpenseHeadAddSuccess) {
                  Navigator.pop(context); // Close loader dialog
                  Navigator.pop(context); // Close loader dialog
                  _fetchApiData(); // Reload warehouse list
                } else if (state is ExpenseHeadAddFailed) {
                  Navigator.pop(context); // Close loader dialog
                  Navigator.pop(context); // Close loader dialog
                  _fetchApiData();
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
                    children: [
                      Expanded(
                        child: CustomSearchTextFormField(
                          controller: context
                              .read<ExpenseHeadBloc>()
                              .filterTextController,
                          onChanged: (value) {
                            _fetchApiData(
                              filterText: value,
                              state:
                                  context
                                          .read<ExpenseHeadBloc>()
                                          .selectedState ==
                                      "All"
                                  ? ""
                                  : context
                                        .read<ExpenseHeadBloc>()
                                        .selectedState,
                            );
                          },

                          onClear: () {
                            context
                                .read<ExpenseHeadBloc>()
                                .filterTextController
                                .clear();
                            _fetchApiData();
                          },
                          hintText:
                              "Search Name", // Pass dynamic hintText if needed
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                      builder: (context, state) {
                        if (state is ExpenseHeadListLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is ExpenseHeadListSuccess) {
                          if (state.list.isEmpty) {
                            return Center(
                              child: Lottie.asset(AppImages.noData),
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.list.length,
                              itemBuilder: (_, index) {
                                final warehouse = state.list[index];
                                return ExpenseHeadCard(
                                  expenseHead: warehouse,
                                  index: index + 1,
                                );
                              },
                            );
                          }
                        } else if (state is ExpenseHeadListFailed) {
                          return Center(
                            child: Text('Failed to load  : ${state.content}'),
                          );
                        } else {
                          return Center(child: Lottie.asset(AppImages.noData));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
