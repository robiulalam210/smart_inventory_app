import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/feature/products/groups/presentation/pages/create_groups.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_images.dart';
import '../../../../../core/configs/app_routes.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/configs/gaps.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../../../responsive.dart';
import '../bloc/groups/groups_bloc.dart';
import '../widget/widget.dart';


class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchApi();
  }

  void _fetchApi(
      {String filterText = '', int pageNumber = 0}) {
    context.read<GroupsBloc>().add(
      FetchGroupsList(context,
        filterText: filterText,
        state: context.read<GroupsBloc>().selectedState == "All"
            ? ""
            : context.read<GroupsBloc>().selectedState,
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
        child: Container(color: AppColors.bg, child: buildContent()),
      );
    }


  Widget buildContent() {
    return SizedBox(

      child: Container(
        padding:AppTextStyle.getResponsivePaddingBody(context),
        child: BlocListener<GroupsBloc, GroupsState>(
          listener: (context, state) {
            if (state is GroupsAddLoading) {
              appLoader(context, "Creating Group, please wait...");
            } else if (state is GroupsSwitchLoading) {
              appLoader(context, "Update Group, please wait...");
            }
            else if (state is GroupDeleteLoading) {
              appLoader(context, "Deleted Group, please wait...");
            }
            else if (state is GroupsAddSuccess) {
              // Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            }

            else if (state is GroupsSwitchSuccess) {
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            }

            else if (state is GroupDeleteSuccess) {
              showCustomToast(
                context: context,
                title: 'Success!',
                description: state.message,
                icon: Icons.check_circle,
                primaryColor: Colors.green,
              );

              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            }
            else if (state is GroupsAddFailed) {
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
            } else if (state is GroupDeleteFailed) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 350,
                      child: CustomSearchTextFormField(
                        controller: context.read<GroupsBloc>().filterTextController,
                        onChanged: (value) {
                          _fetchApi(
                            filterText: value,
                          );
                        },
                        isRequiredLabel: false,
                        hintText: "Name", // Pass dynamic hintText if needed
                      )),
                  gapW16,
                  AppButton(
                    name: "Create Groups ",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(child: GroupsCreate());
                        },
                      );
                    },
                  ),
                ],
              ),
              gapH8,
              SizedBox(
                // height: 500,
                child: BlocBuilder<GroupsBloc, GroupsState>(
                  builder: (context, state) {
                    if (state is GroupsListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GroupsListSuccess) {
                      if (state.list.isEmpty) {
                        return Center(
                          child: Lottie.asset(AppImages.noData),
                        );
                      } else {
                        return // In your parent widget
                          GroupsTableCard(
                            groups: state.list,
                            onGroupTap: () {
                              // Handle row tap if needed
                            },
                          );
                      }
                    } else if (state is GroupsListFailed) {
                      return Center(
                          child:
                          Text('Failed to load group: ${state.content}'));
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
    );

  }


}
