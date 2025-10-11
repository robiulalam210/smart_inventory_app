import '../configs/configs.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.name,
    required this.onPressed,
    this.color,
    this.size,
    this.isDisabled = false,
  });

  final String name;
  final double? size;
  final Color? color;
  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      decoration: BoxDecoration(
        gradient: isDisabled || color != null
            ? null
            : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF33E547), Color(0xFF2A9136)],
        ),
        color: isDisabled
            ? Colors.grey
            : color, // If color is passed, use it (disable gradient)
        borderRadius: BorderRadius.circular(4), // Match border-radius: 4px
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Center(
        child: Text(
          name,
          style: AppTextStyle.buttonTextStyle(context).copyWith(
            color: isDisabled ? Colors.black54 : Colors.white,
          ),
        ),
      ),
    );

    return SizedBox(
      width: size ?? (Responsive.isMobile(context) ? 300 : null),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: isDisabled ? null : onPressed,
          child: buttonContent,
        ),
      ),
    );
  }
}
