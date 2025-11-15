import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
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
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   dataBloc.filterTextController = TextEditingController();
  //   _fetchApiData();
  // }
  //
  // @override
  // void dispose() {
  //   dataBloc.filterTextController.dispose();
  //   super.dispose();
  // }

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

            // Navigator.pop(context);
            if (state is CategoriesAddSuccess) Navigator.pop(context);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    hintText: "Name",
                    isRequiredLabel: false,
                    labelText: "",
                  ),
                ),
                gapW16,
                AppButton(
                  name: "Create Categories ",
                  onPressed: () {
                    context.read<CategoriesBloc>().nameController.clear();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(child: CategoriesCreate());
                      },
                    );
                  },
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
                      return CategoriesTableCard(categories: state.list);
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
