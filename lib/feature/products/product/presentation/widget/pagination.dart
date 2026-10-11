import 'package:flutter/material.dart';

import '../../../../../core/widgets/web_ui.dart';

/// পাতা বদলের সারি — ওয়েবের .pager এর মতো:
///   "Showing 1–30 of 120"   ‹ 1 … 4 [5] 6 … 20 ›   এবং প্রতি পাতায় কতটা (সেগমেন্ট)।
/// API আগের মতোই, তাই ৪১টা স্ক্রিনের কোড বদলাতে হয়নি।
class PaginationBar extends StatelessWidget {
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;
  final Function(int) onPageChanged;
  final Function(int) onPageSizeChanged;

  const PaginationBar({
    super.key,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  static const List<int> _sizes = [10, 20, 30, 50, 100];

  @override
  Widget build(BuildContext context) {
    // বর্তমান size তালিকায় না থাকলে সেটাও দেখাই, যাতে বাছাই করা মানটা হারিয়ে না যায়
    final sizes = [..._sizes];
    if (!sizes.contains(pageSize) && pageSize > 0) {
      sizes.add(pageSize);
      sizes.sort();
    }

    return LayoutBuilder(builder: (context, c) {
      // সরু পর্দায় (মোবাইল) শুধু পাতা-নম্বর; size বাছাই লুকাই
      final bool showSizes = c.maxWidth >= 640;
      return Container(
        decoration: BoxDecoration(
          color: W.surface(context),
          border: Border.all(color: W.line(context)),
          borderRadius: BorderRadius.circular(W.rLg),
        ),
        child: Row(
          children: [
            Expanded(
              child: WPager(
                page: currentPage,
                totalPages: totalPages < 1 ? 1 : totalPages,
                count: count,
                from: from,
                to: to,
                onPage: (p) => onPageChanged(p),
              ),
            ),
            if (showSizes)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Per page',
                        style: TextStyle(fontSize: 13, color: W.muted(context))),
                    const SizedBox(width: 8),
                    WSeg(
                      items: [for (final s in sizes) ('$s', '$s')],
                      value: '$pageSize',
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n != pageSize) onPageSizeChanged(n);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
