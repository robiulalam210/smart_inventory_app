import 'package:google_fonts/google_fonts.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/customer_model.dart';
import '../bloc/customer/customer_bloc.dart';
import '../pages/create_customer_screen.dart';

class CustomerTableCard extends StatelessWidget {
  final List<CustomerModel> customers;
  final VoidCallback? onCustomerTap;

  const CustomerTableCard({
    super.key,
    required this.customers,
    this.onCustomerTap,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 7; // Changed from 6 to 7 to include Status column
        const minColumnWidth = 90.0; // Slightly smaller to accommodate extra column

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: customers.asMap().entries.map((entry) {
                            final customer = entry.value;
                            final dueValue = customer.totalDue != null
                                ? double.tryParse(customer.totalDue.toString())
                                : null;

                            return DataRow(
                              onSelectChanged: onCustomerTap != null ? (_) => onCustomerTap!() : null,
                              cells: [
                                _buildDataCell('${customer.clientNo}', dynamicColumnWidth * 0.6),
                                _buildDataCell(customer.name ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(customer.phone ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(customer.address ?? "N/A", dynamicColumnWidth),
                                _buildStatusCell(customer.isActive ?? false, dynamicColumnWidth),
                                _buildBalanceCell(dueValue, dynamicColumnWidth),
                                _buildActionCell(customer, context, dynamicColumnWidth),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('No.', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Phone', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Address', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Status', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Balance', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(bool isActive, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildBalanceCell(double? dueValue, double width) {
    Color getAmountColor() {
      if (dueValue == null) return Colors.grey;
      if (dueValue < 0) return Colors.green;
      if (dueValue > 0) return Colors.red;
      return Colors.grey;
    }

    String getAmountText() {
      if (dueValue == null) return "N/A";
      return dueValue.abs().toStringAsFixed(2);
    }

    String getAmountLabel() {
      if (dueValue == null) return "N/A";
      if (dueValue < 0) return "Advance";
      if (dueValue > 0) return "Due";
      return "Paid";
    }

    return DataCell(
      SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getAmountText(),
              style: TextStyle(
                color: getAmountColor(),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              getAmountLabel(),
              style: TextStyle(
                color: getAmountColor(),
                fontWeight: FontWeight.w400,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildActionCell(CustomerModel customer, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Edit Button
            IconButton(
              onPressed: () {
                context.read<CustomerBloc>().customerNameController.text = customer.name ?? "";
                context.read<CustomerBloc>().customerNumberController.text = customer.phone ?? "";
                context.read<CustomerBloc>().addressController.text = customer.address ?? "";
                context.read<CustomerBloc>().customerEmailController.text = customer.email?.toString() ?? "";
                context.read<CustomerBloc>().selectedState = customer.isActive == true ? "Active" : "Inactive";
                _showEditDialog(context, customer);
              },
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.blue,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),

            // Delete Button
            IconButton(
              onPressed: () async {
                bool shouldDelete = await showDeleteConfirmationDialog(context);
                if (!shouldDelete) return;

                context.read<CustomerBloc>().add(DeleteCustomer(customer.id.toString()));
              },
              icon: const Icon(
                HugeIcons.strokeRoundedDeleteThrow,
                size: 18,
                color: Colors.red,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.50,
            child: CreateCustomerScreen(
              id: customer.id.toString(),
              submitText: "Update Customer",
            ),
          ),
        );
      },
    );
  }
}