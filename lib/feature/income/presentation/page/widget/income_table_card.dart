import 'package:flutter/material.dart';

import '../../../data/model/income_model.dart';

class IncomeTableCard extends StatelessWidget {
  final List<IncomeModel> incomes;
  final VoidCallback? onIncomeTap;

  const IncomeTableCard({
    Key? key,
    required this.incomes,
    this.onIncomeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return Center(child: Text('No Incomes Found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return Card(
          child: ListTile(
            title: Text(income.headName ?? 'No Head'),
            subtitle: Text(income.amount ?? '0'),
            onTap: onIncomeTap,
          ),
        );
      },
    );
  }
}