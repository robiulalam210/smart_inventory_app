
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
      tileColor: isSelected ? Colors.blue.withValues(alpha: 0.1) : null, // Background color for selected item
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected
              ? Colors.blue // Text color for selected item
              :  AppColors.text(context),
        ),
      ),
      onTap: onPressed,
    );
  }
}
