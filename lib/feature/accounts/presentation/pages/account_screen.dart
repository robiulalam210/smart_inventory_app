import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../data/model/account_model.dart';
import '../bloc/account/account_bloc.dart';
import '../widget/widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  TextEditingController filterTextController = TextEditingController();
  ValueNotifier<String?> selectedAccountTypeNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    _fetchApi();
  }

  void _fetchApi({
    String filterText = '',
    String accountType = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
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
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          _fetchApi();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<AccountBloc, AccountState>(
            listener: (context, state) {
              if (state is AccountAddLoading) {
                appLoader(context, "Creating account, please wait...");
              } else if (state is AccountAddSuccess) {
                Navigator.pop(context);
                _fetchApi();
              } else if (state is AccountAddFailed) {
                Navigator.pop(context);
                _fetchApi();
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
                _buildFilterRow(),
                const SizedBox(height: 16),
                SizedBox(
                  child: BlocBuilder<AccountBloc, AccountState>(
                    builder: (context, state) {
                      if (state is AccountListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is AccountListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                child: _buildAccountTable(state.list),
                              ),
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
                          child: Text(
                            'Failed to load account: ${state.content}',
                          ),
                        );
                      } else {
                        return Center(child: Lottie.asset(AppImages.noData));
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

  Widget _buildFilterRow() {
    return Row(
      children: [
        // 🔍 Search Field
        Expanded(
          child: CustomSearchTextFormField(
            controller: filterTextController,
            onChanged: (value) => _fetchApi(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchApi();
            },
            hintText: "Search Account Name or Number",
          ),
        ),
        const SizedBox(width: 10),

        // 🏦 Account Type Dropdown
        Expanded(
          child: AppDropdown<String>(
            label: "Account Type",
            context: context,
            hint: "Select Account Type",
            isNeedAll: true,
            isRequired: false,
            value: selectedAccountTypeNotifier.value,
            itemList: ['Cash', 'Bank', 'Credit Card', 'Loan', 'Investment', 'Other'],
            onChanged: (newVal) {
              selectedAccountTypeNotifier.value = newVal;
              _fetchApi(
                accountType: newVal?.toLowerCase() ?? '',
              );
            },
            validator: (value) => null,
            itemBuilder: (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildAccountTable(List<AccountModel> accounts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 16,
          headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => AppColors.primaryColor.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Account Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Account Number', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: accounts.asMap().entries.map((entry) {
            final account = entry.value;
            final index = entry.key + 1;

            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(account.acName ?? 'N/A')),
                DataCell(Text(account.acNumber ?? 'N/A')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getAccountTypeColor(account.acType),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      account.acType ?? 'N/A',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${account.balance?.toString() ?? '0.00'}',
                    style: TextStyle(
                      color: (double.tryParse(account.balance.toString()) ?? 0) >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (account.bankName == 'active') ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      account.bankName ?? 'inactive',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          // Edit account action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () {
                          // Delete account action
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getAccountTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'credit card':
        return Colors.orange;
      case 'loan':
        return Colors.red;
      case 'investment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}