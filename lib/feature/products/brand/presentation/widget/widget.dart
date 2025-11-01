import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_sizes.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/brand_model.dart';
import '../bloc/brand/brand_bloc.dart';
import '../pages/create_brand/create_brand_setup.dart';




class BrandCard extends StatefulWidget {
  final BrandModel brand;
  final int index;

  const BrandCard({super.key, required this.brand, required this.index});

  @override
  State<BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<BrandCard> {


  @override
  Widget build(BuildContext context) {
   final brand=  context
        .read<BrandBloc>();
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
          widget.brand.name ?? "N/A",
          style: AppTextStyle.cardTitle(context),
        ),

        trailing: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  context.read<BrandBloc>().nameController.text =
                          widget.brand.name ?? "";
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: SizedBox(
                          width: AppSizes.width(context)*0.50,
                          child: BrandCreate(
                            id: widget.brand.id.toString(),
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
                onPressed: ()async {
                  bool shouldDelete =
                      await showDeleteConfirmationDialog(context);
                      if (shouldDelete) {
                     brand
                            .add(DeleteBrand(id:  widget.brand.id.toString()));
                      }
                },
                  icon :const HugeIcon(
                    icon: HugeIcons.strokeRoundedDeleteThrow,
                    color: Colors.black,
                    size: 24.0,
                  )
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
