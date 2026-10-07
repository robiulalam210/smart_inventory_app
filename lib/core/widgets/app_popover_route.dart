import 'dart:math' as math;

import '../configs/configs.dart';

// ============================================================
// APP POPOVER (route-based) — Desktop এর জন্য Dialog / BottomSheet এর বদল
// ------------------------------------------------------------
// কেন route-based?
//   পুরো app এ ১০০+ জায়গায় showDialog / showModalBottomSheet আছে, আর
//   প্রায় সবখানেই বন্ধ করা হয় `Navigator.pop(context, result)` দিয়ে।
//   শুধু OverlayEntry ব্যবহার করলে ওই Navigator.pop() ভুল করে পুরো
//   page টাই pop করে দিত। তাই popover টা একটা হালকা PopupRoute এর
//   ভিতরে বসানো হয়েছে:
//     • দেখতে popover এর মতো — সাদা card, হালকা shadow, drag handle,
//       বাটনের পাশে (anchored) অথবা পর্দার মাঝে (aligned) খোলে
//     • আচরণে আগের মতোই — Navigator.pop(context, x) হুবহু কাজ করে,
//       Esc চাপলে বন্ধ হয়, focus ঠিক থাকে, ভিতরের dropdown এর
//       suggestion popover এর উপরে দেখা যায়
//
//   placement এর হিসাব app_popover.dart এর resolvePopoverPlacement /
//   resolveAlignedPlacement থেকেই নেওয়া — তাই overlay popover আর এই
//   route popover দুটো একই নিয়মে বসে।
//
// কোনটা কখন:
//   showAppPopover()        — showDialog() এর জায়গায়
//   showAppPopoverSheet()   — showModalBottomSheet() এর জায়গায়
//   showConfirmPopover()    — Delete / Yes-No নিশ্চিতকরণ
//   AppPopoverCard          — AlertDialog / CupertinoAlertDialog এর জায়গায়
//   AppPopoverShell         — Dialog এর জায়গায় (নিজস্ব form/child এর জন্য)
// ============================================================

/// popover কোথায় বসবে
enum PopoverAnchorMode {
  /// যে widget থেকে খোলা হলো সেটা ছোট (বাটন / field) হলে তার পাশে,
  /// বড় (পুরো screen) হলে পর্দার মাঝে
  auto,

  /// সবসময় যে widget থেকে খোলা হলো তার ঠিক নিচে/উপরে
  anchored,

  /// anchor উপেক্ষা করে align অনুযায়ী (start / center / end)
  aligned,
}

/// confirm popover এর রং
enum PopoverTone { normal, danger, warning, success }

const double _kPopoverRadius = 14;
const double _kPopoverEdge = 16;

// ------------------------------------------------------------
// showAppPopover — showDialog() এর drop-in বদল
// ------------------------------------------------------------
// showDialog এর সব parameter এখানে আছে, তাই call site এ শুধু নাম
// বদলালেই চলে। বাড়তি option: mode, align, width।
// ------------------------------------------------------------

Future<T?> showAppPopover<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  bool? requestFocus,
  PopoverAnchorMode mode = PopoverAnchorMode.auto,
  PopoverAlign align = PopoverAlign.center,

  /// anchored popover এর নির্দিষ্ট প্রস্থ (null = content অনুযায়ী)
  double? width,

  /// anchored হলে anchor এর সমান প্রস্থ নেবে (dropdown এর জন্য)
  bool matchAnchorWidth = false,
}) {
  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);

  final Rect? anchorRect = _resolveAnchorRect(context, navigator, mode);

  return navigator.push<T>(
    AppPopoverRoute<T>(
      builder: builder,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ??
          Colors.black.withValues(alpha: anchorRect != null ? 0.06 : 0.22),
      barrierLabel: barrierLabel ??
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      anchorRect: anchorRect,
      align: align,
      width: width ??
          (matchAnchorWidth && anchorRect != null
              ? math.max(anchorRect.width, 260.0)
              : null),
      settings: routeSettings,
    ),
  );
}

