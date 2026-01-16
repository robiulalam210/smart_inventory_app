import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_text.dart';


class AccountCardDashbord extends StatelessWidget {
  final int index;

  const AccountCardDashbord(
      {super.key,  required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: AppColors.whiteColor(context),
          borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200,width: 0.5)
        ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: AppColors.primaryGradient(context)),
          child: Text(
            index.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
         "acName",
            style: AppTextStyle.cardTitle(context)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( "acType",
                style: AppTextStyle.cardLevelHead(context)),
            Text( "acNumber",
                style: AppTextStyle.cardLevelText(context)),
          ],
        ),
        trailing: Text("balance", style: AppTextStyle.cardTitle(context)),
      ),
    );
  }
}
