import 'package:flutter/material.dart';

typedef PageChangedCallback = void Function(int page);
typedef PageSizeChangedCallback = void Function(int pageSize);

class PaginationBar extends StatelessWidget {
  final int count; // total items
  final int totalPages;
  final int currentPage; // 1-based
  final int pageSize;
  final int from;
  final int to;
  final List<int> pageSizeOptions;
  final PageChangedCallback onPageChanged;
  final PageSizeChangedCallback onPageSizeChanged;

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
    this.pageSizeOptions = const [10, 20, 50, 100],
  });

  Widget _buildPageButton(BuildContext context, int page, bool isActive) {
    return SizedBox(
      width: 36,
      height: 36,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.grey.shade200 : Colors.transparent,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
        ),
        onPressed: isActive ? null : () => onPageChanged(page),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isActive ? Colors.black : Theme.of(context).primaryColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    // Build a compact windowed page list: show first, last, and neighbors
    const int window = 2; // show +/-2 pages around current
    final List<int> pages = [];

    for (int i = 1; i <= totalPages; i++) {
      if (i == 1 ||
          i == totalPages ||
          (i >= currentPage - window && i <= currentPage + window)) {
        pages.add(i);
      } else if (pages.isNotEmpty && pages.last != -1) {
        // placeholder for ellipsis, represented by -1
        pages.add(-1);
      }
    }

    return pages.map<Widget>((p) {
      if (p == -1) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('...', style: TextStyle(fontSize: 12)),
        );
      }
      return _buildPageButton(context, p, p == currentPage);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Showing X to Y of Z entries
          Expanded(
            child: Text(
              'Showing $from to $to of $count entries',
              style: const TextStyle(fontSize: 13),
            ),
          ),

          // Page size dropdown
          Row(
            children: [
              const Text('Show', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: pageSize,
                items: pageSizeOptions
                    .map((s) => DropdownMenuItem<int>(
                  value: s,
                  child: Text(s.toString()),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null && value != pageSize) {
                    onPageSizeChanged(value);
                  }
                },
                underline: Container(),
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Prev button
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
          ),

          // Page numbers
          ..._buildPageNumbers(context),

          // Next button
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next',
          ),
        ],
      ),
    );
  }
}