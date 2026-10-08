import 'package:easy_localization/easy_localization.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';
import 'package:meherinMart/core/widgets/app_dropdown.dart';

Widget languageDropdown(BuildContext context) {
  final Map<String, String> languages = {'en': 'English', 'bn': 'বাংলা'};

  final currentCode = context.locale.languageCode;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.11),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.translate,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text("language".tr(), style: AppTextStyle.body(context)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
  width: 150,
  // search সহ dropdown (সব dropdown এ search থাকবে)
  child: AppDropdown<String>(
    key: ValueKey(currentCode),
    label: 'Language',
    hint: 'Language',
    value: currentCode,
    isClearable: false,
    itemList: languages.keys.toList(),
    itemLabel: (code) => languages[code] ?? code,
    onChanged: (value) async {
      if (value != null) {
        context.setLocale(Locale(value));
        await AuthLocalDB.saveLanguage(value);
      }
    },
  ),
),
        ),
      ],
    ),
  );
}
