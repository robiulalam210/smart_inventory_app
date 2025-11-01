
import 'package:hugeicons/hugeicons.dart';
import 'package:smart_inventory/feature/products/unit/presentation/pages/unit_create.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/unit_model.dart';
import '../bloc/unit/unti_bloc.dart';


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

        trailing: FittedBox(
          child: Row(
            children: [


              IconButton(
                onPressed: () {
                  context.read<UnitBloc>().nameController.text =
                      units.name ?? "";


                  // ডায়ালগ দেখানো
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: SizedBox(
                          width: AppSizes.width(context)*0.50,
                          child: UnitCreate(
                            id: units.id.toString(),
                          ),
                        ),
                      );
                    },
                  );

                },
                icon: const Icon(
                  Iconsax.edit,
                  size: 24,
                ),
              ),
              IconButton(
                  onPressed: () async {
                    bool shouldDelete =
                    await showDeleteConfirmationDialog(context);
                    if (shouldDelete) {
                      context.read<UnitBloc>().add(DeleteUnit(
                          units.id.toString()));
                    }
                  },
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDeleteThrow,
                    color: Colors.black,
                    size: 24.0,
                  )),
            ],
          ),
        ),

      ),
    );
  }
}
