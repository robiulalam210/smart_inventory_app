import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../widget/widget.dart';
import 'expense_sub_head_create.dart';

class MobileExpenseSubHeadScreen extends StatefulWidget {
  const MobileExpenseSubHeadScreen({super.key});

  @override
  State<MobileExpenseSubHeadScreen> createState() => _ExpenseHeadScreenState();
}

class _ExpenseHeadScreenState extends State<MobileExpenseSubHeadScreen> {
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),

        child: Icon(Icons.add),
        onPressed: () {
          context.read<ExpenseSubHeadBloc>().clearData();
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                // insetPadding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(AppSizes.radius),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppColors.bottomNavBg(context),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    width: double.infinity,
                    height: AppSizes.height(context) * 0.3,
                    child: const ExpenseSubCreateScreen(),
                  ),
                ),
              );
            },
          );
        },
      ),
      appBar: AppBar(title: Text("Expense Sub Head",style: AppTextStyle.titleMedium(context),),),

      body: SafeArea(
        child:  SizedBox(
          child: RefreshIndicator(
            color: AppColors.primaryColor(context),
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


                    // Mobile/Tablet layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search Field
                        CustomSearchTextFormField(
                          isRequiredLabel: false,
                          controller: context
                              .read<ExpenseSubHeadBloc>()
                              .filterTextController,
                          onChanged: (value) {
                            _fetchApiData(
                              filterText: value,
                            );
                          },
                          onClear: () {
                            context
                                .read<ExpenseSubHeadBloc>()
                                .filterTextController
                                .clear();
                            _fetchApiData();
                          },
                          hintText: "expense sub heads...",
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
                              return ExpenseSubHeadTableCard(expenseSubHeads: state.list,);
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
      ),
    );
  }



}
