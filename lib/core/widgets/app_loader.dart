import '../core.dart';

/// Loading popover — barrierDismissible false, তাই X বাটন / Esc / বাইরে
/// ক্লিকে বন্ধ হয় না। কাজ শেষে caller নিজেই Navigator.pop() করে।
Future<void> appLoader(BuildContext context, String msg) async {
  await showAppPopover<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctx) {
      return AppPopoverCard(
        width: 280,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/jsons/loader.json', height: 90, width: 90),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppTextStyle.body(context),
            ),
          ],
        ),
      );
    },
  );
}
