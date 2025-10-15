import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/product_model.dart';
import '../bloc/products/products_bloc.dart';



class ProductCard extends StatefulWidget {
  final ProductModel product;
  final int index;

  const ProductCard({super.key, required this.product, required this.index});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: AppTextStyle.getResponsivePaddingBody(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // SizedBox(
                    //   width: 60,
                    //   child: widget.product.image != null
                    //       ? ClipRRect(
                    //           borderRadius: BorderRadius.circular(8),
                    //           child: FadeInImage.assetNetwork(
                    //             placeholder: "assets/images/no_image.jpg",
                    //             image:
                    //                 "${AppUrls.imageBaseUrl}/${widget.product.image}",
                    //             imageErrorBuilder:
                    //                 (context, error, stackTrace) {
                    //               return Image.asset(
                    //                   "assets/images/no_image.jpg");
                    //             },
                    //             fit: BoxFit.cover,
                    //           ),
                    //         )
                    //       : Image.asset("assets/images/no_image.jpg"),
                    // ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.name?.capitalize() ?? "N/A",
                            style: AppTextStyle.cardTitle(context)),
                        Text(widget.product.sku ?? "N/A",
                            style: AppTextStyle.cardLevelText(context)),
                        // Text(widget.product.category ?? "N/A",
                        //     style: AppTextStyle.cardLevelText(context)),
                      ],
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     Container(
                //       width: 80,
                //       alignment: Alignment.center,
                //       padding: const EdgeInsets.all(4),
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(5),
                //           color: widget.product.productStatus == 1
                //               ? Colors.green
                //               : Colors.redAccent),
                //       child: Text(
                //         widget.product.productStatus == 1
                //             ? "Active"
                //             : "Inactive",
                //         style: AppTextStyle.cardLevelTextWhiteColor(context),
                //       ),
                //     ),
                //     IconButton(
                //         onPressed: () async {
                //           bool shouldDelete =
                //               await showDeleteConfirmationDialog(context);
                //           if (shouldDelete) {
                //             context.read<ProductsBloc>().add(DeleteProducts(
                //
                //                 id: widget.product.productId.toString()));
                //           }
                //         },
                //         icon: const HugeIcon(
                //           icon: HugeIcons.strokeRoundedDeleteThrow,
                //           color: Colors.black,
                //           size: 24.0,
                //         ))
                //   ],
                // )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                        double.tryParse(
                                widget.product.purchasePrice.toString())!
                            .toStringAsFixed(2),
                        style: AppTextStyle.cardLevelText(context)),
                    Text("Purchase Price",
                        style: AppTextStyle.cardLevelHead(context)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                        double.tryParse(widget.product.sellingPrice.toString())!
                            .toStringAsFixed(2),
                        style: AppTextStyle.cardLevelText(context)),
                    Text("Selling Price",
                        style: AppTextStyle.cardLevelHead(context)),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
