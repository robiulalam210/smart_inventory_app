import '/feature/products/soruce/presentation/pages/soruce_create.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/source/source_bloc.dart';
import '../widget/widget.dart';

class SourceScreen extends StatefulWidget {
  const SourceScreen({super.key});

  @override
  State<SourceScreen> createState() => _SourceScreenState();
}

class _SourceScreenState extends State<SourceScreen> {
  late var sourceBloc = context.read<SourceBloc>();

  @override
  void initState() {
    _fetchApiData();
    // TODO: implement initState
    super.initState();
  }

  void _fetchApiData({String filterText = '', int pageNumber = 0}) {
    context.read<SourceBloc>().add(
      FetchSourceList(context, filterText: filterText, pageNumber: pageNumber),
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
      child: SizedBox(
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<SourceBloc, SourceState>(
            listener: (context, state) {
              if (state is SourceAddLoading) {
                appLoader(context, "Creating Source, please wait...");
              }
              if (state is SourceUpdateLoading) {
                // appLoader(context, "Update Source, please wait...");
              } else if (state is SourceDeleteLoading) {
                appLoader(context, "Deleted Source, please wait...");
              } else if (state is SourceAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
                _fetchApiData(); // Reload warehouse list
              } else if (state is SourceUpdateSuccess) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
                _fetchApiData(); // Reload warehouse list
              } else if (state is SourceDeleteSuccess) {
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: state.message,
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );
                Navigator.pop(context); // Close loader dialog
                _fetchApiData(); // Reload warehouse list
              } else if (state is SourceAddFailed) {
                // Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApiData();
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
              } else if (state is SourceUpdateFailed) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
                _fetchApiData();
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 350,
                      child: CustomSearchTextFormField(
                        controller: context
                            .read<SourceBloc>()
                            .filterTextController,
                        onClear: () {
                          context
                              .read<SourceBloc>()
                              .filterTextController
                              .clear();
                          _fetchApiData();
                        },
                        onChanged: (value) {
                          _fetchApiData(filterText: value);
                        },
                        isRequiredLabel: false,
                        hintText: "Name", // Pass dynamic hintText if needed
                      ),
                    ),
                    gapW16,
                    AppButton(
                      name: "Create Source ",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radius,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radius,
                                ),
                                child: SizedBox(
                                  width: Responsive.isMobile(context)
                                      ? MediaQuery.of(context).size.width * 0.9
                                      : MediaQuery.of(context).size.width * 0.5,
                                  child: SourceCreate(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                gapH8,
                SizedBox(
                  child: BlocBuilder<SourceBloc, SourceState>(
                    builder: (context, state) {
                      if (state is SourceListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SourceListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return SourceTableCard(sources: state.list);
                        }
                      } else if (state is SourceListFailed) {
                        return Center(
                          child: Text('Failed to load : ${state.content}'),
                        );
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
      ),
    );
  }
}
