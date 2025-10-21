import '../core.dart';

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Delete Confirmation',
          style: AppTextStyle.cardTitle(context),
        ),
        content: Text(
          'Are you sure you want to delete this expense head?',
          style: AppTextStyle.cardLevelText(context),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm delete
            },
            child: Text(
                'Delete',
                style: AppTextStyle.errorTextStyle(context)
            ),
          ),
        ],
      );
    },
  ) ?? false;
}