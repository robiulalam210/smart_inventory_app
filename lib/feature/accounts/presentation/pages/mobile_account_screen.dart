
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../data/model/account_model.dart';
import '../bloc/account/account_bloc.dart';
import '../widget/widget.dart';
import 'create_account_screen.dart';
import 'mobile_create_account_screen.dart';

class MobileAccountScreen extends StatefulWidget {
  const MobileAccountScreen({super.key});

  @override
  State<MobileAccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<MobileAccountScreen> {
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedAccountTypeNotifier = ValueNotifier(
    null,
  );

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchApi();
    });
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedAccountTypeNotifier.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String accountType = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<AccountBloc>().add(
      FetchAccountList(
        context,
        filterText: filterText,
        accountType: accountType,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchAccountList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: filterTextController.text,
      accountType: selectedAccountTypeNotifier.value?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showCreateAccountDialog(context),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Account", style: AppTextStyle.titleMedium(context)),
      ),
      body: SafeArea(child: _buildContentArea()),
    );
  }

  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: RefreshIndicator(
        color: AppColors.primaryColor(context),
        onRefresh: () async {
          _fetchApi();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {
              _handleBlocState(state);
            },
            builder: (context, state) {
              return  SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildMobileHeader(),
                    const SizedBox(height: 8),
                    SizedBox(child: _buildAccountList(state)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBlocState(AccountState state) {
    if (state is AccountAddLoading) {
      appLoader(context, "Processing account, please wait...");
    } else if (state is AccountAddSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is AccountAddFailed) {
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
    } else if (state is AccountDeleteLoading) {
      appLoader(context, "Deleting Account, please wait...");
    } else if (state is AccountDeleteSuccess) {
      if (context.mounted) {
        showCustomToast(
          context: context,
          title: 'Success!',
          description: state.message,
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
        Navigator.pop(context);
        _fetchApi();
      }
    } else if (state is AccountDeleteFailed) {
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

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: CustomSearchTextFormField(
                  isRequiredLabel: false,
                  controller: filterTextController,
                  onChanged: (value) => _fetchApi(filterText: value),
                  onClear: () {
                    filterTextController.clear();
                    _fetchApi();
                    FocusScope.of(context).unfocus();

                  },
                  hintText: "accounts...",
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(
                Iconsax.filter,
                color: AppColors.primaryColor(context),
              ),
              onPressed: () => _showMobileFilterSheet(context),
            ),
            IconButton(
              onPressed: (){
                _clearAccountBlocData();

                _fetchApi();
              },
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
          ],
        ),

        // Filter Chips
        ValueListenableBuilder<String?>(
          valueListenable: selectedAccountTypeNotifier,
          builder: (context, accountType, child) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (accountType != null && accountType != "All")
                  Chip(
                    label: Text(accountType),
                    onDeleted: () {
                      selectedAccountTypeNotifier.value = null;
                      _fetchApi();
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountList(AccountState state) {
    if (state is AccountListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is AccountListSuccess) {
      if (state.list.isEmpty) {
        return Center(child: Lottie.asset(AppImages.noData));
      } else {
        return Column(
          children: [
            SizedBox(
              child: AccountCard(
                accounts: state.list,
                onEdit: (account) => _showEditDialog(context, account, false),
                onDelete: (account) async {
                  final shouldDelete = await showDeleteConfirmationDialog(
                    context,
                  );
                  if (!shouldDelete) return;

                  if (context.mounted) {
                    context.read<AccountBloc>().add(
                      DeleteAccount(account.id.toString()),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            PaginationBar(
              count: state.count,
              totalPages: state.totalPages,
              currentPage: state.currentPage,
              pageSize: state.pageSize,
              from: state.from,
              to: state.to,
              onPageChanged: (page) =>
                  _fetchAccountList(pageNumber: page, pageSize: state.pageSize),
              onPageSizeChanged: (newSize) =>
                  _fetchAccountList(pageNumber: 1, pageSize: newSize),
            ),
          ],
        );
      }
    } else if (state is AccountListFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load accounts',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.content,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(name: "Retry", onPressed: () => _fetchApi()),
          ],
        ),
      );
    } else {
      return Center(child: Lottie.asset(AppImages.noData));
    }
  }

  void _showCreateAccountDialog(BuildContext context) {
    _clearAccountBlocData();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: const MobileCreateAccountScreen(),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    AccountModel account,
    bool isMobile,
  ) {
    _clearAccountBlocData();

    final accountBloc = context.read<AccountBloc>();
    accountBloc.accountNameController.text = account.name ?? "";
    accountBloc.accountNumberController.text = account.acNumber ?? "";
    accountBloc.bankNameController.text = account.bankName ?? "";
    accountBloc.branchNameController.text = account.branch ?? "";
    accountBloc.accountOpeningBalanceController.text =
        account.balance?.toString() ?? "0.0";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
            child: CreateAccountScreen(
              id: account.id.toString(),
              submitText: "Update Account",
              account: account,
            ),
          ),
        );
      },
    );
  }

  void _clearAccountBlocData() {
    final accountBloc = context.read<AccountBloc>();
    accountBloc.accountNameController.clear();
    accountBloc.accountNumberController.clear();
    accountBloc.bankNameController.clear();
    accountBloc.branchNameController.clear();
    accountBloc.accountOpeningBalanceController.clear();
    selectedAccountTypeNotifier.value=null;
    accountBloc.selectedState = "";
    filterTextController.clear();
    selectedAccountTypeNotifier.value = null;
  }

  void _showMobileFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Filter Accounts",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.text(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Account Type Filter
                     Text(
                      "Account Type",
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: ["All", "Cash", "Bank", "Mobile Banking"].map((
                        type,
                      ) {
                        final bool isSelected =
                            selectedAccountTypeNotifier.value == type ||
                            (type == "All" &&
                                selectedAccountTypeNotifier.value == null);
                        return FilterChip(
                          label: Text(type, style: AppTextStyle.body(context)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedAccountTypeNotifier.value = selected
                                  ? type
                                  : null;
                            });
                          },
                          selectedColor: AppColors.primaryColor(
                            context,
                          ).withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primaryColor(context),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                filterTextController.clear();
                                selectedAccountTypeNotifier.value = null;
                              });
                              Navigator.pop(context);
                              _fetchApi();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Clear All",
                              style: AppTextStyle.body(
                                context,
                              ).copyWith(color: AppColors.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _fetchApi(
                                filterText: filterTextController.text,
                                accountType:
                                    selectedAccountTypeNotifier.value
                                        ?.toLowerCase() ??
                                    '',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor(context),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:  Text("Apply Filters",style: AppTextStyle.body(
                              context,
                            ).copyWith(color: AppColors.text(context)),),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
