import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../widget/widget.dart';
import 'expense_sub_head_create.dart';

class ExpenseSubHeadScreen extends StatefulWidget {
  const ExpenseSubHeadScreen({super.key});

  @override
  State<ExpenseSubHeadScreen> createState() => _ExpenseHeadScreenState();
}

class _ExpenseHeadScreenState extends State<ExpenseSubHeadScreen> {
  late var dataBloc = context.read<ExpenseSubHeadBloc>();

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
    context.read<ExpenseSubHeadBloc>().add(
      FetchSubExpenseHeadList(
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
            child: BlocListener<ExpenseSubHeadBloc, ExpenseSubHeadState>(
              listener: (context, state) {
                if (state is ExpenseSubHeadAddLoading) {
                  appLoader(context, "Expense Sub Head, please wait...");
                } else if (state is ExpenseSubHeadAddSuccess) {
                  Navigator.pop(context); // Close loader dialog
                  Navigator.pop(context); // Close loader dialog
                  _fetchApiData(); // Reload warehouse list
                } else if (state is ExpenseSubHeadAddFailed) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomSearchTextFormField(
                          isRequiredLabel: false,
                          controller: context
                              .read<ExpenseSubHeadBloc>()
                              .filterTextController,
                          onChanged: (value) {
                            _fetchApiData(
                              filterText: value,
                              state:
                                  context
                                          .read<ExpenseSubHeadBloc>()
                                          .selectedState ==
                                      "All"
                                  ? ""
                                  : context
                                        .read<ExpenseSubHeadBloc>()
                                        .selectedState,
                            );
                          },

                          onClear: () {
                            context
                                .read<ExpenseSubHeadBloc>()
                                .filterTextController
                                .clear();
                            _fetchApiData();
                          },
                          hintText:
                              "Name", // Pass dynamic hintText if needed
                        ),
                      ),
                      gapW16,
                      AppButton(
                        name: "Create Sub Expanse Head",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  width: AppSizes.width(context) * 0.50,
                                  child: ExpenseSubCreateScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    child: BlocBuilder<ExpenseSubHeadBloc, ExpenseSubHeadState>(
                      builder: (context, state) {
                        if (state is ExpenseSubHeadListLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is ExpenseSubHeadListSuccess) {
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
                                return ExpenseSubHeadCard(
                                  expenseHead: warehouse,
                                  index: index + 1,
                                );
                              },
                            );
                          }
                        } else if (state is ExpenseSubHeadListFailed) {
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
