import 'package:dokani_360/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../blocs/products/groups/groups_bloc.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_images.dart';
import '../../../configs/app_routes.dart';
import '../../../configs/app_text.dart';
import '../../../widgets/app_alert_dialog.dart';
import '../../../widgets/app_dropdown.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/coustom_filter_ui.dart';
import '../../../widgets/coustom_search_text_field.dart';
import '../../../widgets/pagination_bar.dart';
import 'create_groups/create_groups_setup.dart';
import 'widget/widget.dart';

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
      {String filterText = '', String state = '', int pageNumber = 0}) {
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: appBar(title: "Groups List", context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setupGroups(context, "Create Groups", "Create", id: "");
        },
        backgroundColor: AppColors.whiteColor,
        child: const Icon(
          Icons.add,
          color: AppColors.primaryColor,
        ),
      ),
      body: Container(
        padding:AppTextStyle.getResponsivePaddingBody(context),
        child: BlocListener<GroupsBloc, GroupsState>(
          listener: (context, state) {
            if (state is GroupsAddLoading) {
              appLoader(context, "Creating Group, please wait...");
            } else if (state is GroupsSwitchLoading) {
              appLoader(context, "Update Group, please wait...");
            } else if (state is GroupsAddSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            } else if (state is GroupsSwitchSuccess) {
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            } else if (state is GroupsAddFailed) {
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
                        controller: context.read<GroupsBloc>().filterTextController,
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
              Expanded(
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
                        return Column(
                          children: [
                            const SizedBox(height: 5),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.list.length,
                                itemBuilder: (_, index) {
                                  final warehouse = state.list[index];
                                  return GroupsCard(
                                      group: warehouse, index: index + 1);
                                },
                              ),
                            ),
                            PaginationBar(
                              totalPages: state.totalPages,
                              currentPage: state.currentPage,
                              onPageSelected: (page) {
                                _fetchApi(
                                  filterText: context
                                      .read<GroupsBloc>()
                                      .filterTextController
                                      .text,
                                  pageNumber: page,
                                );
                              },
                              activeColor: AppColors.primaryColor,
                              inactiveColor: AppColors.grey,
                            ),
                          ],
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
                    child: const Text('Filter'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppDropdown(
                      label: "Status",context: context,
                      hint: "Select Status",
                      isLabel: true,
                      isNeedAll: true,
                      value: context.read<GroupsBloc>().selectedState.isEmpty
                          ? null
                          : context.read<GroupsBloc>().selectedState,
                      itemList: context.read<GroupsBloc>().statesList,
                      onChanged: (newVal) {
                        context.read<GroupsBloc>().selectedState =
                            newVal.toString();
                        _fetchApi(
                          filterText: context
                              .read<GroupsBloc>()
                              .filterTextController
                              .text,
                          state:
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
                              context.read<GroupsBloc>().add(
                                FetchGroupsList(context,),
                              );
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
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
}
