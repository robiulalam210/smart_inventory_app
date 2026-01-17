import '../../../../../core/core.dart';

Widget buildDoctorAvatar({
  required String? imageUrl,
  required String fullName,
  required bool isMan,
  required bool isDoctor,
  required BuildContext context,
  double size = 110, // default same as your container
  double borderRadius = 20,
}) {
  final String fullImageUrl;
  // Construct full URL if image exists
  if(isDoctor){
    fullImageUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? "${AppUrls.baseUrlMain}$imageUrl"
        : "";
  }else{
    fullImageUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? "${AppUrls.baseUrlMain}$imageUrl"
        : "";
  }


  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: AppColors.primaryGradient(context),
    ),
    child: fullImageUrl.isNotEmpty
        ? ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        fullImageUrl,
        width: size,
        height: size,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          // fallback to initials
          return Center(child: Image.asset(isMan ? AppImages.man : AppImages.woman));
        },
      ),
    )
        : Center(child: Image.asset(isMan ? AppImages.man : AppImages.woman)),
  );
}
