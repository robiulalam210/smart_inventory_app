import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
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
                                child: AccountCard( accounts: state.list,),
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
            hintText: "Search Account Name or Number",
          ),
        ),
        const SizedBox(width: 10),

        // 🏦 Account Type Dropdown
        Expanded(
          child: AppDropdown<String>(
            context: context,
            hint: "Select Account Type",
            isNeedAll: true,
            isLabel: false,
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
            ), label: '',
          ),
        ),
        gapW16,
        AppButton(
          name: "Create Account", // Fixed button text
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SizedBox(
                    width: AppSizes.width(context) * 0.50,
                    child: CreateAccountScreen(),
                  ),
                );
              },
            );
          },
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


}