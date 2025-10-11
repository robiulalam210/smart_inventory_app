

import '../../../../../core/configs/configs.dart';
import '../../bloc/lab_billing/lab_billing_bloc.dart';

class TestItemTable extends StatefulWidget {
  const TestItemTable({super.key});

  @override
  State<TestItemTable> createState() => _TestItemTableState();
}

class _TestItemTableState extends State<TestItemTable> {
  final ScrollController _horizontalScrollController = ScrollController();

  // Add this controller
  final ScrollController _verticalScrollController = ScrollController();

  // Add this controller

  @override
  void dispose() {
    _verticalScrollController.dispose(); // Dispose to prevent memory leaks
    _horizontalScrollController.dispose(); // Dispose to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabBillingBloc, LabBillingState>(
      builder: (context, state) {
        List<Map<String, dynamic>> testItems = [];

        if (state is LabBillingUpdated) {
          testItems = state.testItems;
        }

        return _buildTestTable(testItems);
      },
    );
  }

  Widget _buildTestTable(List<Map<String, dynamic>> testItems) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 20;
        final int numColumns = 8;
        final double columnWidth = totalWidth / numColumns;

        const double rowHeight = 48.0;
        const int maxVisibleRows = 10;

        // Calculate subtotal
        final double subTotal = testItems.fold(0.0, (sum, item) {
          final rate = item['total'] ?? 0;
          return sum + rate;
        });

        final double bodyHeight = testItems.length > maxVisibleRows
            ? rowHeight * maxVisibleRows
            : rowHeight * testItems.length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6ab129),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('Item Code', columnWidth),
                          _buildHeaderCell('Test Name', columnWidth),
                          _buildHeaderCell('Rate', columnWidth),
                          _buildHeaderCell('Discount', columnWidth),
                          _buildHeaderCell('Amount', columnWidth),
                          _buildHeaderCell('Qty', columnWidth),
                          _buildHeaderCell('Total', columnWidth),
                          _buildHeaderCell('Action', columnWidth),
                        ],
                      ),
                    ),

                    // Scrollable body with dynamic height
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: bodyHeight),
                      child: Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          child: Column(
                            children: testItems.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final item = entry.value;

                              return Container(
                                height: rowHeight,
                                color: index % 2 == 0
                                    ? Colors.white54
                                    : Colors.grey.shade200,
                                child: Row(
                                  children: [
                                    _buildDataCell(
                                        item['code'] ?? "", columnWidth),
                                    _buildDataCell(item['name'], columnWidth),
                                    _buildDataCell(
                                        '${item['rate']}', columnWidth),
                                    _buildDataCell(item['discountApplied']==0?"":"${item['discountPercentage']}%",
                                        columnWidth),
                                    _buildDataCell(
                                        '${item['discountApplied']==0?"":item['amount'] ?? 0}', columnWidth),
                                    _buildQtyCell(item, index, columnWidth),
                                    _buildDataCell(
                                      '${((item['total'] ?? 0)).toStringAsFixed(2)}',
                                      columnWidth,
                                    ),
                                    SizedBox(
                                      width: columnWidth,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          context
                                              .read<LabBillingBloc>()
                                              .add(RemoveTestItem(index));
                                        },
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.black,
                                            size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    gapH20,
                    // Sub Total row (fixed)
                    Container(
                      color: Colors.white54,
                      // padding: const EdgeInsets.symmetric(
                      //     vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: columnWidth * 5,
                            alignment: Alignment.center,
                            child: const Text(
                              '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: columnWidth,
                            alignment: Alignment.center,
                            child: const Text(
                              'Sub Total:',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: columnWidth,
                            alignment: Alignment.center,
                            child: Text(
                              " ${subTotal.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(width: columnWidth),
                          // for Action column spacing
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildQtyCell(Map<String, dynamic> item, int index, double width) {
    final isInventory = item["type"] == "Inventory";
    final initialQty = (item['qty'] is int)
        ? item['qty']
        : int.tryParse(item['qty']?.toString() ?? '') ?? 1;

    final TextEditingController qtyController = TextEditingController(
      text: initialQty.toString(),
    );

    if (!isInventory) {
      return SizedBox(width: width, child: const Text(''));
    }

    return SizedBox(
      width: width,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            width: 60,
            child: StatefulBuilder(
              builder: (context, setStateInternal) {
                return TextFormField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    int newQty = int.tryParse(value) ?? 1;

                    /// Prevent setting zero or negative
                    if (newQty <= 0 && value.isNotEmpty) {
                      Future.microtask(() {
                        // qtyController.text = '1';
                        // qtyController.selection = TextSelection.fromPosition(
                        //   const TextPosition(offset: 1),
                        // );
                      });
                      // newQty = 1;
                    }

                    // setState(() {
                    //   setState(() {
                    //     context.read<LabBillingBloc>().testItems[index]['qty'] = newQty;
                    //   });
                    //   setStateInternal(() {});
                    //   context.read<LabBillingBloc>().testItems[index]['qty'] =
                    //       newQty;
                    // });
                                context.read<LabBillingBloc>().add(UpdateTestItemQty(index: index, qty: newQty));
setState(() {

});
                    // setStateInternal(() {}); // update suffix icon state
                  },
                  decoration: InputDecoration(

                    fillColor: AppColors.bg,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      borderSide: const BorderSide(color: AppColors.matteBlack),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
