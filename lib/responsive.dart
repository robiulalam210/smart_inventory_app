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

/// Root screen যখন বাঁয়ে স্থায়ী (fixed) sidebar দেখায়, তখন এই scope মূল content এর উপরে বসে।
/// scope থাকলে পুরোনো screen গুলোর নিজস্ব sidebar column আর দেখানো হয় না,
/// আর content column ১২ ভাগই পায় — ফলে ~৪০টা screen আলাদা করে বদলাতে হয়নি।
class PermanentSidebarScope extends InheritedWidget {
  const PermanentSidebarScope({super.key, required super.child});

  static bool active(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PermanentSidebarScope>() != null;

  @override
  bool updateShouldNotify(PermanentSidebarScope oldWidget) => false;
}

// Responsive Column Widget
class ResponsiveCol extends StatelessWidget {
  final double? xs;
  final double? sm;
  final double? md;
  final double? lg;
  final double? xl;
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
        double? columns;

        // স্থায়ী sidebar থাকলে: পুরোনো sidebar column (xs:0, lg:2, xl:2) লুকাও,
        // আর content column (lg:10) কে পুরো ১২ ভাগ দাও।
        if (PermanentSidebarScope.active(context)) {
          if (xs == 0 && lg == 2 && xl == 2) return const SizedBox.shrink();
          if (lg == 10 && (xl == null || xl == 10)) {
            return SizedBox(width: width, child: child);
          }
        }

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

        final double colSpan = columns ?? 12; // fallback
        final double colWidth = width / 12 * colSpan;

        return SizedBox(
          width: colWidth,
          child: child,
        );
      },
    );
  }
}

// class ResponsiveCol extends StatelessWidget {
//   final int? xs;
//   final int? sm;
//   final int? md;
//   final int? lg;
//   final int? xl;
//   final Widget child;
//
//   const ResponsiveCol({
//     super.key,
//     this.xs,
//     this.sm,
//     this.md,
//     this.lg,
//     this.xl,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         int? columns;
//
//         if (width >= 2600 && xl != null) {
//           columns = xl;
//         } else if (width >= 1200 && lg != null) {
//           columns = lg;
//         } else if (width >= 900 && md != null) {
//           columns = md;
//         } else if (width >= 600 && sm != null) {
//           columns = sm;
//         } else {
//           columns = xs;
//         }
//
//         if (columns == null || columns <= 0) {
//           return child;
//         }
//
//         final colWidth = width / 12 * columns;
//         return SizedBox(
//           width: colWidth,
//           child: child,
//         );
//       },
//     );
//   }
// }



