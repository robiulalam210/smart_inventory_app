import 'core/configs/configs.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? smallDesktop;
  final Widget? desktop;
  final Widget? maxDesktop;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    this.smallDesktop,
    this.desktop,
    this.maxDesktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 900;

  static bool isSmallDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900 &&
          MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200 &&
          MediaQuery.of(context).size.width < 1600;

  static bool isMaxDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1600 && maxDesktop != null) {
      return maxDesktop!;
    } else if (width >= 1200 && desktop != null) {
      return desktop!;
    } else if (width >= 900 && smallDesktop != null) {
      return smallDesktop!;
    } else if (width >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

// Responsive Row Widget
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 0,
    this.runSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,

          spacing: spacing,
          runSpacing: runSpacing,
          children: children,
        );
      },
    );
  }
}

// Responsive Column Widget
class ResponsiveCol extends StatelessWidget {
  final int? xs;
  final int? sm;
  final int? md;
  final int? lg;
  final int? xl;
  final Widget child;

  const ResponsiveCol({
    super.key,
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int? columns;

        if (width >= 2600 && xl != null) {
          columns = xl;
        } else if (width >= 1200 && lg != null) {
          columns = lg;
        } else if (width >= 900 && md != null) {
          columns = md;
        } else if (width >= 600 && sm != null) {
          columns = sm;
        } else {
          columns = xs;
        }

        if (columns == null || columns <= 0) {
          return child;
        }

        final colWidth = width / 12 * columns;
        return SizedBox(
          width: colWidth,
          child: child,
        );
      },
    );
  }
}