// ------------------------------------------------------------
// showAppPopoverSheet — showModalBottomSheet() এর drop-in বদল
// ------------------------------------------------------------
// desktop এ নিচ থেকে উঠে আসা sheet অদ্ভুত লাগে (বড় monitor এ চোখকে
// পর্দার একদম নিচে যেতে হয়)। তাই একই content একটা popover card এ
// দেখানো হয়। bottom sheet এর সব parameter গ্রহণ করা হয় যাতে call
// site না ভাঙে; যেগুলো desktop এ অর্থহীন (enableDrag ইত্যাদি) সেগুলো
// উপেক্ষা করা হয়।
// ------------------------------------------------------------

Future<T?> showAppPopoverSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
  AnimationStyle? sheetAnimationStyle,
  bool? requestFocus,
  PopoverAnchorMode mode = PopoverAnchorMode.aligned,
  PopoverAlign align = PopoverAlign.center,
  double? width,
}) {
  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);

  final Rect? anchorRect = _resolveAnchorRect(context, navigator, mode);

  return navigator.push<T>(
    AppPopoverRoute<T>(
      builder: builder,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      barrierDismissible: isDismissible,
      barrierColor: barrierColor ??
          Colors.black.withValues(alpha: anchorRect != null ? 0.06 : 0.22),
      barrierLabel: barrierLabel ??
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      anchorRect: anchorRect,
      align: align,
      width: width ??
          (constraints != null
              ? constraints.maxWidth.clamp(320.0, 720.0).toDouble()
              : 560.0),
      wrapInShell: true,
      shellColor: (backgroundColor == null ||
              backgroundColor == Colors.transparent ||
              backgroundColor.a == 0)
          ? null
          : backgroundColor,
      settings: routeSettings,
    ),
  );
}

/// যে widget থেকে popover খোলা হলো তার পর্দায় অবস্থান।
/// null মানে — পর্দার মাঝে (aligned) বসাও।
Rect? _resolveAnchorRect(
  BuildContext context,
  NavigatorState navigator,
  PopoverAnchorMode mode,
) {
  if (mode == PopoverAnchorMode.aligned) return null;
  if (!context.mounted) return null;

  try {
    final RenderObject? ro = context.findRenderObject();
    final RenderObject? navRo = navigator.context.findRenderObject();
    if (ro is! RenderBox || navRo is! RenderBox) return null;
    if (!ro.attached || !ro.hasSize || !navRo.hasSize) return null;

    final Size size = ro.size;

    /// auto mode এ বড় widget (পুরো screen / table) থেকে খুললে anchor
    /// করার মানে হয় না — popover পর্দার কোণায় চলে যেত। তখন মাঝে বসাও
    if (mode == PopoverAnchorMode.auto &&
        (size.width > 640 || size.height > 140)) {
      return null;
    }

    final Offset topLeft = ro.localToGlobal(Offset.zero, ancestor: navRo);
    return topLeft & size;
  } catch (e) {
    debugPrint('Popover anchor resolve failed: $e');
    return null;
  }
}

// ============================================================
// ROUTE
// ============================================================

class AppPopoverRoute<T> extends PopupRoute<T> {
  AppPopoverRoute({
    required this.builder,
    required this.capturedThemes,
    required bool barrierDismissible,
    required Color barrierColor,
    required String barrierLabel,
    this.anchorRect,
    this.align = PopoverAlign.center,
    this.width,
    this.wrapInShell = false,
    this.shellColor,
    super.settings,
  })  : _barrierDismissible = barrierDismissible,
        _barrierColor = barrierColor,
        _barrierLabel = barrierLabel;

  final WidgetBuilder builder;
  final CapturedThemes capturedThemes;
  final Rect? anchorRect;
  final PopoverAlign align;
  final double? width;
  final bool wrapInShell;
  final Color? shellColor;

