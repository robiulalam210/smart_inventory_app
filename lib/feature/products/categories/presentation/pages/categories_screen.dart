import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/categories/categories_bloc.dart';
import '../widget/widget.dart';
import 'categories_create.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late var dataBloc = context.read<CategoriesBloc>();

  @override
  void initState() {
    _fetchApiData();
    // TODO: implement initState
    super.initState();
  }


  void _fetchApiData({
    String filterText = '',
    String state = '',
    int pageNumber = 0,
  }) {
    context.read<CategoriesBloc>().add(
      FetchCategoriesList(
        context,
        filterText: filterText,
        state: state,
        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.bottomNavBg(context),
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
      child: Container(color: AppColors.bottomNavBg(context), child: buildContent()),
    );
  }

  Widget buildContent() {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: AppTextStyle.getResponsivePaddingBody(context),
      child: BlocListener<CategoriesBloc, CategoriesState>(
        listener: (context, state) {
          if (state is CategoriesAddLoading) {
            appLoader(context, "Creating categories, please wait...");
          } else if (state is CategoriesSwitchLoading) {
            appLoader(context, "Updating categories, please wait...");
          } else if (state is CategoriesDeleteLoading) {
            // appLoader(context, "Deleting categories, please wait...");
          } else if (state is CategoriesAddSuccess ||
              state is CategoriesSwitchSuccess ||
              state is CategoriesDeleteSuccess) {
            if (state is CategoriesDeleteSuccess) {
              showCustomToast(
              context: context,
              title: 'Success!',
              description: state.message,
              icon: Icons.check_circle,
              primaryColor: Colors.green,
            );
            }
            // Navigator.pop(context);
            if (state is CategoriesAddSuccess) {
              Navigator.pop(context);
            }
            _fetchApiData();
            context.read<CategoriesBloc>().clearData();
          } else if (state is CategoriesAddFailed ||
              state is CategoriesDeleteFailed) {
            Navigator.pop(context);
            if (state is CategoriesAddFailed) Navigator.pop(context);
            _fetchApiData();
          }
        },
        child: Column(
          children: [
            // Header with search and button
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title for mobile
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search field
                  CustomSearchTextFormField(
                    controller: dataBloc.filterTextController,
                    onChanged: (value) => _fetchApiData(filterText: value),
                    onClear: () {
                      dataBloc.filterTextController.clear();
                      _fetchApiData();
                    },
                    hintText: "Search categories...",
                    isRequiredLabel: false,
                    labelText: "",
                  ),
                  const SizedBox(height: 12),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      name: "Create Category",
                      onPressed: () {
                        context.read<CategoriesBloc>().nameController.clear();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: CategoriesCreate(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title for desktop/tablet
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: 350,
                        child: CustomSearchTextFormField(
                          controller: dataBloc.filterTextController,
                          onChanged: (value) => _fetchApiData(filterText: value),
                          onClear: () {
                            dataBloc.filterTextController.clear();
                            _fetchApiData();
                          },
                          hintText: "Search categories...",
                          isRequiredLabel: false,
                          labelText: "",
                        ),
                      ),
                      const SizedBox(width: 16),
                      AppButton(
                        name: "Create Category",
                        onPressed: () {
                          context.read<CategoriesBloc>().nameController.clear();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: CategoriesCreate(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 10),

            /// 👇 Expanded fixes layout overflow
            SizedBox(
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoriesListSuccess) {
                    if (state.list.isEmpty) {
                      return Center(child: Lottie.asset(AppImages.noData));
                    } else {
                      return isMobile
                          ? CategoriesListMobile(categories: state.list)
                          : CategoriesTableCard(categories: state.list);
                    }
                  } else if (state is CategoriesListFailed) {
                    return Center(
                      child: Text(
                        'Failed to load categories: ${state.content}',
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
