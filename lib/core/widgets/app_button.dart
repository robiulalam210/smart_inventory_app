import '../configs/configs.dart';

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(widget.borderRadius ?? 8);

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),

      child: Container(
        width: widget.size ?? (Responsive.isMobile(context) ? 300 : null),
        margin: widget.margin ?? EdgeInsets.zero,

        child: Material(
          color: Colors.transparent,
          borderRadius: br,

          child: InkWell(
            borderRadius: br,
            onTap: (widget.isDisabled || widget.isLoading)
                ? null
                : widget.onPressed,

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                gradient: _getGradient(context),
                color: _getBackgroundColor(context),
                border: widget.isOutlined
                    ? Border.all(
                  color: isHover
                      ? (widget.borderColor ??
                      (widget.color ?? AppColors.primaryColor))
                      : (widget.borderColor ??
                      (widget.color ?? AppColors.primaryColor))
                      .withValues(alpha: 0.8),
                  width: 1.5,
                )
                    : null,
                borderRadius: br,
                boxShadow: widget.elevation != null
                    ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: widget.elevation!,
                    offset: const Offset(0, 2),
                  )
                ]
                    : null,
              ),
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Center(child: _buildButtonContent(context)),
            ),
          ),
        ),
      ),
    );
  }

  Gradient? _getGradient(BuildContext context) {
    if (widget.isOutlined || widget.isDisabled || widget.isLoading) return null;
    if (widget.gradient != null) return widget.gradient;
    if (widget.color != null) return null;

    // Hover lighten effect
    if (isHover) {
      return LinearGradient(
        colors: [
          AppColors.primaryColor.withValues(alpha: 0.9),
          AppColors.secondaryBabyBlue.withValues(alpha: 0.9),
        ],
      );
    }

    return AppColors.primaryGradient;
  }

  Color? _getBackgroundColor(BuildContext context) {
    if (widget.isOutlined) return Colors.transparent;
    if (widget.isDisabled || widget.isLoading) return Colors.grey.shade400;
    if (widget.color != null) {
      return isHover
        ? widget.color!.withValues(alpha: 0.9)
        : widget.color;
    }

    return null;
  }

  Widget _buildButtonContent(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isOutlined
                ? (widget.color ?? AppColors.primaryColor)
                : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.name,
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
      if (widget.isDisabled) return Colors.black54;
      if (widget.isOutlined) {
        return widget.textColor ??
            (widget.color ?? AppColors.primaryColor);
      }
      return widget.textColor ?? Colors.white;
    }

    return baseStyle.copyWith(
      color: getTextColor(),
      fontWeight: FontWeight.w600,
    );
  }
}