  final bool _barrierDismissible;
  final Color _barrierColor;
  final String _barrierLabel;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  String? get barrierLabel => _barrierLabel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 120);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return capturedThemes.wrap(
      _PopoverPositioner(
        anchorRect: anchorRect,
        align: align,
        width: width,
        child: Builder(
          builder: (ctx) {
            Widget content = builder(ctx);

            /// DraggableScrollableSheet নিজের উচ্চতা জানে না — parent
            /// থেকে bounded height চায়। bottom sheet এ সেটা পর্দা দিত,
            /// popover এ আমরা দিচ্ছি
            if (content is DraggableScrollableSheet) {
              final double h = MediaQuery.sizeOf(ctx).height * 0.78;
              content = SizedBox(height: h, child: content);
            }

            if (wrapInShell) {
              content = AppPopoverShell(
                backgroundColor: shellColor,
                child: content,
              );
            }

            /// যেসব builder সরাসরি Container / Column ফেরত দেয় তাদের
            /// TextField / InkWell এর জন্য Material ancestor লাগে
            return Material(
              type: MaterialType.transparency,
              child: content,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    /// app_popover.dart এর window এর মতোই — fade + 0.96 → 1.0 scale।
    /// এর বেশি scale দিলে "লাফিয়ে ওঠা" মনে হয়
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
        alignment:
            anchorRect != null ? Alignment.topCenter : Alignment.center,
        child: child,
      ),
    );
  }
}

// ============================================================
// POSITIONER — anchored / aligned placement + drag
// ============================================================

/// popover এর ভিতরের header / handle এই scope দিয়ে পুরো popover কে
/// টেনে সরাতে পারে
class PopoverDragScope extends InheritedWidget {
  const PopoverDragScope({
    super.key,
    required this.onDrag,
    required super.child,
  });

  final ValueChanged<Offset> onDrag;

  static PopoverDragScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PopoverDragScope>();

  @override
  bool updateShouldNotify(PopoverDragScope oldWidget) => false;
}

class _PopoverPositioner extends StatefulWidget {
  const _PopoverPositioner({
    required this.anchorRect,
    required this.align,
    required this.width,
    required this.child,
  });

  final Rect? anchorRect;
  final PopoverAlign align;
  final double? width;
  final Widget child;

  @override
  State<_PopoverPositioner> createState() => _PopoverPositionerState();
}

class _PopoverPositionerState extends State<_PopoverPositioner> {
  Offset _drag = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return PopoverDragScope(
      onDrag: (delta) => setState(() => _drag += delta),
      child: CustomSingleChildLayout(
        delegate: _PopoverLayoutDelegate(
          anchorRect: widget.anchorRect,
          align: widget.align,
          width: widget.width,
          drag: _drag,
        ),
        child: widget.child,
      ),
    );
  }
}

class _PopoverLayoutDelegate extends SingleChildLayoutDelegate {
  _PopoverLayoutDelegate({
    required this.anchorRect,
    required this.align,
    required this.width,
    required this.drag,
  });

  final Rect? anchorRect;
  final PopoverAlign align;
  final double? width;
  final Offset drag;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxW =
        math.max(0.0, constraints.maxWidth - _kPopoverEdge * 2);
    final double maxH =
        math.max(0.0, constraints.maxHeight - _kPopoverEdge * 2);

    if (width != null) {
      final double w = math.min(width!, maxW);
      return BoxConstraints(minWidth: w, maxWidth: w, maxHeight: maxH);
    }
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final PopoverPlacement placement = anchorRect != null
        ? resolvePopoverPlacement(
            anchorTopLeft: anchorRect!.topLeft,
            anchorSize: anchorRect!.size,
            desiredSize: childSize,
            overlaySize: size,
            edge: _kPopoverEdge,
            minHeight: 0,
          )
        : resolveAlignedPlacement(
            desiredSize: childSize,
            overlaySize: size,
            align: align,
            edge: _kPopoverEdge,
            minWidth: 0,
            minHeight: 0,
          );

