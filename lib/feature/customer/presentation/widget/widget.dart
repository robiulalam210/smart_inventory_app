import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/configs/configs.dart';
import '../../data/model/customer_model.dart';


class CustomerCard extends StatefulWidget {
  final CustomerModel customerData;
  final int index;

  const CustomerCard({super.key, required this.customerData, required this.index});

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {




  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding:AppTextStyle.getResponsivePaddingBody(context),


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customerData.name ?? "N/A",
              style: AppTextStyle.cardTitle(context),
            ),
            Text(widget.customerData.phone ?? "N/A",
              style: AppTextStyle.cardLevelText(context),),
            Text(widget.customerData.name ?? "N/A",
              style: AppTextStyle.cardLevelText(context),),
            Text(widget.customerData.address ?? "N/A",
              style: AppTextStyle.cardLevelText(context),),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                        children: [
                         Text("Advance/Due : ",
                        style: AppTextStyle.cardLevelTextWhiteColor(context)),

                          // Text(
                          //   widget.customerData.due != null
                          //       ? double.tryParse(widget.customerData.due.toString())?.abs().toString() ?? "N/A" // Convert to double and then get the absolute value
                          //       : "N/A",
                          //   style: TextStyle(
                          //
                          //     fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          //     color: widget.customerData.due != null && double.tryParse(widget.customerData.due.toString()) != null
                          //         ? (double.parse(widget.customerData.due.toString()) < 0
                          //         ? Colors.green
                          //         : double.parse(widget.customerData.due.toString()) > 0
                          //         ? Colors.red
                          //         : Colors.white)
                          //         : Colors.white,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // )



                        ],
                    ),
                  ),
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
