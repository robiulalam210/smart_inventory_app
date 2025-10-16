import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense_head_model.dart';
import '../bloc/expense_head/expense_head_bloc.dart';


class ExpenseHeadCard extends StatefulWidget {
  final ExpenseHeadModel expenseHead;
  final int index;

  const ExpenseHeadCard(
      {super.key, required this.expenseHead, required this.index});

  @override
  State<ExpenseHeadCard> createState() => _ExpenseHeadCardState();
}

class _ExpenseHeadCardState extends State<ExpenseHeadCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: AppColors.linearGradient),
          child: Text(
            widget.index.toString(),
            style: AppTextStyle.cardTitle(context),
          ),
        ),
        title: Text(
          widget.expenseHead.name ?? "N/A",
          style: AppTextStyle.cardTitle(context),
        ),
        trailing: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  context.read<ExpenseHeadBloc>().name.text =
                      widget.expenseHead.name ?? "";


                },
                icon: const Icon(
                  Iconsax.edit,
                  size: 25,
                ),
              ),
              IconButton(
                onPressed: () async {
                  bool shouldDelete =
                      await showDeleteConfirmationDialog(context);
                  if (shouldDelete) {
                    context.read<ExpenseHeadBloc>().add(DeleteExpenseHead(
                        id: widget.expenseHead.id.toString()));
                  }
                },
                icon:  const HugeIcon(
                  icon: HugeIcons.strokeRoundedDeleteThrow,
                  color: Colors.black,
                  size: 24.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
