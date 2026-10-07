
import '../../../configs/configs.dart';

class MenuTile extends StatelessWidget {
  final bool isSubmenu;
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const MenuTile({
    required this.isSubmenu,
    required this.title,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isSelected ? AppColors.info.withValues(alpha: 0.1) : null, // Background color for selected item
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected
              ? AppColors.info // Text color for selected item
              :  AppColors.text(context),
        ),
      ),
      onTap: onPressed,
    );
  }
}

/// শুধু মোবাইল ড্রয়ারের জন্য — desktop/tablet এর MenuTile অপরিবর্তিত — নির্বাচিত হলে ব্র্যান্ড রঙে হাইলাইট।
class MobileMenuTile extends StatelessWidget {
  final bool isSubmenu;
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const MobileMenuTile({
    required this.isSubmenu,
    required this.title,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? primary.withValues(alpha: 0.12) : null,
        leading: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? primary
                : AppColors.text(context).withValues(alpha: 0.25),
          ),
        ),
        horizontalTitleGap: 8,
        minLeadingWidth: 6,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? primary
                : AppColors.text(context).withValues(alpha: 0.9),
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}
