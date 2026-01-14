import 'package:flutter/material.dart';
import '../../../../../core/configs/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<int> pageSizes = [5, 10, 20, 30, 50, 100];
    final List<int> availablePageSizes = List.from(pageSizes);

    if (!availablePageSizes.contains(pageSize)) {
      availablePageSizes.add(pageSize);
      availablePageSizes.sort();
    }

    final bool showPaginationControls = totalPages > 1;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT — RESULT TEXT
          Expanded(
            child: Text(
              'Showing $from to $to of $count',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.text(context),

              ),
            ),
          ),

          const SizedBox(width: 8),

          /// RIGHT — PAGINATION (SCROLLABLE)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: showPaginationControls
                  ? _buildFullPaginationControls(
                context,
                availablePageSizes,
              )
                  : _buildPageSizeOnly(context ,availablePageSizes),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FULL PAGINATION =================

  Widget _buildFullPaginationControls(
      BuildContext context,
      List<int> availablePageSizes,
      ) {
    return Row(
      children: [
         Text(
          'Show:',
          style: TextStyle(fontSize: 14,               color: AppColors.text(context),
          ),
        ),
        const SizedBox(width: 8),

        _pageSizeDropdown(context ,availablePageSizes),

        const SizedBox(width: 12),

        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
          currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),

        ..._buildPageNumbers(context),

        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  // ================= PAGE SIZE ONLY =================

  Widget _buildPageSizeOnly(BuildContext context ,List<int> availablePageSizes) {
    return Row(
      children: [
         Text(
          'Show:',
          style: TextStyle(fontSize: 14,               color: AppColors.text(context),
          ),
        ),
        const SizedBox(width: 8),
        _pageSizeDropdown(context ,availablePageSizes),
      ],
    );
  }

  // ================= DROPDOWN =================

  Widget _pageSizeDropdown(BuildContext context ,List<int> availablePageSizes) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<int>(
        value: pageSize,
        underline: const SizedBox(),
        icon:  Icon(
          Icons.arrow_drop_down,
          size: 20,
          color: AppColors.primaryColor(context),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        onChanged: (value) {
          if (value != null) onPageSizeChanged(value);
        },
        items: availablePageSizes.map((value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value.toString(),
              style:  TextStyle(color: AppColors.primaryColor(context)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= PAGE NUMBERS =================

  List<Widget> _buildPageNumbers(BuildContext context) {
    final List<Widget> pages = [];

    if (totalPages <= 1) return pages;

    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;
    final int maxVisiblePages = isSmallScreen ? 3 : 5;

    int startPage = (currentPage - (maxVisiblePages ~/ 2))
        .clamp(1, totalPages);
    int endPage = (startPage + maxVisiblePages - 1)
        .clamp(1, totalPages);

    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = (endPage - maxVisiblePages + 1)
          .clamp(1, totalPages);
    }

    if (startPage > 1) {
      pages.add(_pageButton(context ,1));
      if (startPage > 2) {
        pages.add(const Text('...', style: TextStyle(color: Colors.grey)));
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pages.add(_pageButton(context ,i));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(const Text('...', style: TextStyle(color: Colors.grey)));
      }
      pages.add(_pageButton(context ,totalPages));
    }

    return pages;
  }

  // ================= PAGE BUTTON =================

  Widget _pageButton(BuildContext context ,int page) {
    final bool isActive = page == currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => onPageChanged(page),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          backgroundColor:
          isActive ? AppColors.primaryColor(context) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: isActive
                  ? AppColors.primaryColor(context)
                  : Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.white :                              AppColors.text(context)
          ,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
