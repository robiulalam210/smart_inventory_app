
import 'package:meta/meta.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/money_receipt/money_receipt_bloc.dart';
import '../bloc/money_receipt/money_receipt_state.dart';
import '../widgets/widget.dart';


class MoneyReceiptScreen extends StatefulWidget {
  const MoneyReceiptScreen({super.key,});


  @override
  State<MoneyReceiptScreen> createState() => _MoneyReceiptScreenState();
}

class _MoneyReceiptScreenState extends State<MoneyReceiptScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController filterTextController = TextEditingController();

  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);
    context.read<MoneyReceiptBloc>().selectUserModel = null;
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(
      FetchCustomerList(context, dropdownFilter: "?status=1"),
    );
    _fetchApi(from: startDate, to: endDate);
  }


  String selectedQuickOption = "";
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);



  void _fetchApi(
      {String filterText = '',
        String customer = '',
        String seller = '',
        String location = '',
        String paymentMethod = '',
        DateTime? from,
        DateTime? to,
        int pageNumber = 0}) {
    context.read<MoneyReceiptBloc>().add(
      FetchMoneyReceiptList(
        context,
        filterText: filterText,
        customer: customer,
        location: location,
        seller: seller,
        paymentMethod: paymentMethod,
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
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          _fetchApi(

            from: startDate,
            to: endDate,
            customer: context
                .read<MoneyReceiptBloc>()
                .selectCustomerModel
                ?.name ??
                '',
            seller: context
                .read<MoneyReceiptBloc>()
                .selectUserModel
                ?.username ??
                '',
            paymentMethod:
            selectedPaymentMethodNotifier.value?.toString() ?? '',
          );
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<MoneyReceiptBloc, MoneyReceiptState>(
            listener: (context, state) {
              if (state is MoneyReceiptAddLoading) {
                appLoader(context, "Money receipt, please wait...");
              } else if (state is MoneyReceiptAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApi(

                  from: startDate,
                  to: endDate,
                  customer: context
                      .read<MoneyReceiptBloc>()
                      .selectCustomerModel
                      ?.name ??
                      '',
                  seller: context
                      .read<MoneyReceiptBloc>()
                      .selectUserModel
                      ?.username ??
                      '',
                  paymentMethod:
                  selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
              } else if (state is MoneyReceiptDetailsSuccess) {

                // AppRoutes.pop(context);
              } else if (state is MoneyReceiptAddFailed) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApi(

                  from: startDate,
                  to: endDate,
                  customer: context
                      .read<MoneyReceiptBloc>()
                      .selectCustomerModel
                      ?.name ??
                      '',

                  paymentMethod:
                  selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
                appAlertDialog(context, state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                          onPressed: () => AppRoutes.pop(context),
                          child: const Text("Dismiss"))
                    ]);
              } else if (state is MoneyReceiptDeleteLoading) {
                appLoader(context, "Delete MoneyReceipt, please wait...");
              } else if (state is MoneyReceiptDeleteSuccess) {
                // Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApi(


                  from: startDate,
                  to: endDate,
                  customer: context
                      .read<MoneyReceiptBloc>()
                      .selectCustomerModel
                      ?.name ??
                      '',


                  paymentMethod:
                  selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
              } else if (state is MoneyReceiptDeleteFailed) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
                _fetchApi(

                  from: startDate,
                  to: endDate,
                  customer: context
                      .read<MoneyReceiptBloc>()
                      .selectCustomerModel
                      ?.name ??
                      '',

                  paymentMethod:
                  selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
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
                          controller: filterTextController,
                          onChanged: (value) {
                            _fetchApi(
                              filterText: value,

                              from: startDate,
                              to: endDate,
                              customer: context
                                  .read<MoneyReceiptBloc>()
                                  .selectCustomerModel
                                  ?.name ??
                                  '',

                              paymentMethod: selectedPaymentMethodNotifier.value
                                  ?.toString() ??
                                  '',
                            );
                          },
                          onClear: () {
                            _fetchApi(

                              from: startDate,
                              to: endDate,
                              customer: context
                                  .read<MoneyReceiptBloc>()
                                  .selectCustomerModel
                                  ?.name ??
                                  '',

                              paymentMethod: selectedPaymentMethodNotifier.value
                                  ?.toString() ??
                                  '',
                            );
                            filterTextController.clear();
                          },
                          hintText: "Search Name",
                        )),
                    CustomFilterBox(onTapDown: (TapDownDetails details) {

                    })
                  ],
                ),
                SizedBox(
                  child: BlocBuilder<MoneyReceiptBloc, MoneyReceiptState>(
                    builder: (context, state) {
                      if (state is MoneyReceiptListLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (state is MoneyReceiptListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );
                        } else {
                          return MoneyReciptDataTableWidget(sales: state.list,);
                        }
                      } else if (state is MoneyReceiptListFailed) {
                        return Center(
                          child: Text(
                              'Failed to load money receipt: ${state.content}'),
                        );
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
      ),
    );
  }
}
