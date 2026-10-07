

import 'dart:async';
import 'dart:math' as math;

import '../configs/configs.dart';

// ============================================================
// GROUP IDs
// ------------------------------------------------------------
// দুইটা আলাদা group, কারণ দুইটা আলাদা চাহিদা:
//
// kPopoverGroupId — Rx window এর group। keypad গুলোও এই group এর
//   ভিতরে থাকে, তাই keypad এ ক্লিক করলে window বন্ধ হয় না।
//
// kKeypadGroupId — শুধু keypad / picker দের group। Rx screen এর
//   সাধারণ অংশ এতে নেই, তাই screen এর খালি জায়গায় ক্লিক করলে
//   keypad গুলো বন্ধ হয়ে যায় — কিন্তু window টিকে থাকে।
// ============================================================

const Object kPopoverGroupId = 'app_popover_group';
const Object kKeypadGroupId = 'app_keypad_group';

// ============================================================
// OUTSIDE-TAP GUARD — dialog খোলা থাকলে window বন্ধ না হওয়া
// ------------------------------------------------------------
// সমস্যা: Rx window খোলা রেখে "নতুন ওষুধ Create" dialog খুললে,
// dialog এ (বা তার Generic / Description suggestion এ) যেকোনো ক্লিক
// Rx window এর কাছে "বাইরে ক্লিক" — তাই window চুপচাপ বন্ধ হয়ে যেত,
// RxScreen dispose হতো। Save চাপার পর নতুন ওষুধ যোগ করার জায়গাই
// থাকত না → "TextEditingController was used after being disposed"।
//
// সমাধান: dialog চলাকালীন guard ধরে রাখা। guard ধরা থাকলে কোনো
// popover window "বাইরে ক্লিক" এ বন্ধ হবে না। dialog বন্ধ হলেই
// guard ছেড়ে দেওয়া হয় (finally — error হলেও)।
//
// ব্যবহার:
//   final result = await PopoverOutsideTapGuard.run(
//     () => showDialog(...),
//   );
// ============================================================

class PopoverOutsideTapGuard {
  PopoverOutsideTapGuard._();

  static int _holds = 0;

  static bool get isHeld => _holds > 0;

  static Future<T> run<T>(Future<T> Function() action) async {
    _holds++;
    try {
      return await action();
    } finally {
      _holds--;
    }
  }
}

// ============================================================
// SAFE REMOVE — সব manager এর একটাই বন্ধ করার পথ
// ------------------------------------------------------------
// ১. `entry.mounted` দেখে remove করা যাবে না — insert() এর পর পরের
//    frame build না হওয়া পর্যন্ত mounted == false থাকে। ওই ফাঁকে
//    বন্ধ করলে entry পর্দায় "অনাথ" হয়ে থেকে যেত (duplicate popup,
//    বা বন্ধ না হওয়া window)। remove() mounted না হলেও কাজ করে।
// ২. remove এর পর dispose() — না হলে প্রতিবার popup খোলা-বন্ধে
//    একটু করে memory জমতো (OverlayEntry একটা ChangeNotifier)।
//    Flutter নিজেই অপেক্ষা করে, entry পুরো unmount হওয়ার পর dispose।
// ৩. সব try/catch এ — overlay ইতিমধ্যে চলে গেলে (screen বদল, app
//    বন্ধ) crash নয়, শুধু debug log।
// ============================================================

void _safeRemoveEntry(OverlayEntry entry, String debugName) {
  try {
    entry.remove();
  } catch (e) {
    debugPrint('Popover "$debugName" remove failed: $e');
  }
  try {
    entry.dispose();
  } catch (e) {
    debugPrint('Popover "$debugName" dispose failed: $e');
  }
}

// ============================================================
// PLACEMENT — দুই রকম
// ------------------------------------------------------------
//   ১. ANCHORED (resolvePopoverPlacement)
//      ছোট edit popover এর জন্য — যে pencil icon এ ক্লিক হয়েছে
//      ঠিক তার পাশে খোলে, তাই ডাক্তার বোঝেন কোন row edit হচ্ছে।
//
//   ২. ALIGNED (resolveAlignedPlacement)
//      বড় section window এর জন্য — anchor উপেক্ষা করে পর্দার
//      বাঁ / মাঝ / ডান পাশে বসে।
// ============================================================

