

import '../../../../core/configs/configs.dart';
import '../../data/model/account_model.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final int index;

  const AccountCard({super.key, required this.account, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child:ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: AppColors.linearGradient),
          child: Text(
           index.toString(),
            style: AppTextStyle.cardTitle(context),
          ),
        ),
        title: Text(
          account.acName ?? "N/A",
          style: AppTextStyle.cardTitle(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.acType  ?? "N/A",
              style: AppTextStyle.cardLevelText(context),),
            Text(account.acNumber  ?? "N/A",
              style: AppTextStyle.cardLevelText(context),),
          ],
        ),

        trailing: Text("Balance\n${account.balance??"N/A"}",  style: AppTextStyle.cardLevelText(context),),

      ),
    );
  }
}
