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
    // Define page sizes with unique values and include common values
    final List<int> pageSizes = [5, 10, 20, 30, 50, 100];

    // Ensure the current pageSize exists in the list, if not add it
    final List<int> availablePageSizes = List.from(pageSizes);
    if (!availablePageSizes.contains(pageSize)) {
      availablePageSizes.add(pageSize);
      availablePageSizes.sort();
    }

    // Hide pagination controls if there's only one page
    final bool showPaginationControls = totalPages > 1;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Results count
          Text(
            'Showing $from to $to of $count results',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          // Only show pagination controls if there are multiple pages
          if (showPaginationControls)
            _buildFullPaginationControls(availablePageSizes)
          else
            _buildPageSizeOnly(availablePageSizes),
        ],
      ),
    );
  }

  Widget _buildFullPaginationControls(List<int> availablePageSizes) {
    return Row(
      children: [
        // Page size dropdown
        const Text(
          'Show:',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<int>(
            value: pageSize,
            underline: const SizedBox(), // Remove default underline
            icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.primaryColor),
            style: const TextStyle(fontSize: 14, color: Colors.black),
            onChanged: (int? newValue) {
              if (newValue != null) {
                onPageSizeChanged(newValue);
              }
            },
            items: availablePageSizes.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),

        // Previous button
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
        ),

        // Page numbers
        ..._buildPageNumbers(),

        // Next button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildPageSizeOnly(List<int> availablePageSizes) {
    return Row(
      children: [
        const Text(
          'Show:',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<int>(
            value: pageSize,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.primaryColor),
            style: const TextStyle(fontSize: 14, color: Colors.black),
            onChanged: (int? newValue) {
              if (newValue != null) {
                onPageSizeChanged(newValue);
              }
            },
            items: availablePageSizes.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    // Don't show page numbers if there's only one page
    if (totalPages <= 1) {
      return pages;
    }

    // Show maximum 5 page buttons around current page
    const int maxVisiblePages = 5;
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    // Adjust if we're near the start
    if (startPage == 1) {
      endPage = (maxVisiblePages).clamp(1, totalPages);
    }

    // Adjust if we're near the end
    if (endPage == totalPages) {
      startPage = (totalPages - maxVisiblePages + 1).clamp(1, totalPages);
    }

    // Show first page with ellipsis if needed
    if (startPage > 1) {
      pages.add(_buildPageButton(1));
      if (startPage > 2) {
        pages.add(const Text('...', style: TextStyle(color: Colors.grey)));
      }
    }

    // Show page numbers
    for (int i = startPage; i <= endPage; i++) {
      pages.add(_buildPageButton(i));
    }

    // Show last page with ellipsis if needed
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(const Text('...', style: TextStyle(color: Colors.grey)));
      }
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => onPageChanged(page),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: page == currentPage
              ? AppColors.primaryColor
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: page == currentPage ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            fontSize: 14,
            color: page == currentPage ? Colors.white : Colors.black,
            fontWeight: page == currentPage ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}