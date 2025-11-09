
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../bloc/users/user_bloc.dart';
import '../widget/widget.dart';



class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();

    _fetchApi();
  }

  void _fetchApi({String filterText = '', int pageNumber = 0}) {
    context.read<UserBloc>().add(
      FetchUserList(context,
        filterText: filterText,
        pageNumber: pageNumber,
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
                    child:  Text('Filter', style:AppTextStyle.cardLevelText(context),),
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
                              context.read<UserBloc>().add(
                                FetchUserList(context,),
                              );
                            });
                            Navigator.of(context).pop();
                          },
                          child:  Text(
                            'Clear',
                            style:AppTextStyle.errorTextStyle(context),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child:  Text('Close', style:AppTextStyle.cardLevelText(context),),
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
      child:Container(
        padding:AppTextStyle.getResponsivePaddingBody(context),
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserAddLoading) {
              appLoader(context, "User, please wait...");
            } else if (state is UserAddSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            } else if (state is UserSwitchLoading) {
              appLoader(context, "Update User, please wait...");
            } else if (state is UserSwitchSuccess) {
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            } else if (state is UserSwitchFailed) {
              Navigator.pop(context);
              appAlertDialog(context, state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                        onPressed: () => AppRoutes.pop(context),
                        child: const Text("Dismiss"))
                  ]); // Close loader dialog
              _fetchApi(); // Reload warehouse list
            } else if (state is UserAddFailed) {
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
                  SizedBox(
                    width: 400,
                    child: CustomSearchTextFormField(
                      controller: context.read<UserBloc>().filterTextController,
                      onChanged: (value) {
                        _fetchApi(
                          filterText: value,
                        );
                      },

                      onClear: () {
                        _fetchApi();
                        context.read<UserBloc>().filterTextController.clear();
                      },
                      hintText:
                      "by Name,Email or Phone number", // Pass dynamic hintText if needed
                    ),
                  ),

                ],
              ),
              gapH8,
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserListSuccess) {
                    if (state.list.isEmpty) {
                      return Center(
                        child: Lottie.asset(AppImages.noData),
                      );
                    } else {
                      return UserTableCard(users: state.list,);

                    }
                  } else if (state is UserListFailed) {
                    return Center(
                        child: Text('Failed to load User: ${state.content}'));
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
