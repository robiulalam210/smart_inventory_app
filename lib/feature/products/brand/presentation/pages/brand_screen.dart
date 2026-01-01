import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
import '../bloc/brand/brand_bloc.dart';
import '../widget/widget.dart';
import 'create_brand/create_brand_setup.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  late var dataBloc = context.read<BrandBloc>();

  @override
  void initState() {
    _fetchApi();
    super.initState();
  }

  void _fetchApi({String filterText = '', int pageNumber = 0}) {
    context.read<BrandBloc>().add(
      FetchBrandList(context, filterText: filterText, pageNumber: pageNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          spacing: 0,
          runSpacing: 0,
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen, isMobile),
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

  Widget _buildContentArea(bool isBigScreen, bool isMobile) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: RefreshIndicator(
        onRefresh: () async {
          _fetchApi();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: isMobile
                ? const EdgeInsets.all(12)
                : AppTextStyle.getResponsivePaddingBody(context),
            child: buildContent(isMobile),
          ),
        ),
      ),
    );
  }

  Widget buildContent(bool isMobile) {
    return BlocListener<BrandBloc, BrandState>(
      listener: (context, state) {
        if (state is BrandAddLoading) {
          appLoader(context, "Creating brand, please wait...");
        } else if (state is BrandDeleteLoading) {
          appLoader(context, "Deleting brand, please wait...");
        } else if (state is BrandAddSuccess) {
          Navigator.pop(context);
          Navigator.pop(context);
          _fetchApi();
        } else if (state is BrandDeleteSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: state.message,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
          Navigator.pop(context);
          _fetchApi();
        } else if (state is BrandAddFailed) {
          Navigator.pop(context);
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
      child: Column(
        children: [
          _buildHeaderRow(isMobile),
          const SizedBox(height: 16),
          _buildBrandsList(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field
          CustomSearchTextFormField(
            controller: dataBloc.filterTextController,
            onClear: () {
              dataBloc.filterTextController.clear();
              _fetchApi();
            },
            onChanged: (value) {
              _fetchApi(filterText: value);
            },
            hintText: "Search brand name",
            isRequiredLabel: false,
          ),
          const SizedBox(height: 12),
          // Create Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              name: "Create Brand",
              onPressed: () => _showCreateDialog(context),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 350,
          child: CustomSearchTextFormField(
            controller: dataBloc.filterTextController,
            onClear: () {
              dataBloc.filterTextController.clear();
              _fetchApi();
            },
            onChanged: (value) {
              _fetchApi(filterText: value);
            },
            hintText: "Search brand name",
            isRequiredLabel: false,
          ),
        ),
        gapW16,
        AppButton(
          name: "Create Brand",
          onPressed: () => _showCreateDialog(context),
        ),
      ],
    );
  }

  Widget _buildBrandsList() {
    return BlocBuilder<BrandBloc, BrandState>(
      builder: (context, state) {
        if (state is BrandListLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is BrandListSuccess) {
          if (state.list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Lottie.asset(AppImages.noData)),
            );
          } else {
            return BrandTableCard(brands: state.list);
          }
        } else if (state is BrandListFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Failed to load: ${state.content}'),
            ),
          );
        } else {
          return const SizedBox.shrink();
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
            child: const BrandCreate(),
          ),
        );
      },
    );
  }
}