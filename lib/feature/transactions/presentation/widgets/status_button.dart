
import '../../../../core/configs/configs.dart';

class StatusButtonWhite extends StatelessWidget {
  const StatusButtonWhite(
      {super.key,
        required this.child,
        this.onPressed,
        required this.isSelected});

  final Widget child;
  final VoidCallback? onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSizes.bodyPadding,
            vertical: AppSizes.bodyPadding / 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius * 2),
          border: Border.all(width: AppSizes.radius / 2, color: AppColors.grey),
        ),
        child: Center(child: child),
      ),
    );
  }
}