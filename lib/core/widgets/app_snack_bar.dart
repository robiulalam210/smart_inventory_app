// import '../core.dart';
//
// void appSnackBar(BuildContext context, String msg, {Color? color}) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.info,
//             color: color ?? AppColors.primaryColor,
//             size: 20,
//           ),
//           const SizedBox(
//             width: AppSizes.bodyPadding,
//           ),
//           Expanded(child: Text(msg, style: AppTextStyle.titleSmall(context))),
//         ],
//       ),
//       backgroundColor: AppColors.systemBg(context),
//       elevation: 0,
//       behavior: SnackBarBehavior.floating,
//       margin: const EdgeInsets.all(AppSizes.bodyPadding),
//       shape: RoundedRectangleBorder(
//           side: BorderSide(color: color ?? AppColors.primaryColor),
//           borderRadius: BorderRadius.circular(10)),
//     ),
//   );
// }
