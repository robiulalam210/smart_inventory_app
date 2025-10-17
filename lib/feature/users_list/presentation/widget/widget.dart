

import '../../../../core/configs/configs.dart';
import '../../data/model/user_model.dart';

class UserCard extends StatefulWidget {
  final UsersListModel staffData;
  final int index;

  const UserCard({super.key, required this.staffData, required this.index});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {


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
              children: [
                // SizedBox(
                //   width: 60,
                //   height: 60,
                //   child: widget.staffData.image != null
                //       ? ClipRRect(
                //           borderRadius: BorderRadius.circular(8),
                //           child: FadeInImage.assetNetwork(
                //             placeholderFilterQuality: FilterQuality.medium,
                //             placeholder: "assets/images/no_image.jpg",
                //             image:
                //                 "${AppUrls.imageBaseUrl}/${widget.staffData.image}",
                //             imageErrorBuilder: (context, error, stackTrace) {
                //               return Image.asset("assets/images/no_image.jpg");
                //             },
                //             fit: BoxFit.cover,
                //           ),
                //         )
                //       : Image.asset("assets/images/no_image.jpg"),
                // ),
                const SizedBox(
                  width: 6,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.staffData.username ?? "N/A",
                      style: AppTextStyle.cardTitle(context),
                    ),
                    Text(
                      widget.staffData.email ?? "N/A",
                      style: AppTextStyle.cardLevelText(context),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Designation : ",
                          style: AppTextStyle.cardLevelHead(context),
                        ),
                        Text(
                          widget.staffData.role ?? "N/A",
                          style: AppTextStyle.cardLevelText(context),
                        ),
                      ],
                    ),

                  ],
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Role : ",
                          style: AppTextStyle.cardLevelTextWhiteColor(context),
                        ),

                        Text(
                          widget.staffData.isActive.toString() ?? "N/A",
                          style: AppTextStyle.cardLevelTextWhiteColor(context),
                        ),
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
