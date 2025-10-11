import 'configs.dart';

class AppColors{

  static const Color matteBlack = Color(0xff28282B);
  // static const Color seed = Colors.redAccent;
  static const Color link = Colors.blue;
  static const Color blue = Colors.blueAccent;
  static const Color text = matteBlack;
  static const Color subText = Colors.blueGrey;
  static const Color disable = Colors.grey;
  static const Color grey = Colors.grey;
  static const Color green = Colors.greenAccent;
  static const Color orange = Colors.orangeAccent;
  static Color border = Colors.grey.shade400;
  static const Color white = Colors.white;
  static const Color red = Colors.red;
  static const Color redAccent = Colors.redAccent;
  static const Color error = Color(0xffb00020);
  static const Color pay = Colors.deepOrange;


  static const Color primaryColor             = Color(0xFF6ab129);
  static const Color primaryColorBg             = Color(0xFFCEE2CE);
  static const Color bg               = Color(0xFFF3f2ef);
  static const Color lightGreen               = Color(0xFFFCFCFC);
  static const Color whiteColor               =Color(0xFFFFFFFF);
  static const Color blackColor               = Color(0xFF191919);
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

  static Color secondary(BuildContext context) => Theme.of(context).colorScheme.secondary;

  static Color primary(BuildContext context) => Theme.of(context).colorScheme.primary;

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