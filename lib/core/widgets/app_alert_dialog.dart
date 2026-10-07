import '../core.dart';

// ============================================================
// appAlertDialog — success / error / notice বার্তা
// ------------------------------------------------------------
// আগে CupertinoAlertDialog ছিল (desktop এ iOS এর মতো দেখাত)।
// এখন AppPopoverCard — একই parameter, তাই কোনো call site বদলাতে
// হয়নি।
//
// actions খালি থাকলে একটা "OK" বাটন দেওয়া হয় — আগে actions ছাড়া
// আর barrierDismissible = false হলে user আটকে যেত, বন্ধ করার কোনো
// উপায় থাকত না।
// ============================================================

Future<void> appAlertDialog(
  BuildContext context,
  String content, {
  List<Widget> actions = const <Widget>[],
  bool barrierDismissible = false,
  String? title,
  Color color = AppColors.textLight,
  IconData icon = Icons.warning,
}) async {
  final PopoverTone tone = _toneFor(icon, title);

  await showAppPopover<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext ctx) {
      return AppPopoverCard(
        width: 420,
        tone: tone,
        icon: Icon(icon),
        title: Text(title ?? 'Notice'),
        content: content.isEmpty ? null : Text(content),
        actions: actions.isNotEmpty
            ? actions
            : [
                PopoverButton(
                  label: 'OK',
                  primary: true,
                  tone: tone,
                  autofocus: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
      );
    },
  );
}

/// icon / title দেখে রং ঠিক করা — success সবুজ, error লাল, বাকি নীল
PopoverTone _toneFor(IconData icon, String? title) {
  final t = (title ?? '').toLowerCase();
  if (icon == Icons.check_circle ||
      icon == Icons.check ||
      icon == Icons.done ||
      t.contains('success')) {
    return PopoverTone.success;
  }
  if (icon == Icons.error ||
      icon == Icons.error_outline ||
      t.contains('error') ||
      t.contains('fail')) {
    return PopoverTone.danger;
  }
  if (icon == Icons.warning || icon == Icons.warning_amber) {
    return PopoverTone.warning;
  }
  return PopoverTone.normal;
}

/// Yes / Cancel ধরনের প্রশ্ন — true ফেরত দিলে user রাজি
Future<bool> appAdaptiveDialog({
  required BuildContext context,
  required String title,
  required String message,
  List<AdaptiveDialogAction>? actions,
}) async {
  if (actions == null) {
    return showConfirmPopover(
      context,
      title: title,
      message: message,
      confirmText: 'Yes',
    );
  }

  final result = await showAppPopover<bool>(
    context: context,
    builder: (ctx) => AppPopoverCard(
      width: 420,
      title: Text(title),
      content: Text(message),
      actions: actions
          .map(
            (a) => PopoverButton(
              label: a.text,
              primary: a.isDefault || a.isDestructive,
              tone: a.isDestructive ? PopoverTone.danger : PopoverTone.normal,
              autofocus: a.isDefault,
              onPressed: a.onPressed,
            ),
          )
          .toList(),
    ),
  );
  return result ?? false;
}

class AdaptiveDialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;

  AdaptiveDialogAction({
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}