class PopoverPlacement {
  final Offset position;
  final Size size;

  const PopoverPlacement(this.position, this.size);
}

// ------------------------------------------------------------
// ALIGNMENT
// ------------------------------------------------------------
// start — বাঁ কলামের section (Chief Complaints, History,
//   Examination, Diagnosis, Procedure, Investigation)
// end   — ডান কলামের section (Rx, Advice, Follow Up)
// center — যেগুলো কোনো কলামের নয় (Allergy/Drug Reaction ইত্যাদি)
//
// window যে panel এর, সেই পাশেই খুললে ডাক্তারের চোখকে পর্দার এক
// প্রান্ত থেকে অন্য প্রান্তে যেতে হয় না
// ------------------------------------------------------------

enum PopoverAlign { start, center, end }

// ------------------------------------------------------------
// ANCHORED PLACEMENT
// ------------------------------------------------------------
// নিয়ম তিন ধাপে:
//   ১. নিচে ধরলে নিচে
//   ২. না ধরলে উপরে ধরে কিনা দেখো
//   ৩. কোনোটাতেই না ধরলে যেদিকে বেশি জায়গা সেদিকে খোলো এবং
//      উচ্চতা কমিয়ে ওই জায়গার ভিতরে এনে ফেলো
// ------------------------------------------------------------

PopoverPlacement resolvePopoverPlacement({
  required Offset anchorTopLeft,
  required Size anchorSize,
  required Size desiredSize,
  required Size overlaySize,
  double gap = 6,
  double edge = 8,
  double minHeight = 150,
}) {
  final double spaceBelow =
      overlaySize.height - (anchorTopLeft.dy + anchorSize.height + gap) - edge;

  final double spaceAbove = anchorTopLeft.dy - gap - edge;

  final bool fitsBelow = spaceBelow >= desiredSize.height;
  final bool fitsAbove = spaceAbove >= desiredSize.height;

  final bool openUpward =
  fitsBelow ? false : (fitsAbove ? true : spaceAbove > spaceBelow);

  final double available = openUpward ? spaceAbove : spaceBelow;

  /// যেদিকে খুলছে সেই জায়গার ভিতরে আটানো — তবে minHeight এর
  /// নিচে নামানো হয় না, না হলে ভিতরের content ব্যবহারের অযোগ্য
  final double height = math.min(
    desiredSize.height,
    math.max(minHeight, available),
  );

  double top = openUpward
      ? anchorTopLeft.dy - height - gap
      : anchorTopLeft.dy + anchorSize.height + gap;

  top = top.clamp(edge, math.max(edge, overlaySize.height - height - edge));

  double left = anchorTopLeft.dx;

  left = left.clamp(
    edge,
    math.max(edge, overlaySize.width - desiredSize.width - edge),
  );

  return PopoverPlacement(
    Offset(left, top),
    Size(desiredSize.width, height),
  );
}

// ------------------------------------------------------------
// ALIGNED PLACEMENT
// ------------------------------------------------------------
// anchor এর position এখানে লাগে না — শুধু overlay এর মাপ আর
// কোন পাশে বসাতে হবে সেটাই যথেষ্ট।
//
// edge — চারপাশে ন্যূনতম ফাঁক। না রাখলে ছোট screen এ window
// পর্দার কিনারা ছুঁয়ে ফেলে, তখন shadow টাও দেখা যায় না।
// ------------------------------------------------------------

