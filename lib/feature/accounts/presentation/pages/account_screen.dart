
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../data/model/account_model.dart';
import '../bloc/account/account_bloc.dart';
import '../widget/widget.dart';
import 'create_account_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedAccountTypeNotifier = ValueNotifier(null);

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
              return Column(
                children: [
                    _buildDesktopHeader()
               ,

                  SizedBox(
                    child: _buildAccountList(state),
                  ),
                ],
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

  Widget _buildDesktopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔍 Search Field
        Expanded(
          child: CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: filterTextController,
            onChanged: (value) => _fetchApi(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchApi();
            },
            hintText: "Account Name or Number",
          ),
        ),
        const SizedBox(width: 10),

        // 🏦 Account Type Dropdown
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: selectedAccountTypeNotifier,
            builder: (context, value, child) {
              return AppDropdown<String>(
                hint: "Select Account Type",
                isNeedAll: true,
                isLabel: true,
                isRequired: false,
                value: value,
                itemList: ['Cash', 'Bank', 'Mobile Banking'],
                onChanged: (newVal) {
                  selectedAccountTypeNotifier.value = newVal;
                  _fetchApi(accountType: newVal?.toLowerCase() ?? '');
                },
                validator: (value) => null,
                
                label: '',
              );
            },
          ),
        ),
        gapW16,

        // ➕ Create Account Button
        AppButton(
          name: "Create Account",
          onPressed: () => _showCreateAccountDialog(context),
        ),

        gapW16,

        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
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
                  final shouldDelete = await showDeleteConfirmationDialog(context);
                  if (!shouldDelete) return;

                  if (context.mounted) {
                    context.read<AccountBloc>().add(
                      DeleteAccount(account.id.toString()),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            PaginationBar(
              count: state.count,
              totalPages: state.totalPages,
              currentPage: state.currentPage,
              pageSize: state.pageSize,
              from: state.from,
              to: state.to,
              onPageChanged: (page) => _fetchAccountList(
                pageNumber: page,
                pageSize: state.pageSize,
              ),
              onPageSizeChanged: (newSize) => _fetchAccountList(
                pageNumber: 1,
                pageSize: newSize,
              ),
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
            AppButton(
              name: "Retry",
              onPressed: () => _fetchApi(),
            ),
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
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context)
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.6,
              maxHeight: Responsive.isMobile(context)
                  ? AppSizes.height(context) * 0.8
                  : 350,
            ),
            child: const CreateAccountScreen(),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, AccountModel account, bool isMobile) {
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
              maxHeight: isMobile
                  ? AppSizes.height(context) * 0.8
                  : AppSizes.height(context) * 0.7,
            ),
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
    accountBloc.selectedState = "";
  }

}