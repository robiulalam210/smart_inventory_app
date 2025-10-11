import '../configs/configs.dart';

class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final List<int> pageSizeOptions;
  final void Function(int newPage) onPageChanged;
  final void Function(int newPageSize) onPageSizeChanged;

  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    this.pageSizeOptions = const [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (startItem + itemsPerPage - 1).clamp(1, totalItems);

    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text summary
          Text('Showing $startItem to $endItem of $totalItems entries  '),

          // Page size dropdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            SizedBox(width: 60,child:   DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: itemsPerPage,
                padding: EdgeInsets.zero,
                items: pageSizeOptions.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onPageSizeChanged(value);
                  }
                },
              ),
            ),),
              const SizedBox(width: 12),

              // Pagination arrows
              IconButton(              padding: EdgeInsets.zero,

                icon: const Icon(Icons.chevron_left),
                onPressed:
                    currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              ),
              Text('$startItem - $endItem of $totalItems'),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class PaginationBar extends StatelessWidget {
//   final int totalPages;
//   final int currentPage; // 1-based page number
//   final ValueChanged<int> onPageSelected;
//   final Color activeColor;
//   final Color inactiveColor;
//
//   const PaginationBar({
//     super.key,
//     required this.totalPages,
//     required this.currentPage,
//     required this.onPageSelected,
//     this.activeColor = Colors.blue,
//     this.inactiveColor = Colors.grey,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(totalPages, (index) {
//           final pageNumber = index + 1; // 1-based page number
//           final isActive = currentPage == pageNumber;
//
//           return GestureDetector(
//             onTap: () => onPageSelected(pageNumber),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
//               decoration: BoxDecoration(
//                 color: isActive ? activeColor : inactiveColor,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 '$pageNumber',
//                 style: TextStyle(
//                   color: isActive ? Colors.white : Colors.black,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