PopoverPlacement resolveAlignedPlacement({
  required Size desiredSize,
  required Size overlaySize,
  required PopoverAlign align,
  double edge = 24,
  double minWidth = 320,
  double minHeight = 240,

  /// উল্লম্ব অবস্থান। 0.5 = একদম মাঝে, 0.45 = সামান্য উপরে —
  /// নিচের Save / Save & Print / End Visit bar এর কারণে ঠিক মাঝে
  /// বসালে window ওই bar এর গায়ে লেপ্টে আছে বলে মনে হয়
  double verticalBias = 0.45,
}) {
  final double maxW = math.max(0.0, overlaySize.width - edge * 2);
  final double maxH = math.max(0.0, overlaySize.height - edge * 2);

  /// চাওয়া মাপ বড় হলে available জায়গায় নামিয়ে আনা, আবার খুব ছোট
  /// screen এ minWidth / minHeight এর নিচে নামতে না দেওয়া — তবে
  /// available এর বেশিও নয়, তাই দুই দিকেই min() দিয়ে সামলানো
  final double width = math
      .min(desiredSize.width, maxW)
      .clamp(math.min(minWidth, maxW), maxW)
      .toDouble();

  final double height = math
      .min(desiredSize.height, maxH)
      .clamp(math.min(minHeight, maxH), maxH)
      .toDouble();

  /// বাঁ দিকের সর্বনিম্ন আর সর্বোচ্চ সম্ভাব্য অবস্থান। এই দুইয়ের
  /// মাঝে lerp করা হয় বলে window কখনোই পর্দার বাইরে যেতে পারে না —
  /// আগে Follow Up window যেভাবে ডান কিনারা ছাড়িয়ে যেত
  final double minLeft = edge;
  final double maxLeft = math.max(edge, overlaySize.width - width - edge);

  final double t = switch (align) {
    PopoverAlign.start => 0.0,
    PopoverAlign.center => 0.5,
    PopoverAlign.end => 1.0,
  };

  final double left = minLeft + (maxLeft - minLeft) * t;

  final double top = ((overlaySize.height - height) * verticalBias)
      .clamp(edge, math.max(edge, overlaySize.height - height - edge))
      .toDouble();

  return PopoverPlacement(Offset(left, top), Size(width, height));
}

// ============================================================
// POPOVER MANAGER — একবারে একটাই window
// ============================================================

class PopoverManager {
  OverlayEntry? _entry;
  String? _activeTitle;
  VoidCallback? _onClosed;

  /// প্রতিবার open() এ বাড়ে। একই title দ্বিতীয়বার খুললেও যেন নতুন
  /// Key পায় — না হলে Flutter পুরনো element পুনর্ব্যবহার করে,
  /// আর dispose হয়ে যাওয়া controller ধরে রেখে crash করে
  int _openCounter = 0;

  /// resize() এর জন্য — বর্তমান popover এর layout ইনপুট মনে রাখা
  /// হয়, যাতে নতুন size দিয়ে আবার placement বার করা যায় এবং শুধু
  /// markNeedsBuild() করলেই চলে — পুরো entry নতুন করে বানাতে হয় না।
  /// entry রিপ্লেস করলে ভিতরের widget (আর তার state, যেমন form এর
  /// টাইপ করা মান) হারিয়ে যেত।
  Offset? _liveAnchorTopLeft;
  Size? _liveAnchorSize;
  Size? _liveOverlaySize;
  PopoverAlign? _liveAlign;
  Offset _livePosition = Offset.zero;
  Size _liveBoxSize = Size.zero;

  bool get isOpen => _entry != null;
  String? get activeTitle => _activeTitle;

  /// notify = false দিলে onClosed callback চালানো হবে না।
  /// State.dispose() থেকে বন্ধ করার সময় এটাই দরকার — ওই
  /// callback গুলোতে setState থাকে, State তখন defunct
  void close({bool notify = true}) {
    final OverlayEntry? entry = _entry;
    final VoidCallback? cb = _onClosed;

    _entry = null;
    _activeTitle = null;
    _onClosed = null;
    _liveAnchorTopLeft = null;
    _liveAnchorSize = null;
    _liveOverlaySize = null;
    _liveAlign = null;

    if (entry == null) return;

    /// ✅ FIX: আগে `if (entry.mounted) entry.remove()` ছিল — window খোলার
    /// সাথে সাথেই (একই frame এ) বন্ধ হলে, যেমন section button এ দ্রুত
    /// দুইবার ক্লিক, window পর্দায় আটকে থেকে যেত আর কোনোভাবেই বন্ধ
    /// হতো না। এখন সবসময় নিরাপদে সরানো হয়।
    _safeRemoveEntry(entry, 'window');

    if (notify) {
      cb?.call();
    }
  }

