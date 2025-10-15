import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../bloc/customer/customer_bloc.dart';
import '../widget/widget.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  void initState() {
    super.initState();

    // context.read<SourceBloc>().add(
    //   FetchSourceList(
    //     context,
    //   ),
    // );
    _fetchApi();
  }

  void _fetchApi(
      {String filterText = '', String status = '', int pageNumber = 0}) {
    context.read<CustomerBloc>().add(
      FetchCustomerList(
        context,
        filterText: filterText,
        status: status,
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
              padding: AppTextStyle.getResponsivePaddingBody(context),
              child: BlocListener<CustomerBloc, CustomerState>(
                listener: (context, state) {
                  if (state is CustomerAddLoading) {
                    appLoader(context, "Creating Customer, please wait...");
                  } else if (state is CustomerSwitchLoading) {
                    appLoader(context, "Update Customer, please wait...");
                  }else if (state is CustomerDeleteLoading) {
                    appLoader(context, "Delete Customer, please wait...");
                  } else if (state is CustomerSwitchSuccess) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(); // Reload warehouse list
                  }else if (state is CustomerDeleteSuccess) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(); // Reload warehouse list
                  } else if (state is CustomerAddSuccess) {
                    Navigator.pop(context); // Close loader dialog
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(); // Reload warehouse list
                  } else if (state is CustomerSwitchFailed) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi();
                    appAlertDialog(context, state.content,
                        title: state.title,
                        actions: [
                          TextButton(
                              onPressed: () => AppRoutes.pop(context),
                              child: const Text("Dismiss"))
                        ]);
                  } else if (state is CustomerAddFailed) {
                    Navigator.pop(context); // Close loader dialog
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi();
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
                              context.read<CustomerBloc>().filterTextController,
                              onChanged: (value) {
                                _fetchApi(
                                  filterText: value,
                                );
                              },
                              hintText: "Search Name",
                              onClear: () {
                                context.read<CustomerBloc>().filterTextController.clear();
                                _fetchApi();
                              },

                              // Pass dynamic hintText if needed
                            )),
                        CustomFilterBox(
                          onTapDown: (TapDownDetails details) {
                            _showFilterMenu(context, details.globalPosition);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 500,
                      child: BlocBuilder<CustomerBloc, CustomerState>(
                        builder: (context, state) {
                          if (state is CustomerListLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is CustomerSuccess) {
                            Text(state.list.toString());

                            if (state.list.isEmpty) {
                              return Center(
                                child: Lottie.asset(AppImages.noData),
                              );
                            } else {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.list.length,
                                itemBuilder: (_, index) {
                                  final account = state.list[index];

                                  return InkWell(
                                    onTap: () {

                                    },
                                    child: CustomerCard(
                                      index: index,
                                      customerData: account,
                                    ),
                                  );
                                },
                              );
                            }
                          } else if (state is CustomerListFailed) {
                            return Center(
                                child: Text(
                                    'Failed to load customer: ${state.content}'));
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
                    child: Text('Filter',
                        style: AppTextStyle.cardLevelText(context)),
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

                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('Clear',
                              style: AppTextStyle.errorTextStyle(context)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close',
                              style: AppTextStyle.cardLevelText(context)),
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
