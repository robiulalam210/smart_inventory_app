 import '../../feature/common/presentation/cubit/theme_cubit.dart';
import 'configs.dart';

 class AppColors {
   static const Color error = Color(0xffE53935);
   static const Color grey = Color.fromARGB(255, 159, 159, 159);
   static const Color lightGrey = Color.fromARGB(255, 231, 231, 231);
   static const Color white = Color(0xffffffff);
   static const Color black = Colors.black;

   // Light theme defaults
   static const Color lightBg = Color(0xFFEFF9FF);
   static const Color lightBgBottomNav = Color(0xFFF6FCFF);
   static const Color lightText = Color(0xff000000);

   // Dark theme defaults
   static const Color darkBg = Color(0xFF14171C);
   static const Color darkBgBottomNav = Color(0xFF191A22);
   static const Color darkText = Color(0xFFF2F2F2);

   // Default fallback for brand color (can be replaced by ThemeCubit)
   // static const Color defaultPrimary = Color(0xff60DAFF);
   static const Color defaultPrimary = Color(0xff60DAFF);

   /// Get current theme primary color, falling back if Cubit not present.
   static Color primaryColor(BuildContext context) {
     try {
       final themeState = context.watch<ThemeCubit>().state;
       return themeState.primaryColor;
     } catch (_) {
       return defaultPrimary;
     }
   }

   static Color secondary(BuildContext context) =>
       _soften(primaryColor(context), 0.4);

   static Color primaryLight(BuildContext context) =>
       _lighten(primaryColor(context), 0.25);

   static Color primaryDark(BuildContext context) =>
       _darken(primaryColor(context), 0.15);

   /// Theme-aware background color
   static Color background(BuildContext context) =>
       Theme.of(context).brightness == Brightness.dark
           ? darkBg
           : lightBg;

   static Color bottomNavBg(BuildContext context) =>
       Theme.of(context).brightness == Brightness.dark
           ? darkBgBottomNav
           : lightBgBottomNav;

   static Color text(BuildContext context) =>
       Theme.of(context).brightness == Brightness.dark
           ? darkText
           : lightText;

   static LinearGradient primaryGradient(BuildContext context) =>
       buildGradient(primaryColor(context));

   static LinearGradient buildGradient(Color base) => LinearGradient(
     begin: Alignment.topLeft,
     end: Alignment.bottomRight,
     colors: [
       _lighten(base, 0.15),
       _darken(base, 0.05),
     ],
   );

   // Utility helpers for color manipulation
   static Color _lighten(Color color, [double amount = .1]) {
     final hsl = HSLColor.fromColor(color);
     final hslLight =
     hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
     return hslLight.toColor();
   }

   static Color _darken(Color color, [double amount = .1]) {
     final hsl = HSLColor.fromColor(color);
     final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
     return hslDark.toColor();
   }

   static Color _soften(Color color, [double amount = .3]) {
     final hsl = HSLColor.fromColor(color);
     final hslSoft = hsl
         .withSaturation((hsl.saturation * (1 - amount)).clamp(0.0, 1.0))
         .withLightness((hsl.lightness + amount * 0.4).clamp(0.0, 1.0));
     return hslSoft.toColor();
   }


   // Static error, white, black, greys for all modes
   static Color errorColor(BuildContext context) => error;
   static Color greyColor(BuildContext context) => grey;
   static Color lightGreyColor(BuildContext context) => lightGrey;
   static Color whiteColor(BuildContext context) => white;
   static Color blackColor(BuildContext context) => black;








  static const Color matteBlack = Color(0xff28282B);
  // static const Color seed = Colors.redAccent;
  static const Color link = Colors.blue;
  static const Color blue = Colors.blueAccent;
  static const Color subText = Colors.blueGrey;
  static const Color disable = Colors.grey;
  static const Color green = Colors.greenAccent;
  static const Color orange = Colors.orangeAccent;
  static Color border = Colors.grey.shade400;
  static const Color red = Colors.red;
  static const Color redAccent = Colors.redAccent;
  static const Color pay = Colors.deepOrange;

  // static const Color              = Color(0xFF6ab129);
  static const Color primaryColorBg             = Color(0xFFCEE2CE);
  static const Color bg               = Color(0xffEFF9FF);
  static const Color lightGreen               = Color(0xFFFCFCFC);
  static const Color black50Color               = Color(0xFF353535);
  static const Color white50Color               = Color(0xFF9E9E9E);
  static Color onInverseSurface(BuildContext context) => Theme.of(context).colorScheme.onInverseSurface;
  static Color systemBg(BuildContext context) => Theme.of(context).colorScheme.surface;


  static Color surfaceVariant(BuildContext context) => Theme.of(context).colorScheme.surface; // use surfaceVariant instead of surfaceContainerHighest if needed


  static const Color redColor             = Colors.redAccent;
  // static const Color blueGrey         = Colors.blueGrey;
  // static const Color warning          = Colors.amber;
  static Color focusColor(BuildContext context)    => Theme.of(context).focusColor;
  // static Color disabledColor(context) => Theme.of(context).disabledColor;

  static const Color seed = Color(0xff18B4E9);

  // static const Color seed = Color(0xFFFF2D55);
  static const Color selected = Color(0xff004ca8);
  static const Color holidayBlue = Color(0xff0085d4);

  static Color disabledColor(BuildContext context) => Theme.of(context).disabledColor;

  static Color scaffoldBackgroundColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor; //nav disable
  static Color hoverColor(BuildContext context) => Theme.of(context).hoverColor; //nav border


  static Color outline(BuildContext context) => Theme.of(context).colorScheme.outline;

  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;


  static Color onSurfaceVariant(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;



  static Color inversePrimary(BuildContext context) => Theme.of(context).colorScheme.inversePrimary;

  static Color primaryContainer(BuildContext context) => Theme.of(context).colorScheme.primaryContainer;

  static Color onPrimaryContainer(BuildContext context) => Theme.of(context).colorScheme.onPrimaryContainer;

  static Color onPrimary(BuildContext context) => Theme.of(context).colorScheme.onPrimary;

  static Color onSecondary(BuildContext context) => Theme.of(context).colorScheme.onSecondary;

  static Color tertiary(BuildContext context) => Theme.of(context).colorScheme.tertiary;

  static Color tertiaryContainer(BuildContext context) => Theme.of(context).colorScheme.tertiaryContainer; //near by yellow

  static Color onSurface(BuildContext context) => Theme.of(context).colorScheme.onSurface;

  static Color inverseSurface(BuildContext context) => Theme.of(context).colorScheme.inverseSurface;

  static Color onSecondaryContainer(BuildContext context) => Theme.of(context).colorScheme.onSecondaryContainer;


  static Color secondaryContainer(BuildContext context) => Theme.of(context).colorScheme.secondaryContainer;
  static const bgLight = Color(0xFFF4F4F4);
  static const bgSecondaryLight = Color(0xFFFCFCFC);
  static const titleLight = Color(0xFF272B30);
  static const textLight = Color(0xFF6F767E);
  static const textGrey = Color(0xFF9A9FA5);
  static const iconLight = Color(0xFF272B30);
  static const iconBlack = Color(0xFF1A1D1F);
  static const iconGrey = Color(0xFF9A9FA5);
  static const highlightLight = Color(0xFFEFEFEF);

  // static const primary = Color(0xFF2A85FF);

  static const secondaryPeach = Color(0xFFFFBC99);
  static const secondaryLavender = Color(0xFFCABDFF);
  static const secondaryBabyBlue = Color(0xFFB1E5FC);
  static const secondaryMintGreen = Color(0xFFB5E4CA);
  static const secondaryPaleYellow = Color(0xFFFFD88D);

  static  LinearGradient linearGradient=LinearGradient(
      begin: Alignment.topLeft,
      end: const Alignment(0.80, 0.80),
      colors: [
        Colors.green.shade50,
        Colors.blue.shade50,
      ]
  );





 }
