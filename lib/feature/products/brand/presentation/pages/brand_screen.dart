import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_images.dart';
import '../../../../../core/configs/app_routes.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataBloc.filterTextController = TextEditingController();
    _fetchApi();
  }

  @override
  void dispose() {
    dataBloc.filterTextController.dispose();
    super.dispose();
  }

  void _fetchApi({String filterText = '', int pageNumber = 0}) {
    context.read<BrandBloc>().add(
      FetchBrandList(
        context,
        filterText: filterText,
        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTextStyle.getResponsivePaddingBody(context),
      child: BlocListener<BrandBloc, BrandState>(
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
            CustomSearchTextFormField(
              controller: dataBloc.filterTextController,
              onClear: () {
                dataBloc.filterTextController.clear();
                _fetchApi();
              },
              onChanged: (value) {
                _fetchApi(filterText: value);
              },
              hintText: "Search Name",
            ),
            const SizedBox(height: 10),

            /// 👇 Expanded fixes unbounded height issue
            SizedBox(

              height: 500,
              child: BlocBuilder<BrandBloc, BrandState>(
                builder: (context, state) {
                  if (state is BrandListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BrandListSuccess) {
                    if (state.list.isEmpty) {
                      return Center(
                        child: Lottie.asset(AppImages.noData),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.list.length,
                        itemBuilder: (_, index) {
                          final brand = state.list[index];
                          return BrandCard(
                            brand: brand,
                            index: index + 1,
                          );
                        },
                      );
                    }
                  } else if (state is BrandListFailed) {
                    return Center(
                        child: Text('Failed to load: ${state.content}'));
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
