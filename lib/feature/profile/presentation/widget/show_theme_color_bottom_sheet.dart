import 'package:easy_localization/easy_localization.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';
import '../../../common/presentation/cubit/theme_cubit.dart';

// সব রঙ সাদা লেখার সাথে পড়ার মতো গাঢ়। (আগে White/Yellow/Lime ছিল — প্রাইমারি করলে বাটন ও হেডার অদৃশ্য হতো)
final List<Map<String, dynamic>> colors = const [
  {'color': Color(0xff2563EB), 'name': 'Royal Blue'},
  {'color': Color(0xff4F46E5), 'name': 'Indigo'},
  {'color': Color(0xff7C3AED), 'name': 'Violet'},
  {'color': Color(0xff0891B2), 'name': 'Cyan'},
  {'color': Color(0xff0D9488), 'name': 'Teal'},
  {'color': Color(0xff059669), 'name': 'Emerald'},
  {'color': Color(0xff16A34A), 'name': 'Green'},
  {'color': Color(0xffD97706), 'name': 'Amber'},
  {'color': Color(0xffEA580C), 'name': 'Orange'},
  {'color': Color(0xffDC2626), 'name': 'Red'},
  {'color': Color(0xffE11D48), 'name': 'Rose'},
  {'color': Color(0xffDB2777), 'name': 'Pink'},
  {'color': Color(0xff92400E), 'name': 'Brown'},
  {'color': Color(0xff475569), 'name': 'Slate'},
];

void showThemeColorBottomSheet(
  BuildContext context,
  ThemeCubit themeCubit,
  Color currentColor,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showAppPopoverSheet(
    context: context,
    backgroundColor: AppColors.bottomNavBg(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(14),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                gapW8,
                Text(
                  'choose_theme_color'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    AppRoutes.pop(context);
                  },
                  icon: Icon(
                    HugeIcons.strokeRoundedCancelSquare,
                    color: AppColors.errorColor(context),
                  ),
                ),
              ],
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
                      c['color'].value.toString(),
                    );
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
                            color: selected ? c['color'] : Colors.grey.shade300,
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
