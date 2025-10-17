import 'dart:async';

import 'package:hugeicons/hugeicons.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';
import '../bloc/possale/possale_bloc.dart';
import '../widgets/widget.dart';

class PosSaleScreen extends StatefulWidget {
  const PosSaleScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<PosSaleScreen> {
  DateTime? startDate;
  DateTime? endDate;

  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    // Optionally listen for drawer state changes

    filterTextController.clear();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(
      FetchCustomerList(context, dropdownFilter: "?status=1"),
    );
    _fetchApi(from: startDate, to: endDate);
  }

  void _fetchApi({
    String filterText = '',
    String customer = '',
    String seller = '',

    DateTime? from,
    DateTime? to,
    int pageNumber = 0,
  }) {
    context.read<PosSaleBloc>().add(
      FetchPosSaleList(
        context,
        filterText: filterText,
        customer: customer,
        seller: seller,
        startDate: startDate,
        endDate: endDate,
        pageNumber: pageNumber,
      ),
    );
  }

  TextEditingController filterTextController = TextEditingController();

  @override
  void dispose() {
    filterTextController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  var purchaseList = "";

  String selectedQuickOption = "";
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);

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
          _fetchApi();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: MultiBlocListener(
            listeners: [
              BlocListener<CreatePosSaleBloc, CreatePosSaleState>(
                listener: (context, state) {
                  if (state is CreatePosSaleLoading) {
                    appLoader(context, "Creating PosSale, please wait...");
                  } else if (state is CreatePosSaleSuccess) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(); // Reload warehouse list
                  } else if (state is CreatePosSaleFailed) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi();
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
              ),
            ],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchTextFormField(
                        controller: filterTextController,
                        onChanged: (value) {
                          _fetchApi(filterText: filterTextController.text);
                        },
                        onClear: () {
                          _fetchApi();

                          filterTextController.clear();
                        },
                        hintText:
                            "Search InvoiceNo Name & Phone ", // Pass dynamic hintText if needed
                      ),
                    ),
                    CustomFilterBox(onTapDown: (TapDownDetails details) {}),
                  ],
                ),
                SizedBox(
                  child: BlocBuilder<PosSaleBloc, PosSaleState>(
                    builder: (context, state) {
                      if (state is PosSaleListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PosSaleListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return PosSaleDataTableWidget(
                            sales: state.list,
                          );
                        }
                      } else if (state is PosSaleListFailed) {
                        return Center(
                          child: Text(
                            state.content,
                          ),
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
    );
  }
}
