import 'package:easy_localization/easy_localization.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/database/auth_db.dart';

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
          child: DropdownButton<String>(
            value: currentCode,
            underline: const SizedBox(),
            dropdownColor: Theme.of(context).cardColor,
            icon: const Icon(Icons.arrow_drop_down),
            items: languages.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, style: AppTextStyle.body(context)),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                context.setLocale(Locale(value));
                await AuthLocalDB.saveLanguage(value);
              }
            },
          ),
        ),
      ],
    ),
  );
}
