import '../core.dart';

/// Delete নিশ্চিতকরণ — আগে AlertDialog ছিল, এখন desktop popover।
/// true = Delete, false = Cancel / বাইরে ক্লিক / Esc
Future<bool> showDeleteConfirmationDialog(BuildContext context) {
  return showConfirmPopover(
    context,
    title: 'Delete Confirmation',
    message: 'Are you sure you want to delete this?\nThis action cannot be undone.',
    confirmText: 'Delete',
    tone: PopoverTone.danger,
  );
}
