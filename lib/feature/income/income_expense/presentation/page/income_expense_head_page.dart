import '../income_expense_bloc/income_expense_head_bloc.dart';
import '/core/core.dart';

import '../../../../../core/widgets/coustom_search_text_field.dart';
import 'income_expense_head_create.dart';
import 'widget/income_head_widget.dart';

class MobileIncomeHeadScreen extends StatefulWidget {
  const MobileIncomeHeadScreen({super.key});

  @override
  State<MobileIncomeHeadScreen> createState() => _IncomeHeadScreenState();
}

class _IncomeHeadScreenState extends State<MobileIncomeHeadScreen> {
  late IncomeHeadBloc dataBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataBloc = context.read<IncomeHeadBloc>();
      _fetchApiData();
    });
  }



  void _fetchApiData({String filterText = '', int pageNumber = 0}) {
    if (!mounted) return;
    context.read<IncomeHeadBloc>().add(
      FetchIncomeHeadList(
        context: context,
        filterText: filterText,
        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        child: Icon(Icons.add),
        onPressed: () => _showCreateDialog(context),
      ),
      appBar: AppBar(
        title: Text("Income Head", style: AppTextStyle.titleMedium(context)),
      ),
      body: SafeArea(
        child: SizedBox(
          child: RefreshIndicator(
            color: AppColors.primaryColor(context),
            onRefresh: () async {
              _fetchApiData();
            },
            child: Container(
              padding: AppTextStyle.getResponsivePaddingBody(context),
              child: BlocConsumer<IncomeHeadBloc, IncomeHeadState>(
                listener: (context, state) {
                  _handleBlocState(state);
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMobileHeader(context),
                        const SizedBox(height: 8),
                        _buildIncomeHeadList(state),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBlocState(IncomeHeadState state) {
    if (state is IncomeHeadAddLoading) {
      appLoader(context, "Creating Income Head, please wait...");
    } else if (state is IncomeHeadAddSuccess) {
      Navigator.pop(context);
      Navigator.pop(context);
      _fetchApiData();
    } else if (state is IncomeHeadAddFailed) {
      if (context.mounted) {
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
    }
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomSearchTextFormField(
                  isRequiredLabel: false,
                  controller: context
                      .read<IncomeHeadBloc>()
                      .filterTextController,
                  onChanged: (value) {
                    _fetchApiData(filterText: value);
                  },
                  onClear: () {
                    context.read<IncomeHeadBloc>().filterTextController.clear();
                    _searchController.clear();
                    _fetchApiData();
                  },
                  hintText: "Income head...",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeHeadList(IncomeHeadState state) {
    if (state is IncomeHeadListLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    } else if (state is IncomeHeadListSuccess) {
      if (state.list.isEmpty) {
        return Expanded(child: Center(child: Lottie.asset(AppImages.noData)));
      } else {
        return SizedBox(
          child: IncomeHeadTableCard(
            incomeHeads: state.list,
            onIncomeHeadTap: () {
              // Handle income head tap if needed
            },
          ),
        );
      }
    } else if (state is IncomeHeadListFailed) {
      return Expanded(
        child: Center(
          child: Text(
            'Failed to load: ${state.content}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Expanded(child: Center(child: Lottie.asset(AppImages.noData)));
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.isMobile(context)
                    ? AppSizes.width(context)
                    : AppSizes.width(context) * 0.5,
                maxHeight: AppSizes.height(context) * 0.7,
              ),
              child: const IncomeHeadCreate(),
            ),
          ),
        );
      },
    );
  }
}