import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_inventory/feature/products/categories/presentation/pages/categories_create.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_sizes.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/categories_model.dart';
import '../bloc/categories/categories_bloc.dart';


class CategoriesCard extends StatefulWidget {
  final CategoryModel categories;
  final int index;

  const CategoriesCard(
      {super.key, required this.categories, required this.index});

  @override
  State<CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<CategoriesCard> {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categories.name ?? "N/A",
              style: AppTextStyle.cardTitle(context),
            ),
          ],
        ),
        trailing: FittedBox(
          child: Row(
            children: [


              IconButton(
                onPressed: () {
                  context.read<CategoriesBloc>().nameController.text =
                      widget.categories.name ?? "";

                  // context.read<CategoriesBloc>().selectedState=  widget.categories.status.toString()=="1"?"Active":"Inactive";

                  // ডায়ালগ দেখানো
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: SizedBox(
                          width: AppSizes.width(context)*0.50,
                          child: CategoriesCreate(
                            id: widget.categories.id.toString(),
                          ),
                        ),
                      );
                    },
                  );
                  // setupCategories(context, "Update Categories", "Update",
                  //     id: widget.categories.id.toString());
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
                      context.read<CategoriesBloc>().add(DeleteCategories(
                          id: widget.categories.id.toString()));
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

  @override
  void dispose() {
    super.dispose();
  }
}
