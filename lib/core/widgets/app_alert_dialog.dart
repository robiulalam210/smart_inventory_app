import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../core.dart';

Future<void> appAlertDialog(BuildContext context, String content,
    {List<Widget> actions = const <Widget>[],
    bool barrierDismissible = false,
    String? title,
    Color color = AppColors.textLight,
    IconData icon = Icons.warning}) async {
  final alert = CupertinoAlertDialog(
    // titlePadding: EdgeInsets.zero,
    title: Row(
      children: [
        Icon(
          icon,
          color: AppColors.text(context)
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          title ?? "Notice",
          style:  TextStyle(color: AppColors.text(context)),
        ),
      ],
    ),
    content: content.isEmpty ? null : Text(content,style: TextStyle(
      color: AppColors.text(context)
    ),),
    actions: actions,
  );

  showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


Future<bool> appAdaptiveDialog({
  required BuildContext context,
  required String title,
  required String message,
  List<AdaptiveDialogAction>? actions,
}) async {
  final defaultActions = [
    AdaptiveDialogAction(
      text: 'Cancel',
      onPressed: () => Navigator.of(context).pop(false),
    ),
    AdaptiveDialogAction(
      text: 'Yes',
      isDefault: true,
      onPressed: () => Navigator.of(context).pop(true),
    ),
  ];

  final combinedActions = actions ?? defaultActions;

  if (Platform.isIOS) {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(

        // backgroundColor: AppColors.bottomNavBg(context),
        title: Text(title,style: AppTextStyle.bodyLarge(context),),
        content: Text(message,style: AppTextStyle.body(context),),
        actions: combinedActions.map((action) {
          return CupertinoDialogAction(

            onPressed: action.onPressed,
            isDestructiveAction: action.isDestructive,
            isDefaultAction: action.isDefault,
            child: Text(action.text),
          );
        }).toList(),
      ),
    ) ??
        false;
  } else {
    return await showDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(

        // backgroundColor: AppColors.bottomNavBg(context),
        title: Text(title,style: AppTextStyle.bodyLarge(context),),
        content: Text(message,style: AppTextStyle.body(context),),
        actions: combinedActions.map((action) {
          return TextButton(
            onPressed: action.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: action.isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            child: Text(action.text),
          );
        }).toList(),
      ),
    ) ??
        false;
  }
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
