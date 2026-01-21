import 'package:intl/intl.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import '/core/core.dart';
import '/feature/accounts/presentation/bloc/account/account_bloc.dart';
import '../../../accounts/data/model/account_active_model.dart';
import '../bloc/account_transfer/account_transfer_bloc.dart';
import 'mobile_account_transfer_screen.dart';

class MobileAccountTransferForm extends StatefulWidget {
  const MobileAccountTransferForm({super.key});

  @override
  State<MobileAccountTransferForm> createState() =>
      _MobileAccountTransferFormState();
}

class _MobileAccountTransferFormState extends State<MobileAccountTransferForm> {
  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  void _initializeData() {
    // Fetch available accounts
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<AccountTransferBloc>().add(
      FetchAvailableAccounts(context: context),
    );

    // Set default date
    final transferBloc = context.read<AccountTransferBloc>();
    transferBloc.dateController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AccountTransferBloc transferBloc;
  ValueNotifier<bool> isQuickTransfer = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    transferBloc = context.read<AccountTransferBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isQuickTransfer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchApi() {
    context.read<AccountTransferBloc>().add(
      FetchAccountTransferList(context: context, pageNumber: 1, pageSize: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "Account Transfer",
          style: AppTextStyle.titleMedium(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:  Icon(     HugeIcons.strokeRoundedReload,
              color: AppColors.primaryColor(context),),
            onPressed: () {
              transferBloc.add(ResetForm());
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: BlocListener<AccountTransferBloc, AccountTransferState>(
            listener: (context, state) {
              if (state is AccountTransferAddLoading ||
                  state is QuickTransferLoading ||
                  state is ExecuteTransferLoading) {
                appLoader(context, "Processing transfer...");
              } else if (state is AccountTransferAddSuccess) {

                _fetchApi();
                // _showSuccessDialog(
                //   "Transfer Created",
                //   "Transfer request created successfully. Use execute option to complete it.",
                // );
                Navigator.pop(context);

                AppRoutes.pushReplacement(context, MobileAccountTransferScreen());
              } else if (state is QuickTransferSuccess) {
                Navigator.pop(context);

                AppRoutes.pushReplacement(context, MobileAccountTransferScreen());
                _showSuccessDialog(
                  "Transfer Completed",
                  "Transfer completed successfully.",
                );
              } else if (state is AccountTransferAddFailed ||
                  state is QuickTransferFailed ||
                  state is ExecuteTransferFailed) {
                Navigator.pop(context);
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Transfer Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bottomNavBg(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quick Transfer",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primaryColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Complete transfer immediately",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.text(context),
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: isQuickTransfer,
                          builder: (context, isQuick, child) {
                            return Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isQuick,
                                onChanged: (value) {
                                  isQuickTransfer.value = value;
                                },
                                activeThumbColor: AppColors.primaryColor(context),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // From Account
                  _buildAccountSection(
                    title: "From Account",
                    isFromAccount: true,
                    context: context
                  ),
                  const SizedBox(height: 8),

                  // To Account
                  _buildAccountSection(
                    title: "To Account",
                    isFromAccount: false,
                    context: context
                  ),
                  const SizedBox(height: 8),

                  // Transfer Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bottomNavBg(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transfer Details",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.primaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Amount
                        _buildAmountField(),
                        const SizedBox(height: 8),

                        // Transfer Type
                        _buildTransferTypeField(),
                        const SizedBox(height: 8),

                        // Date
                        _buildDateField(),
                        const SizedBox(height: 8),

                        // Reference No
                        _buildReferenceField(),
                        const SizedBox(height: 8),

                        // Description
                        _buildDescriptionField(),
                        const SizedBox(height: 8),

                        // Remarks
                        _buildRemarksField(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection({
    required String title,
    required bool isFromAccount,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          _buildAccountDropdown(isFromAccount: isFromAccount),
        ],
      ),
    );
  }

  Widget _buildAccountDropdown({required bool isFromAccount}) {
    final selectedAccount = isFromAccount
        ? transferBloc.fromAccountModel
        : transferBloc.toAccountModel;

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountActiveListLoading) {
          return Container(
            height: 40,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (state is AccountActiveListSuccess) {
          final filteredAccounts = state.list.where((account) {
            if (isFromAccount) {
              return account.id != transferBloc.toAccountModel?.id;
            } else {
              return account.id != transferBloc.fromAccountModel?.id;
            }
          }).toList();

          return GestureDetector(
            onTap: () {
              _showAccountSelector(context, filteredAccounts, isFromAccount);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAccount?.name ?? "Select Account",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.text(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selectedAccount != null &&
                            selectedAccount.acNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Acc. No: ${selectedAccount.acNumber}",
                              style:  TextStyle(
                                fontSize: 12,
                                color:AppColors.text(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAccountSelector(
    BuildContext context,
    List<AccountActiveModel> accounts,
    bool isFromAccount,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            color: AppColors.bottomNavBg(context),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),

                    Text(
                      "Select ${isFromAccount ? 'From' : 'To'} Account",
                      style:  TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 20,),
                    IconButton(
                      onPressed: () {
                        AppRoutes.pop(context);
                      },
                      icon: Icon(HugeIcons.strokeRoundedCancelSquare),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return ListTile(
                        onTap: () {
                          setState(() {
                            if (isFromAccount) {
                              transferBloc.fromAccountModel = account;
                            } else {
                              transferBloc.toAccountModel = account;
                            }
                          });
                          Navigator.pop(context);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.primaryColor(context),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          account.name ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (account.acNumber != null)
                              Text(
                                "Acc. No: ${account.acNumber}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              "Balance: ${account.balance ?? '0.00'}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount *",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: transferBloc.amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter amount",
            hintStyle: AppTextStyle.body(context),
            prefixIcon: const Icon(Icons.currency_rupee, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTransferTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Transfer Type *",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: transferBloc.selectedTransferType,
          items: transferBloc.transferTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type.replaceAll('_', ' ').toUpperCase(),
                style:  AppTextStyle.body(context)
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              transferBloc.selectedTransferType = value!;
            });
          },
          decoration: InputDecoration(
            hintText: "Select type",
            hintStyle: AppTextStyle.body(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select transfer type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Transfer Date *",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: AppColors.primaryColor(context),
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primaryColor(context),
                    ),
                    buttonTheme: const ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                transferBloc.dateController.text = appWidgets
                    .convertDateTimeDDMMYYYY(pickedDate);
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.text(context),
                ),
                const SizedBox(width: 12),
                Text(
                  transferBloc.dateController.text.isNotEmpty
                      ? transferBloc.dateController.text
                      : "Select date",
                  style: TextStyle(
                    fontSize: 14,
                    color: transferBloc.dateController.text.isNotEmpty
                        ? AppColors.text(context)
                        :AppColors.text(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reference No",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: transferBloc.referenceNoController,
          decoration: InputDecoration(
            hintText: "Enter reference number",
            hintStyle: AppTextStyle.body(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: transferBloc.descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "Enter description",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Remarks",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: transferBloc.remarksController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "Enter remarks",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: isQuickTransfer,
            builder: (context, isQuick, child) {
              return SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: () {
                    if (isQuick) {
                      _createQuickTransfer();
                    } else {
                      _createTransfer();
                    }
                  },
                  name: isQuick ? "QUICK TRANSFER" : "CREATE TRANSFER",
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                transferBloc.add(ResetForm());
                setState(() {});
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.primaryColor(context)),
              ),
              child: Text(
                "RESET FORM",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primaryColor(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _createTransfer() {
    if (!formKey.currentState!.validate()) return;

    // Validate accounts
    if (transferBloc.fromAccountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select from account')),
      );
      return;
    }

    if (transferBloc.toAccountModel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select to account')));
      return;
    }

    // Check if accounts are different
    if (transferBloc.fromAccountModel!.id == transferBloc.toAccountModel!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot transfer to the same account')),
      );
      return;
    }

    // Check if from account has sufficient balance
    final fromBalance = transferBloc.fromAccountModel?.balance is String
        ? double.tryParse(transferBloc.fromAccountModel?.balance) ?? 0.0
        : (transferBloc.fromAccountModel?.balance ?? 0.0);

    final transferAmount =
        double.tryParse(transferBloc.amountController.text.trim()) ?? 0;

    if (transferAmount > fromBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Available: $fromBalance'),
        ),
      );
      return;
    }

    // Format date for API
    final dateText = transferBloc.dateController.text.trim();
    DateTime? transferDate;
    if (dateText.isNotEmpty) {
      try {
        transferDate = DateFormat('dd-MM-yyyy').parse(dateText);
      } catch (e) {
        transferDate = DateTime.now();
      }
    } else {
      transferDate = DateTime.now();
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(transferDate);

    Map<String, dynamic> body = {
      "from_account_id": transferBloc.fromAccountModel!.id.toString(),
      "to_account_id": transferBloc.toAccountModel!.id.toString(),
      "amount": transferBloc.amountController.text.trim(),
      "description": transferBloc.descriptionController.text.trim(),
      "transfer_type": transferBloc.selectedTransferType,
      "reference_no": transferBloc.referenceNoController.text.trim(),
      "remarks": transferBloc.remarksController.text.trim(),
      "transfer_date": formattedDate,
    };

    transferBloc.add(CreateAccountTransfer(context: context, body: body));
  }

  void _createQuickTransfer() {
    if (!formKey.currentState!.validate()) return;

    // Validate accounts
    if (transferBloc.fromAccountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select from account')),
      );
      return;
    }

    if (transferBloc.toAccountModel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select to account')));
      return;
    }

    // Check if accounts are different
    if (transferBloc.fromAccountModel!.id == transferBloc.toAccountModel!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot transfer to the same account')),
      );
      return;
    }

    // Check if from account has sufficient balance
    final fromBalance = transferBloc.fromAccountModel?.balance is String
        ? double.tryParse(transferBloc.fromAccountModel?.balance) ?? 0.0
        : (transferBloc.fromAccountModel?.balance ?? 0.0);

    final transferAmount =
        double.tryParse(transferBloc.amountController.text.trim()) ?? 0;

    if (transferAmount > fromBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Available: $fromBalance'),
        ),
      );
      return;
    }

    // Format date for API
    final dateText = transferBloc.dateController.text.trim();
    DateTime? transferDate;
    if (dateText.isNotEmpty) {
      try {
        transferDate = DateFormat('dd-MM-yyyy').parse(dateText);
      } catch (e) {
        transferDate = DateTime.now();
      }
    } else {
      transferDate = DateTime.now();
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(transferDate);

    Map<String, dynamic> body = {
      "from_account_id": transferBloc.fromAccountModel!.id.toString(),
      "to_account_id": transferBloc.toAccountModel!.id.toString(),
      "amount": transferBloc.amountController.text.trim(),
      "description": transferBloc.descriptionController.text.trim(),
      "transfer_type": transferBloc.selectedTransferType,
      "reference_no": transferBloc.referenceNoController.text.trim(),
      "remarks": transferBloc.remarksController.text.trim(),
      "transfer_date": formattedDate,
    };

    transferBloc.add(QuickTransfer(context: context, body: body));
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              transferBloc.add(ResetForm());
              setState(() {});
            },
            child: Text("OK", style: TextStyle(color: AppColors.primaryColor(context))),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