    /// drag করা offset যোগ করে পর্দার ভিতরে আটকে রাখা — popover কখনো
    /// পর্দার বাইরে হারিয়ে যাবে না
    final double left = (placement.position.dx + drag.dx).clamp(
      0.0,
      math.max(0.0, size.width - childSize.width),
    );
    final double top = (placement.position.dy + drag.dy).clamp(
      0.0,
      math.max(0.0, size.height - childSize.height),
    );
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_PopoverLayoutDelegate old) =>
      old.anchorRect != anchorRect ||
      old.align != align ||
      old.width != width ||
      old.drag != drag;
}

// ============================================================
// SHARED DECORATION
// ============================================================

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _popoverBorder(BuildContext context) => _isDark(context)
    ? Colors.white.withValues(alpha: 0.10)
    : AppColors.borderLight;

BoxDecoration _popoverDecoration(BuildContext context, Color bg) =>
    BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(_kPopoverRadius),
      border: Border.all(color: _popoverBorder(context)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isDark(context) ? 0.45 : 0.16),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );

/// route এর barrierDismissible = false হলে (যেমন loader) X বাটন
/// দেখানো যাবে না — না হলে user loader বন্ধ করে দিলে পরে code এর
/// Navigator.pop() ভুল route pop করত
bool _routeAllowsClose(BuildContext context) {
  final route = ModalRoute.of(context);
  if (route is PopupRoute) return route.barrierDismissible;
  return true;
}

/// popover এর উপরের ধূসর handle — ধরে টেনে popover সরানো যায়
class PopoverDragHandle extends StatelessWidget {
  const PopoverDragHandle({super.key, this.height = 18});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scope = PopoverDragScope.maybeOf(context);
    return MouseRegion(
      cursor:
          scope != null ? SystemMouseCursors.move : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: scope == null ? null : (d) => scope.onDrag(d.delta),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyColor(context).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AppPopoverShell — Dialog এর drop-in বদল
// ------------------------------------------------------------
// Dialog এর সব parameter গ্রহণ করে (const সহ), তাই
// `Dialog(` → `AppPopoverShell(` করলেই চলে। ভিতরের child আগের মতোই
// নিজের মাপ ঠিক করে; shell শুধু card এর চেহারা আর drag handle দেয়।
// ============================================================

class AppPopoverShell extends StatelessWidget {
  const AppPopoverShell({
    super.key,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.constraints,
    this.showDragHandle = true,
    this.child,
  });

  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final EdgeInsetsGeometry? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final bool showDragHandle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color bg = (backgroundColor == null ||
            backgroundColor == Colors.transparent ||
            backgroundColor!.a == 0)
        ? AppColors.bottomNavBg(context)
        : backgroundColor!;

    Widget body = child ?? const SizedBox.shrink();

    if (showDragHandle) {
      /// Stack — handle টা child এর উপরে ভাসে, child এর মাপে হাত দেয় না
      body = Stack(
        children: [
          Padding(padding: const EdgeInsets.only(top: 14), child: body),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PopoverDragHandle(height: 16),
          ),
        ],
      );
    }

    Widget card = Container(
      decoration: _popoverDecoration(context, bg),
      clipBehavior: clipBehavior == Clip.none ? Clip.none : Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: body,
      ),
    );

    card = ConstrainedBox(
      constraints: constraints ?? const BoxConstraints(minWidth: 280),
      child: card,
    );

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: card,
    );
  }
}

// ============================================================
// AppPopoverCard — AlertDialog / CupertinoAlertDialog এর drop-in বদল
// ------------------------------------------------------------
// title / content / actions — তিন অংশ:
//   header  : title + X বাটন, পুরো header টেনে popover সরানো যায়
//   content : দরকার হলে নিজে scroll করে, তাই লম্বা form পর্দা ছাড়ায় না
//   actions : ডান দিকে সারিবদ্ধ, উপরে হালকা divider
// ============================================================

