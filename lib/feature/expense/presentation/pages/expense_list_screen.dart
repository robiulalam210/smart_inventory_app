


import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../widget/widget.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {



  DateTime? startDate;
  DateTime? endDate;
  DateTime now = DateTime.now();

  late var dataBloc=context.read<ExpenseBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sourceBloc here

    // Now, you can safely access the SourceBloc and initialize the filterTextController
    dataBloc.filterTextController = TextEditingController();
    _fetchApi(from: startDate, to: endDate);
  }

  @override
  void dispose() {
    // Dispose of the filterTextController when the widget is disposed
    dataBloc.filterTextController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    startDate = DateTime(now.year, now.month-1,  now.day);
    endDate = DateTime(now.year, now.month ,  now.day);

    context
        .read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context,));
    _fetchApi(from: startDate, to: endDate);
  }

  Future<void> _selectDateRange(StateSetter setState) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: endDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        AppRoutes.pop(context);
      });
      // Add your controller method here

      _fetchApi(from: startDate, to: endDate);
    }
  }


  void _fetchApi(
      {String filterText = '',
        DateTime? from,
        DateTime? to,
        int pageNumber = 0}) {
    context.read<ExpenseBloc>().add(
      FetchExpenseList(context,
        filterText: filterText,
        startDate: from,
        endDate: to,
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
        child: Container(
          padding:AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseAddLoading) {
                appLoader(context, "Expense, please wait...");
              } else if (state is ExpenseAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApi(); // Reload warehouse list
              } else if (state is ExpenseAddFailed) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog

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
                          context.read<ExpenseBloc>().filterTextController,
                          onChanged: (value) {
                            _fetchApi(
                              filterText: value,
                            );
                          },
                          onClear: (){
                            context.read<ExpenseBloc>().filterTextController.clear();
                            _fetchApi(from: startDate, to: endDate);

                          },
                          hintText: "Search Name",
                        )),
                    CustomFilterBox(onTapDown: (TapDownDetails details) {
                      _showFilterMenu(context, details.globalPosition);
                    })
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (context, state) {
                      if (state is ExpenseListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ExpenseListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );
                        } else {
                          return  ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.list.length,
                            itemBuilder: (_, index) {
                              final warehouse = state.list[index];
                              return ExpenseCard(
                                  expense: warehouse, index: index);
                            },
                          );
                        }
                      } else if (state is ExpenseListFailed) {
                        if(state.content.toString()=="No Data"){
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );

                        }else{
                          return Center(
                              child:
                              Text('Failed to load data : ${state.content}'));
                        }
                      } else {
                        return Center(
                          child: Lottie.asset(AppImages.noData),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                    child:  Text('Filter',                          style:AppTextStyle.cardLevelText(context)),

                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      children: [

                      ],
                    ),
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


                              context.read<ExpenseBloc>().add(
                                FetchExpenseList(context,),
                              );
                            });
                            Navigator.of(context).pop();
                          },
                          child:  Text(
                            'Clear',
                            style:AppTextStyle.cardLevelText(context),

                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child:  Text('Close',                          style:AppTextStyle.cardLevelText(context)),
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