  void dispose() {
    close(notify: false);
  }

  /// চালু থাকা popover কে নতুন size এ animate করে — বন্ধ/খোলা করে
  /// না, তাই ভিতরের widget এর state (form এর টাইপ করা মান ইত্যাদি)
  /// অক্ষত থাকে। title না মিললে বা কিছু খোলা না থাকলে চুপচাপ ফিরে যায়
  void resize({required String title, required Size size}) {
    if (_entry == null || _activeTitle != title) return;
    if (_liveOverlaySize == null) return;

    final placement = _liveAlign == null
        ? resolvePopoverPlacement(
      anchorTopLeft: _liveAnchorTopLeft!,
      anchorSize: _liveAnchorSize!,
      desiredSize: size,
      overlaySize: _liveOverlaySize!,
    )
        : resolveAlignedPlacement(
      desiredSize: size,
      overlaySize: _liveOverlaySize!,
      align: _liveAlign!,
    );

    _livePosition = placement.position;
    _liveBoxSize = placement.size;

    /// mounted না হলে দরকার নেই — প্রথম build এ নতুন মাপ এমনিতেই পাবে
    if (_entry!.mounted) _entry!.markNeedsBuild();
  }

  void open({
    required BuildContext context,
    required String title,
    required Size size,
    required WidgetBuilder bodyBuilder,
    VoidCallback? onClosed,

    /// null দিলে anchor ধরে খোলে — edit popover এর জন্য এটাই দরকার।
    /// মান দিলে anchor উপেক্ষা করে ওই পাশে বসে।
    ///
    /// default null রাখা হয়েছে ইচ্ছে করেই — যেসব call site এ হাত
    /// দেওয়া হবে না, সেগুলো হুবহু আগের মতোই চলবে
    PopoverAlign? align,

    /// পেছনের backdrop কতটা গাঢ় হবে। aligned window এ একটু বেশি
    /// (0.18) দিলে চোখ আপনা থেকেই window তে যায়
    double barrierOpacity = 0.06,
  }) {
    final wasOpenSameTitle = _activeTitle == title;
    close();

    if (wasOpenSameTitle) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final RenderBox? buttonBox = context.findRenderObject() as RenderBox?;
    final RenderBox overlayBox =
    overlay.context.findRenderObject() as RenderBox;

    final Offset buttonTopLeft = buttonBox != null
        ? buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox)
        : Offset.zero;
    final Size buttonSize = buttonBox?.size ?? Size.zero;
    final Size overlaySize = overlayBox.size;

    /// একই open() দুই mode ই সামলায় — caller শুধু align দেয়,
    /// কোন ফাংশন ডাকতে হবে সেটা এখানেই ঠিক হয়
    final placement = align == null
        ? resolvePopoverPlacement(
      anchorTopLeft: buttonTopLeft,
      anchorSize: buttonSize,
      desiredSize: size,
      overlaySize: overlaySize,
    )
        : resolveAlignedPlacement(
      desiredSize: size,
      overlaySize: overlaySize,
      align: align,
    );

    /// resize() পরে এই ইনপুটগুলোই আবার ব্যবহার করবে
    _liveAnchorTopLeft = buttonTopLeft;
    _liveAnchorSize = buttonSize;
    _liveOverlaySize = overlaySize;
    _liveAlign = align;
    _livePosition = placement.position;
    _liveBoxSize = placement.size;

    _onClosed = onClosed;

    final String instanceKey = '${title}_${_openCounter++}';

