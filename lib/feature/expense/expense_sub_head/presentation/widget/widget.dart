import 'package:hugeicons/hugeicons.dart';
import 'package:smart_inventory/feature/expense/data/model/expense.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../expense_head/data/model/expense_head_model.dart';
import '../../data/model/expense_sub_head_model.dart';
import '../bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../pages/expense_sub_head_create.dart';



class ExpenseSubHeadCard extends StatefulWidget {
  final ExpenseSubHeadModel expenseHead;
  final int index;

  const ExpenseSubHeadCard(
      {super.key, required this.expenseHead, required this.index});

  @override
  State<ExpenseSubHeadCard> createState() => _ExpenseHeadCardState();
}

class _ExpenseHeadCardState extends State<ExpenseSubHeadCard> {
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

                  // Bloc এর টেক্সট কন্ট্রোলারে আগের নাম সেট করা
                  context.read<ExpenseSubHeadBloc>().name.text =
                      widget.expenseHead.name ?? "";

                  // ডায়ালগ দেখানো
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: SizedBox(
                          width: AppSizes.width(context)*0.50,
                          child: ExpenseSubHeadCreate(
                            id: widget.expenseHead.id.toString(),
                            name: widget.expenseHead.name,
                            selectedHead: ExpenseHeadModel(
                              id: widget.expenseHead.head
                                  ,name: widget.expenseHead.headName
                            ),
                          ),
                        ),
                      );
                    },
                  );

                },
                icon: const Icon(
                  Iconsax.edit,
                  size: 25,
                ),
              ),
              IconButton(
                onPressed: () async {
                  // ✅ Show confirmation dialog
                  bool shouldDelete = await showDeleteConfirmationDialog(context);
                  if (!shouldDelete) return;

                  // ✅ Show loading dialog
                  showLoadingDialog(context, message: 'Deleting...');

                    context.read<ExpenseSubHeadBloc>().add(DeleteSubExpenseHead(
                        id: widget.expenseHead.id.toString()));

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
