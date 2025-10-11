import '../configs/configs.dart';

void showCustomToast({
  required BuildContext context,
  required String title,
  required String description,
  ToastificationType type = ToastificationType.success,
  ToastificationStyle style = ToastificationStyle.flat,
  Duration duration = const Duration(seconds: 2),
  IconData icon = Icons.info,
  Color primaryColor = Colors.blue,
}) {
  toastification.show(
    context: context,
    type: type,
    style: style,
    autoCloseDuration: duration,
    title: Text(title),
    description: RichText(
      text: TextSpan(
        text: description,
        style: const TextStyle(color: Colors.black),
      ),
    ),
    alignment: Alignment.topRight,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 200),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    icon: Icon(icon),
    showIcon: true,
    primaryColor: primaryColor,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    showProgressBar: true,
    closeButton: ToastCloseButton(
      showType: CloseButtonShowType.onHover,
      buttonBuilder: (context, onClose) {
        return IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
        );
      },
    ),
    pauseOnHover: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}