    _entry = OverlayEntry(
      builder: (ctx) {
        return KeyedSubtree(
          key: ValueKey(instanceKey),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: barrierOpacity),
                  ),
                ),
              ),
              StatefulBuilder(
                builder: (ctx2, setLocalState) {
                  return Positioned(
                    left: _livePosition.dx,
                    top: _livePosition.dy,
                    child: TapRegion(
                      groupId: kPopoverGroupId,
                      onTapOutside: (_) {
                        /// dialog খোলা থাকলে window বন্ধ নয়
                        if (PopoverOutsideTapGuard.isHeld) return;
                        close();
                      },

                      /// window হঠাৎ ফুটে উঠলে ঝাঁকুনির মতো লাগে —
                      /// scale + fade এ মসৃণ ভাবে আসে। 0.96 → 1.0,
                      /// এর বেশি পার্থক্য দিলে "লাফিয়ে ওঠা" মনে হয়
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        builder: (_, t, child) => Opacity(
                          opacity: t,
                          child: Transform.scale(
                            scale: 0.96 + (0.04 * t),
                            child: child,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,

                          /// AnimatedContainer — resize() এর নতুন
                          /// width/height এ মসৃণ ভাবে বড়/ছোট হয়,
                          /// আগে এটা plain Container ছিল বলে size
                          /// বদলানোর কোনো উপায়ই ছিল না
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            width: _liveBoxSize.width,
                            height: _liveBoxSize.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanUpdate: (d) {
                                    setLocalState(() {
                                      double newLeft =
                                          _livePosition.dx + d.delta.dx;
                                      double newTop =
                                          _livePosition.dy + d.delta.dy;
                                      newLeft = newLeft.clamp(
                                        0.0,
                                        math.max(
                                          0.0,
                                          overlaySize.width -
                                              _liveBoxSize.width,
                                        ),
                                      );
                                      newTop = newTop.clamp(
                                        0.0,
                                        math.max(
                                          0.0,
                                          overlaySize.height -
                                              _liveBoxSize.height,
                                        ),
                                      );
                                      _livePosition =
                                          Offset(newLeft, newTop);
                                    });
                                  },
                                  child: Container(
                                    height: 24,
                                    width: double.infinity,
                                    color: const Color(0xFFF3F4F6),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.drag_indicator,
                                      size: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                Expanded(child: bodyBuilder(ctx2)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_entry!);
    _activeTitle = title;
  }
}

// ============================================================
// MULTI POPOVER MANAGER — keypad / picker
// ------------------------------------------------------------
// এখানে align option ইচ্ছে করেই যোগ করা হয়নি — keypad আর picker
// সবসময় যে field এ কাজ চলছে তার পাশেই থাকা দরকার
//
// ✅ একসাথে একটাই সাব-popover খোলা থাকে। Rx window নিজে
// PopoverManager এ আছে, তাই সাব-popover বদলালে window ছোঁয়া হয় না
// ============================================================

class MultiPopoverManager {
  final Map<String, OverlayEntry> _entries = {};
  final Map<String, VoidCallback?> _onClosedCallbacks = {};

  /// PopoverManager এর মতোই — element পুনর্ব্যবহার ঠেকাতে
  int _openCounter = 0;

  bool isOpen(String title) => _entries.containsKey(title);
  List<String> get openTitles => _entries.keys.toList();

  void close(String title, {bool notify = true}) {
    final entry = _entries.remove(title);
    final cb = _onClosedCallbacks.remove(title);

    if (entry == null) return;

    /// ✅ FIX (duplicate popup): আগে `if (entry.mounted)` ছিল।
    /// কিন্তু insert() এর পর পরের frame build না হওয়া পর্যন্ত
    /// mounted == false থাকে। ওই ফাঁকে close() হলে entry map থেকে
    /// মুছে যেত কিন্তু পর্দা থেকে সরতো না — "অনাথ" popup হয়ে চিরকাল
    /// থেকে যেত, আর পরের popup তার উপর খুলতো। remove() mounted না
    /// হলেও কাজ করে, তাই সবসময় remove করা হচ্ছে।
    _safeRemoveEntry(entry, title);

    if (notify) {
      cb?.call();
    }
  }

  void closeAll({bool notify = true}) {
    for (final title in _entries.keys.toList()) {
      close(title, notify: notify);
    }
  }

  /// model বদলালে খোলা popover কে আবার build করাতে হয় —
  /// না হলে ভিতরের checkbox / chip highlight পুরনো থেকে যায়
  void refresh(String title) {
    final entry = _entries[title];
    if (entry != null && entry.mounted) {
      entry.markNeedsBuild();
    }
  }

  void refreshAll() {
    for (final entry in _entries.values) {
      if (entry.mounted) entry.markNeedsBuild();
    }
  }

  void dispose() {
    closeAll(notify: false);
  }

  void open({
    required BuildContext context,
    required String title,
    required Size size,
    required WidgetBuilder bodyBuilder,
    VoidCallback? onClosed,
  }) {
    /// ✅ FIX: অন্য title এর কোনো সাব-popover খোলা থাকলে আগে সেগুলো
    /// বন্ধ। বাটনগুলো kKeypadGroupId এর ভিতরে থাকে বলে বাটনে ক্লিক
    /// "outside tap" ধরা হয় না — তাই onTapOutside এ এগুলো বন্ধ হত না
    /// এবং frequency + duration একসাথে খোলা থাকত
    for (final other in _entries.keys.where((t) => t != title).toList()) {
      close(other);
    }

    /// একই বাটনে দ্বিতীয়বার ক্লিক = বন্ধ
    final wasOpenSameTitle = _entries.containsKey(title);
    close(title);
    if (wasOpenSameTitle) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final RenderBox? buttonBox = context.findRenderObject() as RenderBox?;
    final RenderBox overlayBox =
    overlay.context.findRenderObject() as RenderBox;

    final Offset buttonTopLeft = buttonBox != null
        ? buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox)
        : Offset.zero;
    final Size buttonSize = buttonBox?.size ?? Size.zero;
    final Size overlaySize = overlayBox.size;

    final placement = resolvePopoverPlacement(
      anchorTopLeft: buttonTopLeft,
      anchorSize: buttonSize,
      desiredSize: size,
      overlaySize: overlaySize,
    );

    Offset position = placement.position;
    final Size boxSize = placement.size;

    _onClosedCallbacks[title] = onClosed;

    final String instanceKey = '${title}_${_openCounter++}';

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) {
        return KeyedSubtree(
          key: ValueKey(instanceKey),
          child: StatefulBuilder(
            builder: (ctx2, setLocalState) {
              return Positioned(
                left: position.dx,
                top: position.dy,

                /// বাইরের layer — keypad কে Rx window এর group এ
                /// ঢোকায়, তাই keypad এ ক্লিক করলে window বন্ধ হয় না।
                /// onTapOutside নেই — window বন্ধ করা PopoverManager
                /// এর নিজের দায়িত্ব
                child: TapRegion(
                  groupId: kPopoverGroupId,

                  /// ভিতরের layer — keypad দের নিজেদের group
                  child: TapRegion(
                    groupId: kKeypadGroupId,
                    onTapOutside: (_) {
                      if (PopoverOutsideTapGuard.isHeld) return;
                      closeAll();
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: boxSize.width,
                        height: boxSize.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (d) {
                                setLocalState(() {
                                  double newLeft = position.dx + d.delta.dx;
                                  double newTop = position.dy + d.delta.dy;
                                  newLeft = newLeft.clamp(
                                    0.0,
                                    math.max(
                                      0.0,
                                      overlaySize.width - boxSize.width,
                                    ),
                                  );
                                  newTop = newTop.clamp(
                                    0.0,
                                    math.max(
                                      0.0,
                                      overlaySize.height - boxSize.height,
                                    ),
                                  );
                                  position = Offset(newLeft, newTop);
                                });
                              },
                              child: Container(
                                height: 24,
                                width: double.infinity,
                                color: const Color(0xFFF3F4F6),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            Expanded(child: bodyBuilder(ctx2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    overlay.insert(entry);
    _entries[title] = entry;
  }
}

// ============================================================
// SCOPED TAP REGION — popover এর ভিতরের search dropdown এর জন্য
// ------------------------------------------------------------
// সমস্যা: search field আর তার suggestion list দুটোই kPopoverGroupId
// group এ ছিল। পুরো window ও ওই একই group এ। তাই window এর ভিতরে
// যেকোনো জায়গায় ক্লিক = "group এর ভিতরে" → onTapOutside কখনো চলত না,
// suggestion list খোলাই থেকে যেত। শুধু window এর বাইরে ক্লিক করলে
// বন্ধ হতো।
//
// সমাধান: দুই স্তর —
//   বাইরের স্তর kPopoverGroupId → suggestion এ ক্লিক করলে window
//     বন্ধ হয় না (আগের মতো)
//   ভিতরের স্তর নিজস্ব groupId → field আর তার list এর বাইরে (window
//     এর ভিতরে হলেও) ক্লিক করলে onTapOutside চলে, list বন্ধ হয়
// ============================================================

class ScopedTapRegion extends StatelessWidget {
  const ScopedTapRegion({
    super.key,
    required this.groupId,
    required this.child,
    this.onTapOutside,
  });

  /// প্রতিটা dropdown এর নিজস্ব — field আর তার overlay এ একই object
  final Object groupId;
  final TapRegionCallback? onTapOutside;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: kPopoverGroupId,
      child: TapRegion(
        groupId: groupId,
        onTapOutside: onTapOutside,
        child: child,
      ),
    );
  }
}

// ============================================================
// OVERLAY DIALOG — popover window এর উপরে dialog
// ------------------------------------------------------------
// কেন showDialog() নয়:
//   Rx / Follow Up ইত্যাদি window গুলো root overlay এ সরাসরি বসানো
//   OverlayEntry। showDialog() একটা route push করে, আর Navigator নতুন
//   route কে আগের route এর ঠিক উপরে বসায় — সরাসরি বসানো entry গুলোর
//   নিচে। তাই dialog window এর পেছনে চাপা পড়ে যেত (Add Rx dialog
//   Rx window এর নিচে দেখা যেত)।
//
//   এই helper dialog কেও root overlay এর একদম উপরে একটা entry হিসেবে
//   বসায় — তাই সবসময় window এর উপরে থাকে। ভিতরের dropdown গুলোর
//   suggestion (পরে insert হয়) এর উপরেও আসে।
//
// ব্যবহার — Navigator.pop(ctx, x) এর বদলে close(x):
//   final r = await showOverlayDialog<DrugModel>(
//     context: context,
//     builder: (ctx, close) => ... close(result) ...,
//   );
// ============================================================

typedef OverlayDialogClose<T> = void Function([T? result]);

Future<T?> showOverlayDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext ctx, OverlayDialogClose<T> close)
  builder,
  double barrierOpacity = 0.35,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final completer = Completer<T?>();
  late final OverlayEntry entry;

  void close([T? result]) {
    if (completer.isCompleted) return;
    _safeRemoveEntry(entry, 'overlay_dialog');
    completer.complete(result);
  }

  entry = OverlayEntry(
    builder: (ctx) {
      /// window এর group এ — dialog এ ক্লিক কোনো window বন্ধ করে না
      return TapRegion(
        groupId: kPopoverGroupId,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              /// পেছনের ধূসর পর্দা — নিচের কিছুতে ক্লিক পৌঁছায় না
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: barrierOpacity),
                  ),
                ),
              ),

              /// Esc চাপলে বন্ধ — showDialog এর মতো
              Positioned.fill(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape): close,
                  },
                  child: FocusScope(
                    autofocus: true,
                    child: builder(ctx, close),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  /// dialog চলাকালীন নিচের window "বাইরে ক্লিক" এ বন্ধ হবে না
  return PopoverOutsideTapGuard.run(() => completer.future);
}

