import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/configs/configs.dart';
import '../../data/model/source_model.dart';
import '../bloc/source/source_bloc.dart';


class SourceCard extends StatelessWidget {
  final SourceModel source;
  final int index;

  const SourceCard({super.key, required this.source, required this.index});

  @override
  Widget build(BuildContext context) {
    final sourceBloc=   context
        .read<SourceBloc>();
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
          source.name ?? "N/A",
          style: AppTextStyle.cardTitle(context),
        ),

         // FittedBox(
         //        child: Row(
         //          children: [
         //            IconButton(
         //              onPressed: () {
         //                context.read<SourceBloc>().nameController.text =
         //                    source.name ?? "";
         //                setupSource(
         //                  context,
         //                  "Update Source",
         //                  "Update",
         //                  id: source.id.toString(),
         //                );
         //              },
         //              icon: const Icon (
         //                Iconsax.edit,
         //                size: 24,
         //              ),
         //            ),
         //            IconButton(
         //              onPressed: () async {
         //                bool shouldDelete =
         //                    await showDeleteConfirmationDialog(context);
         //                if (shouldDelete) {
         //               sourceBloc
         //                      .add(DeleteSource(source.id.toString()));
         //                }
         //              },
         //              icon:  const HugeIcon(
         //                icon: HugeIcons.strokeRoundedDeleteThrow,
         //                color: Colors.black,
         //                size: 24.0,
         //              ),
         //            ),
         //          ],
         //        ),
         //      )

      ),
    );
  }
}
