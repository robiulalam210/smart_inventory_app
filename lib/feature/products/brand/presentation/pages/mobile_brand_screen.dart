import 'package:meherinMart/core/configs/configs.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/brand/brand_bloc.dart';
import '../widget/widget.dart';
import 'create_brand/create_brand_setup.dart';

class MobileBrandScreen extends StatefulWidget {
  const MobileBrandScreen({super.key});

  @override
  State<MobileBrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<MobileBrandScreen> {
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
    return AppScaffold(
      appBar: AppBar(
        title: Text("Brand", style: AppTextStyle.titleMedium(context)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showCreateDialog(context),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchApi();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
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
          _buildHeaderRow(),
          const SizedBox(height: 8),
          _buildBrandsList(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Field
        CustomSearchTextFormField(
          controller: dataBloc.filterTextController,
          onClear: () {
            dataBloc.filterTextController.clear();
            _fetchApi();
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            _fetchApi(filterText: value);
          },
          hintText: "brand name",
          isRequiredLabel: false,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: SizedBox(
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.5,
              child: const BrandCreate(),
            ),
          ),
        );
      },
    );
  }
}
