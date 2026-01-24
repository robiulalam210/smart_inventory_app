// features/products/sale_mode/presentation/screens/sale_mode_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_scaffold.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/sale_mode_bloc.dart';
import 'sale_mode_create_screen.dart';
import 'widgets/sale_mode_table_card.dart';

class SaleModeListScreen extends StatefulWidget {
  final String? baseUnitId;

  const SaleModeListScreen({super.key, this.baseUnitId});

  @override
  State<SaleModeListScreen> createState() => _SaleModeListScreenState();
}

class _SaleModeListScreenState extends State<SaleModeListScreen> {
  late var dataBloc = context.read<SaleModeBloc>();

  @override
  void initState() {
    _fetchApi();
    super.initState();
  }

  void _fetchApi({String filterText = '', int pageNumber = 0}) {
    context.read<SaleModeBloc>().add(
      FetchSaleModeList(
        context,
        filterText: filterText,
        pageNumber: pageNumber,
        baseUnitId: widget.baseUnitId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.baseUnitId != null ? "Unit Sale Modes" : "Sale Modes",
          style: AppTextStyle.titleMedium(context),
        ),
      ),
      floatingActionButton: widget.baseUnitId == null
          ? FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showCreateDialog(context),
        child:  Icon(Icons.add,color: AppColors.whiteColor(context),),
      )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchApi();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: BlocListener<SaleModeBloc, SaleModeState>(
                listener: (context, state) {
                  if (state is SaleModeAddLoading) {
                    appLoader(context, "Creating sale mode, please wait...");
                  } else if (state is SaleModeDeleteLoading) {
                    appLoader(context, "Deleting sale mode, please wait...");
                  } else if (state is SaleModeAddSuccess) {
                    Navigator.pop(context);
                    _fetchApi();
                    showCustomToast(
                      context: context,
                      title: 'Success!',
                      description: 'Sale mode saved successfully',
                      icon: Icons.check_circle,
                      primaryColor: Colors.green,
                    );
                  } else if (state is SaleModeDeleteSuccess) {
                    showCustomToast(
                      context: context,
                      title: 'Success!',
                      description: state.message,
                      icon: Icons.check_circle,
                      primaryColor: Colors.green,
                    );
                    Navigator.pop(context);
                    _fetchApi();
                  } else if (state is SaleModeAddFailed) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    appAlertDialog(
                      context,
                      state.content,
                      title: state.title,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
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
                    _buildSaleModesList(),
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeaderRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          hintText: "sale modes...",
          isRequiredLabel: false,
        ),
      ],
    );
  }

  Widget _buildSaleModesList() {
    return BlocBuilder<SaleModeBloc, SaleModeState>(
      builder: (context, state) {
        if (state is SaleModeListLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is SaleModeListSuccess) {
          if (state.list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Lottie.asset(AppImages.noData)),
            );
          } else {
            return SaleModeTableCard(saleModes: state.list);
          }
        } else if (state is SaleModeListFailed) {
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
              child: const SaleModeCreateScreen(),
            ),
          ),
        );
      },
    );
  }
}