class AppPopoverCard extends StatelessWidget {
  const AppPopoverCard({
    super.key,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.contentPadding,
    this.contentTextStyle,
    this.actions,
    this.actionsPadding,
    this.actionsAlignment,
    this.actionsOverflowAlignment,
    this.actionsOverflowDirection,
    this.actionsOverflowButtonSpacing,
    this.buttonPadding,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.scrollable = false,
    this.constraints,
    // CupertinoAlertDialog এর parameter — compile এর জন্য রাখা
    this.scrollController,
    this.actionScrollController,
    this.insetAnimationDuration,
    this.insetAnimationCurve,
    // বাড়তি
    this.width,
    this.tone = PopoverTone.normal,
    this.showCloseButton = true,
  });

  final Widget? icon;
  final EdgeInsetsGeometry? iconPadding;
  final Color? iconColor;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? contentTextStyle;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment? actionsAlignment;
  final OverflowBarAlignment? actionsOverflowAlignment;
  final VerticalDirection? actionsOverflowDirection;
  final double? actionsOverflowButtonSpacing;
  final EdgeInsetsGeometry? buttonPadding;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final String? semanticLabel;
  final EdgeInsetsGeometry? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final bool scrollable;
  final BoxConstraints? constraints;
  final ScrollController? scrollController;
  final ScrollController? actionScrollController;
  final Duration? insetAnimationDuration;
  final Curve? insetAnimationCurve;

  /// নির্দিষ্ট প্রস্থ (null = content অনুযায়ী, 320–560 এর মধ্যে)
  final double? width;
  final PopoverTone tone;
  final bool showCloseButton;

  Color _toneColor(BuildContext context) => switch (tone) {
        PopoverTone.danger => AppColors.danger,
        PopoverTone.warning => AppColors.warning,
        PopoverTone.success => AppColors.success,
        PopoverTone.normal => AppColors.primaryColor(context),
      };

  @override
  Widget build(BuildContext context) {
    final Color bg = (backgroundColor == null ||
            backgroundColor == Colors.transparent ||
            backgroundColor!.a == 0)
        ? AppColors.bottomNavBg(context)
        : backgroundColor!;
    final Color textColor = AppColors.text(context);
    final bool canClose = showCloseButton && _routeAllowsClose(context);
    final List<Widget> acts = actions ?? const <Widget>[];

    final children = <Widget>[];

    // ---------------- header ----------------
    if (title != null || icon != null) {
      final dragScope = PopoverDragScope.maybeOf(context);
      children.add(
        MouseRegion(
          cursor: dragScope != null
              ? SystemMouseCursors.move
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate:
                dragScope == null ? null : (d) => dragScope.onDrag(d.delta),
            child: Padding(
              padding: titlePadding ??
                  EdgeInsets.fromLTRB(20, 14, canClose ? 8 : 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    IconTheme.merge(
                      data: IconThemeData(
                        color: iconColor ?? _toneColor(context),
                        size: 20,
                      ),
                      child: icon!,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: DefaultTextStyle(
                      style: titleTextStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.3,
                          ),
                      child: title ?? const SizedBox.shrink(),
                    ),
                  ),
                  if (canClose)
                    IconButton(
                      tooltip: 'Close (Esc)',
                      visualDensity: VisualDensity.compact,
                      splashRadius: 18,
                      icon: Icon(Icons.close_rounded,
                          size: 20, color: AppColors.greyColor(context)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      children.add(Divider(height: 1, color: _popoverBorder(context)));
    } else {
      children.add(const PopoverDragHandle());
    }

    // ---------------- content ----------------
    if (content != null) {
      children.add(
        Flexible(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: contentPadding ??
                EdgeInsets.fromLTRB(20, title != null ? 16 : 4, 20, 16),
            child: DefaultTextStyle(
              style: contentTextStyle ??
                  TextStyle(fontSize: 14, color: textColor, height: 1.45),
              child: content!,
            ),
          ),
        ),
      );
    }

    // ---------------- actions ----------------
    if (acts.isNotEmpty) {
      children.add(Divider(height: 1, color: _popoverBorder(context)));
      children.add(
        Padding(
          padding:
              actionsPadding ?? const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: OverflowBar(
            alignment: actionsAlignment ?? MainAxisAlignment.end,
            spacing: 8,
            overflowSpacing: actionsOverflowButtonSpacing ?? 8,
            overflowAlignment:
                actionsOverflowAlignment ?? OverflowBarAlignment.end,
            overflowDirection:
                actionsOverflowDirection ?? VerticalDirection.down,
            children: acts,
          ),
        ),
      );
    }

    /// IntrinsicWidth — AlertDialog যেভাবে content এর মাপে চওড়া হয়,
    /// ঠিক সেভাবেই। ফলে আগে যে content AlertDialog এ ঠিক ছিল, এখানেও
    /// একই মাপে থাকবে
    Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    column = width != null
        ? SizedBox(width: width, child: column)
        : IntrinsicWidth(child: column);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: constraints ??
            BoxConstraints(minWidth: 320, maxWidth: width ?? 560),
        child: Container(
          decoration: _popoverDecoration(context, bg),
          clipBehavior: Clip.antiAlias,
          child: Material(color: Colors.transparent, child: column),
        ),
      ),
    );
  }
}

// ============================================================
// POPOVER BUTTONS — সব popover এ একই রকম বাটন
// ============================================================

class PopoverButton extends StatelessWidget {
  const PopoverButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.tone = PopoverTone.normal,
    this.icon,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final PopoverTone tone;
  final IconData? icon;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (tone) {
      PopoverTone.danger => AppColors.danger,
      PopoverTone.warning => AppColors.warning,
      PopoverTone.success => AppColors.success,
      PopoverTone.normal => AppColors.primaryColor(context),
    };

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );
    const padding = EdgeInsets.symmetric(horizontal: 18, vertical: 12);
    final text = Text(label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));

