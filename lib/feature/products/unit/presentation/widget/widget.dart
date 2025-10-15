import 'package:dokani_360/blocs/blocs.dart';
import 'package:dokani_360/models/product/unit_model.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../widgets/delete_dialog.dart';
import '../create_unit/create_unit_setup.dart';

class UnitCard extends StatelessWidget {
  final UnitsModel units;
  final int index;

  const UnitCard({super.key, required this.units, required this.index});

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
            index.toString(),
            style: AppTextStyle.cardTitle(context),
          ),
        ),
        title: Text(
          units.name?.capitalize() ?? "N/A",
          style: AppTextStyle.cardTitle(context),
        ),
    //     subtitle: Text(
    //         "Short Name : ${units.subName?.capitalize().toString() ?? "N/A"}",
    // style: AppTextStyle.cardLevelHead(context)),
    //     trailing: FittedBox(
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           IconButton(
    //             onPressed: () {
    //               context.read<UnitBloc>().nameController.text =
    //                   units.name ?? "";
    //               context.read<UnitBloc>().shortNameController.text =
    //                   units.subName ?? "";
    //
    //               setupUnit(context, "Update Unit", "Update",
    //                   id: units.id.toString());
    //             },
    //             icon: const Icon(
    //               Iconsax.edit,
    //               size: 24,
    //             ),
    //           ),
    //           IconButton(
    //               onPressed: () async {
    //                 bool shouldDelete =
    //                     await showDeleteConfirmationDialog(context);
    //                 if (shouldDelete) {
    //                   context
    //                       .read<UnitBloc>()
    //                       .add(DeleteUnit(units.id.toString()));
    //                 }
    //               },
    //               icon: const HugeIcon(
    //                 icon: HugeIcons.strokeRoundedDeleteThrow,
    //                 color: Colors.black,
    //                 size: 24.0,
    //               )),
    //         ],
    //       ),
    //     ),
      ),
    );
  }
}
