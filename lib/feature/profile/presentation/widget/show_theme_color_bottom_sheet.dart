import 'package:easy_localization/easy_localization.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';
import '../../../common/presentation/cubit/theme_cubit.dart';
final List<Map<String, dynamic>> colors = const [
  {'color': Color(0xff60DAFF), 'name': 'Default'},
  {'color': Color(0xff69B128), 'name': 'Default 2'},
  {'color': Colors.red, 'name': 'Red'},
  {'color': Colors.pink, 'name': 'Pink'},
  {'color': Colors.purple, 'name': 'Purple'},
  {'color': Colors.deepPurple, 'name': 'Deep Purple'},
  {'color': Colors.indigo, 'name': 'Indigo'},
  {'color': Colors.blue, 'name': 'Blue'},
  {'color': Colors.lightBlue, 'name': 'Light Blue'},
  {'color': Colors.cyan, 'name': 'Cyan'},
  {'color': Colors.teal, 'name': 'Teal'},
  {'color': Colors.green, 'name': 'Green'},
  {'color': Colors.lightGreen, 'name': 'Light Green'},
  {'color': Colors.lime, 'name': 'Lime'},
  {'color': Colors.yellow, 'name': 'Yellow'},
  {'color': Colors.amber, 'name': 'Amber'},
  {'color': Colors.orange, 'name': 'Orange'},
  {'color': Colors.deepOrange, 'name': 'Deep Orange'},
  {'color': Colors.brown, 'name': 'Brown'},
  {'color': Colors.grey, 'name': 'Grey'},
  {'color': Colors.blueGrey, 'name': 'Blue Grey'},
  {'color': Colors.black, 'name': 'Black'},
  {'color': Colors.white, 'name': 'White'},
];

void showThemeColorBottomSheet(
    BuildContext context,
    ThemeCubit themeCubit,
    Color currentColor,
    ) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF23272B) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'choose_theme_color'.tr(),
              style:  TextStyle(
                fontSize: 18,
                color: AppColors.text(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                final selected = c['color'].value == currentColor.value;
                return GestureDetector(
                  onTap: () async {
                    themeCubit.setPrimaryColor(c['color']);
                    await AuthLocalDB.savePrimaryColor(
                        c['color'].value.toString());
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: c['color'],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? c['color']
                                : Colors.grey.shade300,
                            width: selected ? 3 : 1,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c['name'],
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? c['color']
                              : isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}