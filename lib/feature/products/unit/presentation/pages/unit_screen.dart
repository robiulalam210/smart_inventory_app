import 'package:smart_inventory/feature/products/unit/presentation/pages/unit_create.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../bloc/unit/unti_bloc.dart';
import '../widget/widget.dart';

class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  late var dataBloc = context.read<UnitBloc>();

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

  void _fetchApiData({String filterText = '', int pageNumber = 0}) {
    context.read<UnitBloc>().add(
      FetchUnitList(context, filterText: filterText, pageNumber: pageNumber),
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
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<UnitBloc, UnitState>(
            listener: (context, state) {
              if (state is UnitAddLoading) {
                appLoader(context, "Creating unit, please wait...");
              }
              if (state is UnitUpdateLoading) {
                appLoader(context, "Update unit, please wait...");
              } else if (state is UnitDeleteLoading) {
                appLoader(context, "Deleted unit, please wait...");
              } else if (state is UnitAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApiData(); // Reload warehouse list
              } else if (state is UnitUpdateSuccess) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApiData(); // Reload warehouse list
              } else if (state is UnitDeleteSuccess) {
                Navigator.pop(context); // Close loader dialog
                _fetchApiData(); // Reload warehouse list
              } else if (state is UnitAddFailed) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
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
              } else if (state is UnitUpdateFailed) {
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
                Row(children: [
                  Expanded(
                    child:  CustomSearchTextFormField(
                      controller: context.read<UnitBloc>().filterTextController,
                      onChanged: (value) {
                        _fetchApiData(filterText: value);
                      },
                      onClear: () {
                        context.read<UnitBloc>().filterTextController.clear();
                        _fetchApiData();
                      },
                      isRequiredLabel: false,
                      hintText: "Name", // Pass dynamic hintText if needed
                    ),
                  ),

                  gapW16,
                  AppButton(
                    name: "Create Unit ",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(child: UnitCreate());
                        },
                      );

                    },
                  ),
                ],),


                SizedBox(
                  child: BlocBuilder<UnitBloc, UnitState>(
                    builder: (context, state) {
                      if (state is UnitListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is UnitListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return UnitTableCard(units: state.list,);
                        }
                      } else if (state is UnitListFailed) {
                        return Center(
                          child: Text(
                            'Failed to load unit screen: ${state.content}',
                          ),
                        );
                      } else {
                        return Container();
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
