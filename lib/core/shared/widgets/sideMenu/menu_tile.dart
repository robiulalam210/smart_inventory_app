
import '../../../widgets/web_ui.dart';
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
    // ওয়েবের .sb-link: ১০px কোণা; চালু থাকলে হালকা নীল-wash + নীল লেখা (সেমি-বোল্ড)
    final primary = AppColors.primaryColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: isSelected
            ? primary.withValues(alpha: W.dark(context) ? 0.16 : 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primary : W.ink2(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
