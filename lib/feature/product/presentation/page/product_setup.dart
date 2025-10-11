import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../responsive.dart';

class ProductSetupScreen extends StatefulWidget {
  const ProductSetupScreen({super.key});

  @override
  State<ProductSetupScreen> createState() => _ProductSetupScreenState();
}

class _ProductSetupScreenState extends State<ProductSetupScreen> {
  static const menuItems = [
    'Product',
    'Category',
    'Unit',
    'Group',
    'Source Table',
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Container(
    color: AppColors.bg,
    child: SafeArea(
    child: Container(

    child:  _buildMainContent(),
    ),
    ),
    );
    }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen) _buildSidebar(),
        _buildContentArea(isBigScreen),
      ],
    );
  }

  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0,
      sm: 1,
      md: 1,
      lg: 2,
      xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: Container(
        color: AppColors.bg,
        child:

         SizedBox(
          height: 400,

          child: Column(
            // Give height to Row by putting it inside an Expanded of a Column!
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Sidebar
                    Expanded(
                      flex: 2,
                      child: SidebarMenu(
                        menuItems: menuItems,
                        selectedIndex: selectedIndex,
                        onMenuTap: (i) => setState(() => selectedIndex = i),
                      ),
                    ),
                    // Main content
                    Expanded(
                      flex: 8,
                      child: ContentArea(
                        title: menuItems[selectedIndex],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  }
// }

class SidebarMenu extends StatelessWidget {
  final List<String> menuItems;
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;

  const SidebarMenu({
    Key? key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12),
            child: Text('Lab Setup',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          ...List.generate(menuItems.length, (i) {
            return ListTile(
              leading: const Icon(Icons.add_circle_outline, size: 18),
              title: Text(menuItems[i]),
              selected: selectedIndex == i,
              onTap: () => onMenuTap(i),
            );
          }),
        ],
      ),
    );
  }
}

class ContentArea extends StatelessWidget {
  final String title;
  const ContentArea({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No need for LayoutBuilder if parent is bounded!
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Add refresh logic
      },

      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Back to list'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SearchBar(),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // TODO: Clear filter logic
            },
            child: const Text("Clear"),
          ),
          const SizedBox(height: 10),
          if (title == 'Product')
            const TableContainer(child: ProductTable())
          else if (title == 'Category')
            const TableContainer(child: CategoryTable())
          else if (title == 'Unit')
              const TableContainer(child: UnitTable())
            else if (title == 'Group')
                const TableContainer(child: GroupTable())
              else if (title == 'Source Table')
                  const TableContainer(child: SourceTableTable())
        ],
      ),
    );
  }
}

// --- TableContainer gives bounded height for DataTable! ---
class TableContainer extends StatelessWidget {
  final Widget child;
  const TableContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Or MediaQuery.of(context).size.height * 0.5 for more dynamic sizing
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: child,
        ),
      ),
    );
  }
}

// Example table widgets
class ProductTable extends StatelessWidget {
  const ProductTable({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('SL')),
        DataColumn(label: Text('Product Name')),
        DataColumn(label: Text('Action')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('1')),
          const DataCell(Text('Aspirin')),
          DataCell(IconButton(icon: const Icon(Icons.edit), onPressed: () {})),
        ]),
        // Add more rows as needed
      ],
    );
  }
}

class CategoryTable extends StatelessWidget {
  const CategoryTable({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('SL')),
        DataColumn(label: Text('Category Name')),
        DataColumn(label: Text('Action')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('1')),
          const DataCell(Text('Tablet')),
          DataCell(IconButton(icon: const Icon(Icons.edit), onPressed: () {})),
        ]),
      ],
    );
  }
}

class UnitTable extends StatelessWidget {
  const UnitTable({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('SL')),
        DataColumn(label: Text('Unit')),
        DataColumn(label: Text('Action')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('1')),
          const DataCell(Text('Box')),
          DataCell(IconButton(icon: const Icon(Icons.edit), onPressed: () {})),
        ]),
      ],
    );
  }
}

class GroupTable extends StatelessWidget {
  const GroupTable({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('SL')),
        DataColumn(label: Text('Group Name')),
        DataColumn(label: Text('Action')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('1')),
          const DataCell(Text('Radiology')),
          DataCell(IconButton(icon: const Icon(Icons.edit), onPressed: () {})),
        ]),
      ],
    );
  }
}

class SourceTableTable extends StatelessWidget {
  const SourceTableTable({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('SL')),
        DataColumn(label: Text('Source Name')),
        DataColumn(label: Text('Action')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('1')),
          const DataCell(Text('Main Source')),
          DataCell(IconButton(icon: const Icon(Icons.edit), onPressed: () {})),
        ]),
      ],
    );
  }
}

// Search bar widget - keep your implementation
class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // TODO: Clear search field
          },
        ),
        hintText: 'Search',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      ),
    );
  }
}