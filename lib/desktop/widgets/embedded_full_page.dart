import 'package:flutter/material.dart';
import 'package:meherinMart/core/configs/configs.dart';
import 'package:meherinMart/desktop/widgets/sidebar.dart';

/// FIX: Root screen এর main area একটা SingleChildScrollView (অসীম উচ্চতা)। তার ভিতরে
/// নিজস্ব Scaffold (FAB সহ) থাকা screen বসালে Scaffold এর মাপ ঠিক হয় না →
/// "Cannot hit test a render box that has never been laid out" error।
/// তাই এই screen গুলোকে window এর উচ্চতা অনুযায়ী নির্দিষ্ট মাপ দেওয়া হয়।
class EmbeddedFullPage extends StatelessWidget {
  final Widget child;
  const EmbeddedFullPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final h = screenH - 90; // header + padding
    // বাকি সব screen এ big screen এ বাম পাশে Sidebar (12 column এর 2টা) থাকে।
    // Embedded screen (Income List / Income Head / Sale Mode) এ সেটা ছিল না — এখানে যোগ করা হলো।
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return SizedBox(
      height: h < 400 ? 400 : h,
      child: isBigScreen
          ? LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth / 12 * 2,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minHeight: 0,
                          maxHeight: screenH,
                          child: Container(
                            color: Colors.white,
                            child: const Sidebar(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: child),
                  ],
                );
              },
            )
          : child,
    );
  }
}
