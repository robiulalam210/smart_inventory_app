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

          Row(
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
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),

              // Page numbers
              ..._buildPageNumbers(),

              // Next button
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    // Calculate the range of pages to show
    int startPage = (currentPage - 1).clamp(0, totalPages - 1);
    int endPage = (currentPage + 2).clamp(0, totalPages);

    // Adjust startPage if we're near the end
    if (endPage - startPage < 3 && startPage > 0) {
      startPage = (endPage - 3).clamp(0, totalPages - 1);
    }

    for (int i = startPage; i < endPage; i++) {
      pages.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton(
            onPressed: () => onPageChanged(i),
            style: TextButton.styleFrom(
              backgroundColor: i == currentPage
                  ? AppColors.primaryColor
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              (i + 1).toString(),
              style: TextStyle(
                color: i == currentPage ? Colors.white : Colors.black,
                fontWeight:
                i == currentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return pages;
  }
}