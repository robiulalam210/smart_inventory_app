import 'dart:async';

import 'package:hugeicons/hugeicons.dart';
import 'package:smart_inventory/feature/purchase/presentation/bloc/create_purchase/create_purchase_bloc.dart';
import 'package:smart_inventory/feature/purchase/presentation/bloc/purchase_bloc.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../widget.dart';


class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
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
    context.read<SupplierListBloc>().add(
      FetchSupplierList(context, ),
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
    context.read<PurchaseBloc>().add(
      FetchPurchaseList(
        context,
        filterText: filterText,

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
              BlocListener<CreatePurchaseBloc, CreatePurchaseState>(
                listener: (context, state) {
                  if (state is CreatePurchaseLoading) {
                    appLoader(context, "Creating PosSale, please wait...");
                  } else if (state is CreatePurchaseSuccess) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(); // Reload warehouse list
                  } else if (state is CreatePurchaseFailed) {
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
                  child: BlocBuilder<PurchaseBloc, PurchaseState>(
                    builder: (context, state) {
                      if (state is PurchaseListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PurchaseListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return PurchaseDataTableWidget(
                            sales: state.list,
                          );
                        }
                      } else if (state is PurchaseListFailed) {
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
