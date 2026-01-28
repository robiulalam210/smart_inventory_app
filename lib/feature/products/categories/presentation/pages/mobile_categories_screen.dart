import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/categories/categories_bloc.dart';
import '../widget/widget.dart';
import 'categories_create.dart';

class MobileCategoriesScreen extends StatefulWidget {
  const MobileCategoriesScreen({super.key});

  @override
  State<MobileCategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<MobileCategoriesScreen> {
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

    return AppScaffold(
      appBar: AppBar(
        title: Text("Categories", style: AppTextStyle.titleMedium(context)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () {
          context.read<CategoriesBloc>().nameController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CategoriesCreate()),
              );
            },
          );
        },
        child: Icon(Icons.add,color: AppColors.whiteColor(context),),
      ),
      body: SafeArea(
        child: Padding(
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with search and button

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: CustomSearchTextFormField(
                          controller: dataBloc.filterTextController,
                          onChanged: (value) => _fetchApiData(filterText: value),
                          onClear: () {
                            dataBloc.filterTextController.clear();
                            _fetchApiData();
                            FocusScope.of(context).unfocus();

                          },
                          hintText: "categories...",
                          isRequiredLabel: false,
                          labelText: "",
                        ),
                      ),
                    ],
                  ),


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
                            return CategoriesListMobile(categories: state.list)
                                ;
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
          ),
        )
      ),
    );
  }





}
