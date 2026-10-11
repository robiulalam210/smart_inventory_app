import 'package:google_fonts/google_fonts.dart';
import 'configs.dart';

class AppTextStyle {
  // ওয়েবের মতো একই ফন্ট: IBM Plex Sans (ইংরেজি/সংখ্যা) + Hind Siliguri (বাংলা)
  static String get fontFamily => GoogleFonts.ibmPlexSans().fontFamily!;
  static List<String> get fontFallback => [GoogleFonts.hindSiliguri().fontFamily!];

  static TextStyle titleLarge(BuildContext context) => Theme.of(context)
      .textTheme
      .titleLarge!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle headlineMedium(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle headlineSmall(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineSmall!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle titleMedium(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle titleSmall(BuildContext context) => Theme.of(context)
      .textTheme
      .titleSmall!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle displaySmall(BuildContext context) => Theme.of(context)
      .textTheme
      .displaySmall!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle bodySmall(BuildContext context) => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle bodyLarge(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyLarge!
      .copyWith(fontFamily: fontFamily, fontFamilyFallback: fontFallback, color: AppColors.text(context));

  static TextStyle appBarTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = AppColors.whiteColor(context);

    return Responsive.isMobile(context)
        ? textTheme.labelLarge!.copyWith(
            color: color,
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w500,
          )
        : textTheme.headlineSmall!.copyWith(
            color: color,
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w600,
          );
  }

  static TextStyle titleBold(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.text(context),
    fontFamily: fontFamily, fontFamilyFallback: fontFallback,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text(context),
    fontFamily: fontFamily, fontFamilyFallback: fontFallback,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 14,
    color: AppColors.text(context),
    fontFamily: fontFamily, fontFamilyFallback: fontFallback,
    fontStyle: FontStyle.normal,
    height: 13 / 10,
    letterSpacing: -0.32,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text(context),
    fontFamily: fontFamily, fontFamilyFallback: fontFallback,
  );

  static TextStyle headerTitle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: AppColors.text(context),
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        fontWeight: FontWeight.w700,
      );

  static TextStyle headerTitleWhite(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: AppColors.whiteColor(context),
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        fontWeight: FontWeight.w700,
      );

  static TextStyle drawerTextStyleWhite(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.bodyMedium!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            color: AppColors.whiteColor(context),
            fontWeight: FontWeight.w700,
          )
        : textTheme.headlineSmall!.copyWith(
            color: AppColors.whiteColor(context),
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w700,
          );
  }

  static TextStyle drawerConditionTextStyle(BuildContext context, isTrue) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.bodyMedium!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w700,
            color: AppColors.text(context),
          )
        : textTheme.headlineSmall!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w700,
            color: AppColors.text(context),
          );
  }

  static TextStyle cardTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          )
        : textTheme.labelLarge!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontSize: 14,

            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          );
  }

  static TextStyle cardLevelHead(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        color: AppColors.text(context),
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        fontSize: 12,

        fontWeight: FontWeight.w500,
      );

  static TextStyle cardLevelText(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        color: AppColors.text(context),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle cardLevelTextWhiteColor(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            color: AppColors.whiteColor(context),
            fontWeight: FontWeight.w500,
          )
        : textTheme.bodyMedium!.copyWith(
            color: AppColors.whiteColor(context),
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontWeight: FontWeight.w600,
          );
  }

  static TextStyle searchTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        color: AppColors.text(context),
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        fontWeight: FontWeight.w500,
      );

  static TextStyle labelDropdownTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        color: AppColors.text(context),
        fontWeight: FontWeight.w400,
      );

  static TextStyle buttonTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelLarge!.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            color: AppColors.whiteColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          )
        : textTheme.bodyLarge!.copyWith(
            color: AppColors.whiteColor(context),
            fontFamily: fontFamily, fontFamilyFallback: fontFallback,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          );
  }

  static TextStyle errorTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
        color: AppColors.errorColor(context),
        fontFamily: fontFamily, fontFamilyFallback: fontFallback,
        fontWeight: FontWeight.w700,
      );

  static EdgeInsets getResponsivePaddingBody(BuildContext context) {
    return Responsive.isMobile(context)
        ? const EdgeInsets.symmetric(vertical: 6, horizontal: 10)
        : const EdgeInsets.symmetric(vertical: 15, horizontal: 15);
  }

  static EdgeInsets getResponsivePaddingBodyNotMobile(BuildContext context) {
    return Responsive.isMobile(context)
        ? const EdgeInsets.symmetric(vertical: 2, horizontal: 2)
        : const EdgeInsets.symmetric(vertical: 15, horizontal: 35);
  }
}