    if (primary) {
      final style = FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.onColor(color),
        shape: shape,
        padding: padding,
        minimumSize: const Size(96, 40),
      );
      if (icon != null) {
        return FilledButton.icon(
          autofocus: autofocus,
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: text,
          style: style,
        );
      }
      return FilledButton(
        autofocus: autofocus,
        onPressed: onPressed,
        style: style,
        child: text,
      );
    }

    return OutlinedButton(
      autofocus: autofocus,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text(context),
        side: BorderSide(color: _popoverBorder(context)),
        shape: shape,
        padding: padding,
        minimumSize: const Size(88, 40),
      ),
      child: text,
    );
  }
}

// ============================================================
// showConfirmPopover — Delete / Yes-No এর জন্য
// ------------------------------------------------------------
// true = নিশ্চিত, false = বাতিল / বাইরে ক্লিক / Esc।
// Enter চাপলে নিশ্চিত হয় (confirm বাটনে autofocus)।
// ============================================================

Future<bool> showConfirmPopover(
  BuildContext context, {
  String title = 'Are you sure?',
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  PopoverTone tone = PopoverTone.normal,
  IconData? icon,
  PopoverAnchorMode mode = PopoverAnchorMode.auto,
}) async {
  final result = await showAppPopover<bool>(
    context: context,
    mode: mode,
    builder: (ctx) => AppPopoverCard(
      width: 400,
      tone: tone,
      icon: Icon(icon ??
          switch (tone) {
            PopoverTone.danger => Icons.delete_outline_rounded,
            PopoverTone.warning => Icons.warning_amber_rounded,
            PopoverTone.success => Icons.check_circle_outline_rounded,
            PopoverTone.normal => Icons.help_outline_rounded,
          }),
      title: Text(title),
      content: Text(message),
      actions: [
        PopoverButton(
          label: cancelText,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        PopoverButton(
          label: confirmText,
          primary: true,
          tone: tone,
          autofocus: true,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}
