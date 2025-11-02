// import '../configs/configs.dart';
//
// class AppButton extends StatelessWidget {
//   const AppButton({
//     super.key,
//     required this.name,
//     required this.onPressed,
//     this.color,
//     this.size,
//     this.isDisabled = false,
//   });
//
//   final String name;
//   final double? size;
//   final Color? color;
//   final VoidCallback? onPressed;
//   final bool isDisabled;
//
//   @override
//   Widget build(BuildContext context) {
//     final buttonContent = Container(
//       decoration: BoxDecoration(
//         gradient: isDisabled || color != null
//             ? null
//             : const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF33E547), Color(0xFF2A9136)],
//         ),
//         color: isDisabled
//             ? Colors.grey
//             : color, // If color is passed, use it (disable gradient)
//         borderRadius: BorderRadius.circular(4), // Match border-radius: 4px
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       child: Center(
//         child: Text(
//           name,
//           style: AppTextStyle.buttonTextStyle(context).copyWith(
//             color: isDisabled ? Colors.black54 : Colors.white,
//           ),
//         ),
//       ),
//     );
//
//     return SizedBox(
//       width: size ?? (Responsive.isMobile(context) ? 300 : null),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(4),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(4),
//           onTap: isDisabled ? null : onPressed,
//           child: buttonContent,
//         ),
//       ),
//     );
//   }
// }
import '../configs/configs.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.name,
    required this.onPressed,
    this.color,
    this.size,
    this.isDisabled = false,
    this.isLoading = false,
    this.height,
    this.width,
    this.borderRadius,
    this.textColor,
    this.borderColor,
    this.icon,
    this.padding,
    this.margin,
    this.elevation,
    this.gradient,
    this.isOutlined = false,
  });

  final String name;
  final double? size;
  final Color? color;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? textColor;
  final Color? borderColor;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Gradient? gradient;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: size ?? (Responsive.isMobile(context) ? 300 : null),
      margin: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          onTap: (isDisabled || isLoading) ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: _getGradient(context),
              color: _getBackgroundColor(context),
              border: isOutlined
                  ? Border.all(
                color: borderColor ?? (color ?? AppColors.primaryColor),
                width: 1.5,
              )
                  : null,
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              boxShadow: elevation != null ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation!,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Center(
              child: _buildButtonContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Gradient? _getGradient(BuildContext context) {
    if (isOutlined || isDisabled || isLoading) return null;
    if (gradient != null) return gradient;
    if (color != null) return null;

    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF33E547), Color(0xFF2A9136)],
    );
  }

  Color? _getBackgroundColor(BuildContext context) {
    if (isOutlined) return Colors.transparent;
    if (isDisabled || isLoading) return Colors.grey.shade400;
    if (color != null) return color;
    return null; // Let gradient handle it
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? (color ?? AppColors.primaryColor) : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            name,
            style: _getTextStyle(context),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = AppTextStyle.buttonTextStyle(context);

    Color getTextColor() {
      if (isDisabled) return Colors.black54;
      if (isOutlined) return textColor ?? (color ?? AppColors.primaryColor);
      return textColor ?? Colors.white;
    }

    return baseStyle.copyWith(
      color: getTextColor(),
      fontWeight: FontWeight.w600,
    );
  }
}