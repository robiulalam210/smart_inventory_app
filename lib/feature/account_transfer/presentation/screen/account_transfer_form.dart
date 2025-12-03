// lib/account_transfer/presentation/screens/account_transfer_form.dart


import 'package:intl/intl.dart';
import 'package:meherin_mart/core/core.dart';
import 'package:meherin_mart/feature/accounts/presentation/bloc/account/account_bloc.dart';
import '../../../accounts/data/model/account_active_model.dart';
import '../bloc/account_transfer/account_transfer_bloc.dart';

class AccountTransferForm extends StatefulWidget {
  const AccountTransferForm({super.key});

  @override
  State<AccountTransferForm> createState() => _AccountTransferFormState();
}

class _AccountTransferFormState extends State<AccountTransferForm> {
  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  void _initializeData() {
    // Fetch available accounts
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<AccountTransferBloc>().add(FetchAvailableAccounts(context: context));

    // Set default date
    final transferBloc = context.read<AccountTransferBloc>();
    transferBloc.dateController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AccountTransferBloc transferBloc;

  ValueNotifier<bool> isQuickTransfer = ValueNotifier<bool>(false);

  @override
  void didChangeDependencies() {
    transferBloc = context.read<AccountTransferBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isQuickTransfer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return SafeArea(
      child: ResponsiveRow(
        spacing: 0,
        runSpacing: 0,
        children: [
          if (isBigScreen)
            ResponsiveCol(
              xs: 0,
              sm: 1,
              md: 1,
              lg: 2,
              xl: 2,
              child: Container(
                decoration: BoxDecoration(color: AppColors.whiteColor),
                child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
              ),
            ),
          ResponsiveCol(
            xs: 12,
            sm: 12,
            md: 12,
            lg: 10,
            xl: 10,
            child: Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: AppColors.bg,
                child: BlocListener<AccountTransferBloc, AccountTransferState>(
                  listener: (context, state) {
                    if (state is AccountTransferAddLoading ||
                        state is QuickTransferLoading ||
                        state is ExecuteTransferLoading) {
                      appLoader(context, "Processing transfer, please wait...");
                    } else if (state is AccountTransferAddSuccess) {
                      Navigator.pop(context); // Close loader dialog
                      _showSuccessDialog(
                        "Transfer Created",
                        "Transfer request created successfully. Use execute option to complete it.",
                      );
                    } else if (state is QuickTransferSuccess) {
                      Navigator.pop(context); // Close loader dialog
                      _showSuccessDialog(
                        "Transfer Completed",
                        "Transfer completed successfully.",
                      );
                    } else if (state is ExecuteTransferSuccess) {
                      Navigator.pop(context); // Close loader dialog
                      _showSuccessDialog(
                        "Transfer Executed",
                        "Transfer executed successfully.",
                      );
                    } else if (state is AccountTransferAddFailed ||
                        state is QuickTransferFailed ||
                        state is ExecuteTransferFailed ||
                        state is AvailableAccountsFailed) {
                      Navigator.pop(context); // Close loader dialog
                      // appAlertDialog(
                      //   context,
                      //   state.content,
                      //   title: state.title,
                      //   actions: [
                      //     TextButton(
                      //       onPressed: () => Navigator.pop(context),
                      //       child: const Text("Dismiss"),
                      //     ),
                      //   ],
                      // );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Account Transfer",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: isQuickTransfer,
                            builder: (context, isQuick, child) {
                              return Row(
                                children: [
                                  const Text("Quick Transfer:"),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: isQuick,
                                    onChanged: (value) {
                                      isQuickTransfer.value = value;
                                    },
                                    activeColor: AppColors.primaryColor,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              "Transfer Details",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ResponsiveRow(
                              spacing: 20,
                              runSpacing: 10,
                              children: [
                                // From Account
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 6,
                                  md: 6,
                                  lg: 6,
                                  xl: 6,
                                  child: _buildAccountDropdown(
                                    context,
                                    isFromAccount: true,
                                  ),
                                ),
                                // To Account
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 6,
                                  md: 6,
                                  lg: 6,
                                  xl: 6,
                                  child: _buildAccountDropdown(
                                    context,
                                    isFromAccount: false,
                                  ),
                                ),
                                // Amount
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 3,
                                  md: 3,
                                  lg: 3,
                                  xl: 3,
                                  child: AppTextField(
                                    isRequired: true,
                                    controller: transferBloc.amountController,
                                    hintText: 'Amount',
                                    keyboardType: TextInputType.number,
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
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                // Transfer Type
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 3,
                                  md: 3,
                                  lg: 3,
                                  xl: 3,
                                  child: AppDropdown<String>(
                                    context: context,
                                    label: "Transfer Type",
                                    hint: transferBloc.selectedTransferType
                                        .toUpperCase(),
                                    isLabel: false,
                                    isRequired: true,
                                    isNeedAll: false,
                                    value: transferBloc.selectedTransferType,
                                    itemList: transferBloc.transferTypes,
                                    onChanged: (newVal) {
                                      setState(() {
                                        transferBloc.selectedTransferType = newVal.toString();
                                      });
                                    },
                                    itemBuilder: (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.blackColor,
                                          fontFamily: 'Quicksand',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Date
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 3,
                                  md: 3,
                                  lg: 3,
                                  xl: 3,
                                  child: CustomInputField(
                                    isRequired: true,
                                    controller: transferBloc.dateController,
                                    hintText: 'Transfer Date',
                                    fillColor: const Color.fromARGB(
                                      255, 255, 255, 255,
                                    ),
                                    readOnly: true,
                                    keyboardType: TextInputType.text,
                                    validator: (value) {
                                      return value!.isEmpty
                                          ? 'Please select date'
                                          : null;
                                    },
                                    onTap: () async {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          transferBloc.dateController.text =
                                              appWidgets.convertDateTimeDDMMYYYY(pickedDate);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                // Reference No
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 3,
                                  md: 3,
                                  lg: 3,
                                  xl: 3,
                                  child: AppTextField(
                                    isRequired: false,
                                    controller: transferBloc.referenceNoController,
                                    hintText: 'Reference No',
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                // Description
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 12,
                                  md: 12,
                                  lg: 12,
                                  xl: 12,
                                  child: AppTextField(
                                    isRequired: false,
                                    controller: transferBloc.descriptionController,
                                    hintText: 'Description',
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                // Remarks
                                ResponsiveCol(
                                  xs: 12,
                                  sm: 12,
                                  md: 12,
                                  lg: 12,
                                  xl: 12,
                                  child: AppTextField(
                                    isRequired: false,
                                    controller: transferBloc.remarksController,
                                    hintText: 'Remarks',
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: isQuickTransfer,
                            builder: (context, isQuick, child) {
                              return AppButton(
                                width: 200,
                                name: isQuick ? "Quick Transfer" : "Create Transfer",
                                onPressed: () {
                                  if (isQuick) {
                                    _createQuickTransfer();
                                  } else {
                                    _createTransfer();
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          AppButton(
                            width: 100,

                            color: AppColors.secondary,
                            onPressed: () {
                              transferBloc.add(ResetForm());
                              setState(() {});
                            }, name: 'Reset',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDropdown(
      BuildContext context, {
        required bool isFromAccount,
      }) {
    final transferBloc = context.read<AccountTransferBloc>();

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountActiveListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AccountActiveListFailed) {
          return Text(
            state.content ?? "Failed to load accounts",
            style: const TextStyle(color: Colors.red),
          );
        } else if (state is AccountActiveListSuccess) {
          final selectedAccount = isFromAccount
              ? transferBloc.fromAccountModel
              : transferBloc.toAccountModel;

          // Filter out the opposite account to prevent self-transfer
          final filteredAccounts = state.list.where((account) {
            if (isFromAccount) {
              return account.id != transferBloc.toAccountModel?.id;
            } else {
              return account.id != transferBloc.fromAccountModel?.id;
            }
          }).toList();

          return AppDropdown<AccountActiveModel>(
            context: context,
            label: isFromAccount ? "From Account" : "To Account",
            hint: selectedAccount == null
                ? "Select ${isFromAccount ? 'From' : 'To'} Account"
                : "${selectedAccount.name}${selectedAccount.acNumber != null && selectedAccount.acNumber!.isNotEmpty ? ' - ${selectedAccount.acNumber}' : ''}",
            isLabel: false,
            isRequired: true,
            isNeedAll: false,
            value: selectedAccount,
            itemList: filteredAccounts,
            onChanged: (newVal) {
              setState(() {
                if (isFromAccount) {
                  transferBloc.fromAccountModel = newVal;
                } else {
                  transferBloc.toAccountModel = newVal;
                }
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select ${isFromAccount ? 'from' : 'to'} account';
              }
              if (isFromAccount &&
                  transferBloc.toAccountModel != null &&
                  value.id == transferBloc.toAccountModel!.id) {
                return 'Cannot transfer to the same account';
              }
              return null;
            },
            itemBuilder: (item) => DropdownMenuItem(
              value: item,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? "Unknown",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Balance: ${item.balance ?? '0.00'} | Type: ${item.acType?.toUpperCase() ?? 'Unknown'}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }


  void _createTransfer() {
    if (!formKey.currentState!.validate()) return;

    final transferBloc = context.read<AccountTransferBloc>();

    // Validate accounts
    if (transferBloc.fromAccountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select from account')),
      );
      return;
    }

    if (transferBloc.toAccountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select to account')),
      );
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
    final fromBalance = double.tryParse(transferBloc.fromAccountModel?.balance.toString() ?? '0') ?? 0.0;
    final transferAmount = double.tryParse(transferBloc.amountController.text.trim()) ?? 0;

    if (transferAmount > fromBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Available: $fromBalance, Required: $transferAmount',
          ),
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

    transferBloc.add(CreateAccountTransfer(
      context: context,
      body: body,
    ));
  }

  void _createQuickTransfer() {
    if (!formKey.currentState!.validate()) return;

    final transferBloc = context.read<AccountTransferBloc>();

    // Validate accounts
    if (transferBloc.fromAccountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select from account')),
      );
      return;
    }

    if (transferBloc.toAccountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select to account')),
      );
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
    final fromBalance = double.tryParse(transferBloc.fromAccountModel!.balance ?? '0') ?? 0;
    final transferAmount = double.tryParse(transferBloc.amountController.text.trim()) ?? 0;

    if (transferAmount > fromBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Available: $fromBalance, Required: $transferAmount',
          ),
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

    transferBloc.add(QuickTransfer(
      context: context,
      body: body,
    ));
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
              Navigator.pop(context); // Close dialog
              transferBloc.add(ResetForm());
              setState(() {});
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}