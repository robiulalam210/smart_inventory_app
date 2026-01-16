import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '/feature/products/unit/presentation/pages/unit_create.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/unit/unti_bloc.dart';
import '../widget/widget.dart';

class MobileUnitScreen extends StatefulWidget {
  const MobileUnitScreen({super.key});

  @override
  State<MobileUnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<MobileUnitScreen> {
  late var dataBloc = context.read<UnitBloc>();

  @override
  void initState() {
    _fetchApiData();

    // TODO: implement initState
    super.initState();
  }

  void _fetchApiData({String filterText = '', int pageNumber = 0}) {
    context.read<UnitBloc>().add(
      FetchUnitList(context, filterText: filterText, pageNumber: pageNumber),
    );
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      appBar: AppBar(
        title: Text("Unit", style: AppTextStyle.titleMedium(context)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () {
          context.read<UnitBloc>().nameController.clear();
          context.read<UnitBloc>().shortNameController.clear();


          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: UnitCreate(),
                ),
              );
            },
          );


        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: ResponsiveCol(
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
                    showCustomToast(
                      context: context,
                      title: 'Success!',
                      description: state.message,
                      icon: Icons.check_circle,
                      primaryColor: Colors.green,
                    );

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
                child:  RefreshIndicator(
                  onRefresh: ()async{
                    _fetchApiData();
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      SizedBox(child:   Container(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        // width: 350,
                        child:  CustomSearchTextFormField(
                          controller: context.read<UnitBloc>().filterTextController,
                          onChanged: (value) {
                            _fetchApiData(filterText: value);
                          },
                          onClear: () {
                            context.read<UnitBloc>().filterTextController.clear();
                            _fetchApiData();
                            FocusScope.of(context).unfocus();
                          },
                          isRequiredLabel: false,
                          hintText: "Name", // Pass dynamic hintText if needed
                        ),
                      ),),


                        SizedBox(
                          child: BlocBuilder<UnitBloc, UnitState>(
                            builder: (context, state) {
                              if (state is UnitListLoading) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (state is UnitListSuccess) {
                                if (state.list.isEmpty) {
                                  return Center(child: Lottie.asset(AppImages.noData));
                                } else {
                                  return MobileUnitTableCard(units: state.list,);
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
            ),
          ),
        )
      ),
    );
  }



}
