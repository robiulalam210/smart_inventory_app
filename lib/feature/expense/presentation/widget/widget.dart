import 'package:hugeicons/hugeicons.dart';
import 'package:smart_inventory/feature/expense/expense_sub_head/data/model/expense_sub_head_model.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense.dart';
import '../../expense_head/data/model/expense_head_model.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../pages/expense_create.dart';


class ExpenseCard extends StatefulWidget {
  final ExpenseModel expense;
  final int index;

  const ExpenseCard({super.key, required this.expense, required this.index});

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  @override
  Widget build(BuildContext context) {

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: AppTextStyle.getResponsivePaddingBody(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expense.description?.capitalize() ?? "N/A",
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text("Expense Head : ${widget.expense.headName ?? "N/A"}",
                    style: AppTextStyle.cardLevelText(context)),
                const SizedBox(
                  height: 2,
                ),
                Text(
                    "Date  : ${appWidgets.convertDateTimeDDMMMYYYY(widget.expense.expenseDate)}",
                    style: AppTextStyle.cardLevelText(context)),
                const SizedBox(
                  height: 2,
                ),
                Text("Note : ${widget.expense.description ?? "N/A"}",
                    style: AppTextStyle.cardLevelText(context)),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(widget.expense.subheadName ?? "N/A",
                            style: AppTextStyle.cardLevelText(context)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text("Expense No",
                            style: AppTextStyle.cardLevelHead(context)),
                      ],
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    Column(
                      children: [
                        Text(widget.expense.paymentMethod ?? "N/A",
                            style: AppTextStyle.cardLevelText(context)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text("Payment",
                            style: AppTextStyle.cardLevelHead(context)),
                      ],
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    Column(
                      children: [
                        Text(widget.expense.amount ?? "N/A",
                            style: AppTextStyle.cardLevelText(context)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text("Amount",
                            style: AppTextStyle.cardLevelHead(context)),
                      ],
                    ),
                  ],
                )
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () {

                    },
                    icon: const Icon(Iconsax.edit)),
                IconButton(
                    onPressed: () async {
                      // ডায়ালগ দেখানো
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: SizedBox(
                              width: AppSizes.width(context)*0.50,
                              child: ExpenseCreateScreen(
                                id: widget.expense.id.toString(),
                                name: widget.expense.description,
                                selectedExpenseHead: ExpenseHeadModel(
                                    id: widget.expense.head
                                    ,name: widget.expense.headName
                                ),
                                selectedExpenseSubHead: ExpenseSubHeadModel(
                                    id: widget.expense.subhead
                                    ,name: widget.expense.subheadName
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(HugeIcons.strokeRoundedView)),
                IconButton(
                    onPressed: () async {
                      bool shouldDelete = await showDeleteConfirmationDialog(context);
                      if (!shouldDelete) return;

                      // ✅ Show loading dialog
                      showLoadingDialog(context, message: 'Deleting...');
                      context.read<ExpenseBloc>().add(
                          DeleteExpense(id: widget.expense.id.toString()));
                    },
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                    )),
              ],
            )
          ],
        ));
  }
  void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }


}
