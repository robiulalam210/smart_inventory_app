import 'package:flutter/material.dart';

import 'page_guides.dart';
import 'web_ui.dart';

/// "**গাঢ়**" চিহ্ন দেওয়া লেখাকে RichText এর span এ ভাঙা
List<InlineSpan> _bold(String text, TextStyle base) {
  final spans = <InlineSpan>[];
  final parts = text.split('**');
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    spans.add(TextSpan(
      text: parts[i],
      style: i.isOdd ? base.copyWith(fontWeight: FontWeight.w700) : base,
    ));
  }
  return spans;
}

/// গাইডের ভেতরের লেখা — ধাপ, পরামর্শ (desktop কার্ড ও mobile sheet দুটোতেই)
class PageGuideBody extends StatelessWidget {
  final PageGuideData guide;
  const PageGuideBody({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: 13.5, height: 1.45, color: W.ink2(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(guide.lead, style: base.copyWith(fontWeight: FontWeight.w600, color: W.ink(context))),
        const SizedBox(height: 8),
        for (var i = 0; i < guide.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8, top: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: W.blueWash(context), shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: W.blueInk(context))),
                ),
                Expanded(child: Text.rich(TextSpan(children: _bold(guide.steps[i], base)))),
              ],
            ),
          ),
        if (guide.tip.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: W.blueWash(context),
              borderRadius: BorderRadius.circular(W.rSm),
              border: Border.all(color: W.blueLine(context)),
            ),
            child: Text.rich(TextSpan(children: _bold('💡 ${guide.tip}', base))),
          ),
      ],
    );
  }
}

/// Desktop: পেজের মাথায় ভাঁজ করা যায় এমন গাইড-কার্ড (ওয়েবের "কীভাবে কাজ করবেন" এর মতো)
class PageGuideCard extends StatefulWidget {
  final String guideKey;
  const PageGuideCard({super.key, required this.guideKey});

  /// একবার বন্ধ করলে সেশনে আর খোলে না
  static final Set<String> _closed = <String>{};

  @override
  State<PageGuideCard> createState() => _PageGuideCardState();
}

class _PageGuideCardState extends State<PageGuideCard> {
  @override
  Widget build(BuildContext context) {
    final guide = kPageGuides[widget.guideKey];
    if (guide == null) return const SizedBox.shrink();
    final open = !PageGuideCard._closed.contains(widget.guideKey);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: W.surface(context),
        borderRadius: BorderRadius.circular(W.rMd),
        border: Border.all(color: W.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(W.rMd),
            onTap: () => setState(() {
              open ? PageGuideCard._closed.add(widget.guideKey) : PageGuideCard._closed.remove(widget.guideKey);
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 18, color: W.blueInk(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('কীভাবে কাজ করবেন',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: W.ink(context))),
                  ),
                  Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: W.muted(context)),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: PageGuideBody(guide: guide),
            ),
        ],
      ),
    );
  }
}

/// Mobile: পেজের উপর ছোট "?" বোতাম — চাপলে নিচ থেকে গাইড উঠে আসে
class GuideHost extends StatelessWidget {
  final String guideKey;
  final Widget child;
  const GuideHost({super.key, required this.guideKey, required this.child});

  /// mobile menu index থেকে
  factory GuideHost.mobile({Key? key, required int index, required Widget child}) => GuideHost(
        key: key,
        guideKey: index >= 0 && index < kMobileGuideKeys.length ? kMobileGuideKeys[index] : '',
        child: child,
      );

  void _open(BuildContext context, PageGuideData guide) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('কীভাবে কাজ করবেন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: W.ink(ctx))),
                const SizedBox(height: 10),
                PageGuideBody(guide: guide),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guide = kPageGuides[guideKey];
    if (guide == null) return child;
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 12,
          bottom: 84,
          child: Tooltip(
            message: 'কীভাবে কাজ করবেন',
            child: Material(
              color: W.blue(context),
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _open(context, guide),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.help_outline_rounded, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog / form এর মাথায় বসানোর ছোট "?" আইকন — চাপলে গাইড খোলে
class GuideIconButton extends StatelessWidget {
  final String guideKey;
  const GuideIconButton({super.key, required this.guideKey});

  @override
  Widget build(BuildContext context) {
    final guide = kPageGuides[guideKey];
    if (guide == null) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'কীভাবে কাজ করবেন',
      icon: Icon(Icons.help_outline_rounded, color: W.blueInk(context)),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('কীভাবে কাজ করবেন',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: W.ink(ctx))),
                  const SizedBox(height: 10),
                  PageGuideBody(guide: guide),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
