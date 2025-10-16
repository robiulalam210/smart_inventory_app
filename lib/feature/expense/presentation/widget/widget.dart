import 'package:hugeicons/hugeicons.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense.dart';
import '../bloc/expense_list/expense_bloc.dart';


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
                Text("Expense Head : ${widget.expense.subhead ?? "N/A"}",
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
                Text("Note : ${widget.expense.note ?? "N/A"}",
                    style: AppTextStyle.cardLevelText(context)),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(widget.expense.subhead.toString() ?? "N/A",
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

                    },
                    icon: const Icon(HugeIcons.strokeRoundedView)),
                IconButton(
                    onPressed: () async {
                      bool shouldDelete =
                      await showDeleteConfirmationDialog(context);
                      if (shouldDelete) {
                        context.read<ExpenseBloc>().add(
                            DeleteExpense(id: widget.expense.id.toString()));
                      }
                    },
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                    )),
              ],
            )
          ],
        ));
  }


}
