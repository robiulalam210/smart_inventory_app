import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '/feature/products/groups/presentation/pages/create_groups.dart';
import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_images.dart';
import '../../../../../core/configs/app_routes.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/configs/gaps.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../../../responsive.dart';
import '../bloc/groups/groups_bloc.dart';
import '../widget/widget.dart';

class MobileGroupsScreen extends StatefulWidget {
  const MobileGroupsScreen({super.key});

  @override
  State<MobileGroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<MobileGroupsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchApi();
  }

  void _fetchApi({String filterText = '', int pageNumber = 0}) {
    context.read<GroupsBloc>().add(
      FetchGroupsList(
        context,
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
      appBar: AppBar(title: Text("Group",style: AppTextStyle.titleMedium(context),),),
      floatingActionButton: FloatingActionButton( onPressed: () => _showCreateDialog(context),child: Icon(Icons.add),),
      body: SafeArea(
        child:ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: Container(
            color: AppColors.bottomNavBg(context),
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchApi();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(12)
                  ,
                  child: buildContent(),
                ),
              ),
            ),
          ),
        )
      ),
    );
  }


  Widget buildContent() {
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GroupsAddLoading) {
          appLoader(context, "Creating Group, please wait...");
        } else if (state is GroupsSwitchLoading) {
          appLoader(context, "Update Group, please wait...");
        } else if (state is GroupDeleteLoading) {
          appLoader(context, "Deleted Group, please wait...");
        } else if (state is GroupsAddSuccess) {
          Navigator.pop(context);
          _fetchApi();
        } else if (state is GroupsSwitchSuccess) {
          Navigator.pop(context);
          _fetchApi();
        } else if (state is GroupDeleteSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: state.message,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
          Navigator.pop(context);
          _fetchApi();
        } else if (state is GroupsAddFailed) {
          Navigator.pop(context);
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
        } else if (state is GroupDeleteFailed) {
          Navigator.pop(context);
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Row
            _buildHeaderRow(),
            gapH8,
            // Groups List
            _buildGroupsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field
          CustomSearchTextFormField(
            controller: context.read<GroupsBloc>().filterTextController,
            onChanged: (value) {
              _fetchApi(filterText: value);
            },
            isRequiredLabel: false,
            hintText: "group name",
          ),
         
        ],
      );



  }

  Widget _buildGroupsList() {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state is GroupsListLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is GroupsListSuccess) {
          if (state.list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Lottie.asset(AppImages.noData),
              ),
            );
          } else {
            return GroupsTableCard(
              groups: state.list,
              onGroupTap: () {},
            );
          }
        } else if (state is GroupsListFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Failed to load groups: ${state.content}'),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.9
                : MediaQuery.of(context).size.width * 0.5,
            child: const GroupsCreate(),
          ),
        );
      },
    );
  }
}