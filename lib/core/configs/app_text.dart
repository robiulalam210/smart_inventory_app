
import 'configs.dart';

class AppTextStyle {
  // Define your custom font family
  static const String fontFamily = 'Roboto';

  static TextStyle titleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(fontFamily: fontFamily);

  static TextStyle headlineMedium(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(fontFamily: fontFamily);

  static TextStyle headlineSmall(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!.copyWith(fontFamily: fontFamily);

  static TextStyle titleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(fontFamily: fontFamily);

  static TextStyle titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(fontFamily: fontFamily);

  static TextStyle displaySmall(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall!.copyWith(fontFamily: fontFamily);

  static TextStyle bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(fontFamily: fontFamily);

  static TextStyle bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: fontFamily);

  static TextStyle appBarTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = AppColors.whiteColor(context);

    return Responsive.isMobile(context)
        ? textTheme.labelLarge!.copyWith(
      color: color,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    )
        : textTheme.headlineSmall!.copyWith(
      color: color,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle titleBold(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.text(context),
    fontFamily: fontFamily,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text(context),
    fontFamily: fontFamily,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 14,
    color: AppColors.text(context),
    fontFamily: fontFamily,
    fontStyle: FontStyle.normal,
    height: 13 / 10,
    letterSpacing: -0.32,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text(context),
    fontFamily: fontFamily,
  );
  static TextStyle headerTitle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
          color:AppColors.blackColor(context),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700);

  static TextStyle headerTitleWhite(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: AppColors.whiteColor(context),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700);

  static TextStyle drawerTextStyleWhite(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.bodyMedium!.copyWith(
      fontFamily: fontFamily,
      color: AppColors.whiteColor(context),
      fontWeight: FontWeight.w700,
    )
        : textTheme.headlineSmall!.copyWith(
      color: AppColors.whiteColor(context),
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle drawerConditionTextStyle(BuildContext context, isTrue) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.bodyMedium!.copyWith(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
    )
        : textTheme.headlineSmall!.copyWith(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    )
        : textTheme.labelLarge!.copyWith(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle cardLevelHead(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color =AppColors.blackColor(context);

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
      color: color,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
    )
        : textTheme.labelSmall!.copyWith(
      color: color,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle cardLevelText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    )
        : textTheme.labelSmall!.copyWith(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle cardLevelTextWhiteColor(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
      fontFamily: fontFamily,
      color: AppColors.whiteColor(context),
      fontWeight: FontWeight.w500,
    )
        : textTheme.bodyMedium!.copyWith(
      color: AppColors.whiteColor(context),
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle searchTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color =AppColors.blackColor(context);

    return Responsive.isMobile(context)
        ? textTheme.labelSmall!.copyWith(
      color: color,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    )
        : textTheme.labelSmall!.copyWith(
      color: color,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle labelDropdownTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelMedium!.copyWith(
      fontFamily: fontFamily,
      color:AppColors.blackColor(context),
      fontWeight: FontWeight.w400,
    )
        : textTheme.labelMedium!.copyWith(
      color:AppColors.blackColor(context),
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle buttonTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Responsive.isMobile(context)
        ? textTheme.labelLarge!.copyWith(
      fontFamily: fontFamily,
      color: AppColors.whiteColor(context),
      fontSize: 14,
      fontWeight: FontWeight.w300,
    )
        : textTheme.bodyLarge!.copyWith(
      color: AppColors.whiteColor(context),
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle errorTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
          color: AppColors.errorColor(context),
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700);

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