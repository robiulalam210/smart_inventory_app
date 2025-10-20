


import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../products/soruce/presentation/bloc/source/source_bloc.dart';
import '../bloc/supplier/supplier_list_bloc.dart';
import '../widget/widget.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {

  late var dataBloc=context.read<SupplierListBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize sourceBloc here

    // Now, you can safely access the SourceBloc and initialize the filterTextController
    dataBloc.filterTextController = TextEditingController();
    _fetchApi();
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
    context.read<SourceBloc>().add(
      FetchSourceList(
        context,
      ),
    );

  }

  void _fetchApi(
      {String filterText = '', String status = '', int pageNumber = 0}) {
    context.read<SupplierListBloc>().add(
      FetchSupplierList(context,
        filterText: filterText,
        state: status,
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
          child: BlocListener<SupplierListBloc, SupplierListState>(
            listener: (context, state) {
              if (state is SupplierAddLoading) {
                appLoader(context, "Creating Supplier, please wait...");
              } else if (state is SupplierAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApi(); // Reload warehouse list
              } else if (state is SupplierAddFailed) {
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
                          context.read<SupplierListBloc>().filterTextController,
                          onClear: () {
                            _fetchApi();
                            context.read<SupplierListBloc>().filterTextController.clear();
                          },
                          onChanged: (value) {
                            _fetchApi(
                              filterText: value,
                            );
                          },
                          hintText: "Search Name", // Pass dynamic hintText if needed
                        )),
                    CustomFilterBox(
                      onTapDown: (TapDownDetails details) {
                        _showFilterMenu(context, details.globalPosition);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  child: BlocBuilder<SupplierListBloc, SupplierListState>(
                    builder: (context, state) {
                      if (state is SupplierListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SupplierListSuccess) {
                        Text(state.list.toString());

                        if (state.list.isEmpty) {
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );
                        } else {
                          return SupplierDataTableWidget(suppliers: state.list,);
                        }
                      } else if (state is SupplierListFailed) {
                        return Center(
                            child:
                            Text('Failed to load account: ${state.content}'));
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
        )
      );
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 10, left: 10, right: 10),
                      decoration: const BoxDecoration(
                        // borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromARGB(255, 248, 248, 248),
                      ),
                      child:  Text('Filter',style:AppTextStyle.cardLevelText(context)),
                    ),
                    AppDropdown(
                      label: "Status ",context: context,
                      hint: "Select Status",
                      isLabel: true,
                      isNeedAll: true,
                      value: context.read<SupplierListBloc>().selectedState.isEmpty
                          ? null
                          : context.read<SupplierListBloc>().selectedState,
                      itemList: context.read<SupplierListBloc>().statesList,
                      onChanged: (newVal) {
                        context.read<SupplierListBloc>().selectedState =
                            newVal.toString();
                        _fetchApi(
                          filterText: context
                              .read<SupplierListBloc>()
                              .filterTextController
                              .text,
                          status:
                          newVal.toString() == "All" ? "" : newVal.toString(),
                        );
                      },
                      itemBuilder: (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            color: AppColors.blackColor,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

                                context.read<SupplierListBloc>().add(
                                  FetchSupplierList(context,),
                                );
                              });
                              Navigator.of(context).pop();
                            },
                            child:  Text(
                                'Clear',
                                style:AppTextStyle.errorTextStyle(context)
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child:  Text('Close',style:AppTextStyle.cardLevelText(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
