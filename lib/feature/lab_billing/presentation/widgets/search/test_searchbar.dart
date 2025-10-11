import 'package:collection/collection.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../../core/configs/configs.dart';
import '../../../data/models/tests_model/tests_model.dart';
import '../../bloc/lab_billing/lab_billing_bloc.dart';
import '../../bloc/test_bloc/test_bloc.dart';

class TestSearchWidget extends StatefulWidget {
  const TestSearchWidget({super.key});

  @override
  State<TestSearchWidget> createState() => _TestSearchWidgetState();
}

class _TestSearchWidgetState extends State<TestSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  late final LabBillingBloc labBillingBloc;

  @override
  void initState() {
    super.initState();

    labBillingBloc = context.read<LabBillingBloc>();

    _controller.addListener(() {
      setState(() {});
    });
    labBillingBloc.selectedCategoriesTest.addListener(() {
      labBillingBloc.testTypeAheadController.clear();
      labBillingBloc.selectedTest.value = null;
    });
  }

  void addSelectedTest(TestLocalModel selectedTest) {
    labBillingBloc.testTypeAheadController.clear();
    labBillingBloc.selectedTest.value = null;

    context.read<LabBillingBloc>().add(
          AddTestItem(
            id: selectedTest.orgTestNameId.toString(),
            name: selectedTest.name ?? "",
            code: selectedTest.code ?? "",
            type: "Test",
            price: selectedTest.fee ?? 0,
            quantity: 1,
            discountApplied: selectedTest.discountApplied ?? 0,
            discountPercentage: selectedTest.discount ?? 0.0,
            testGroupName: selectedTest.testGroupName,
          ),
        );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestBloc, TestState>(
      builder: (context, state) {
        if (state is TestLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TestLoaded) {
          final tests = state.tests;

          return ValueListenableBuilder<TestLocalModel?>(
            valueListenable: labBillingBloc.selectedTest,
            builder: (context, selectedTest, child) {
              if (!mounted) return Container();

              final selectedCategoryId = labBillingBloc
                  .selectedCategoriesTest.value?.orgTestCategoryId;

              // Filter tests by category; show all if null or 0 or empty
              final filteredTests = (selectedCategoryId == null ||
                      selectedCategoryId == 0 ||
                      (selectedCategoryId is String &&
                          selectedCategoryId.toString().isEmpty))
                  ? tests
                  : tests
                      .where((t) => t.testCategoryId == selectedCategoryId)
                      .toList();

              return TypeAheadField<TestLocalModel>(
                controller: labBillingBloc.testTypeAheadController,
                focusNode: labBillingBloc.testFocusNode,
                debounceDuration: const Duration(milliseconds: 300),
                // direction: VerticalDirection.down,

                direction: VerticalDirection.down,
                // 👈 this shows the list upward
                suggestionsCallback: (pattern) async {
                  final query = pattern.toLowerCase();

                  final matches = filteredTests
                      .where((test) =>
                          test.name.toString().toLowerCase().contains(query))
                      .toList();

                  matches.sort((a, b) {
                    final aName = a.name.toString().toLowerCase();
                    final bName = b.name.toString().toLowerCase();

                    final aStartsWith = aName.startsWith(query) ? 0 : 1;
                    final bStartsWith = bName.startsWith(query) ? 0 : 1;

                    // If both start with or both don't, sort alphabetically
                    if (aStartsWith == bStartsWith) {
                      return aName.compareTo(bName);
                    }

                    return aStartsWith.compareTo(bStartsWith);
                  });

                  return matches;
                },
                itemBuilder: (context, test) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.bodyPadding,
                          vertical: AppSizes.bodyPadding),
                      color: AppColors.white.withValues(alpha: 0.6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 300,
                              child: Text(test.name ?? "N/A",
                                  style: AppTextStyle.cardLevelText(context))),
                          Text(test.code ?? "",
                              style: AppTextStyle.cardLevelText(context)),
                          Text(test.fee.toString(),
                              style: AppTextStyle.cardLevelText(context)),
                        ],
                      ),
                    ),
                  );
                },

                onSelected: (test) {
                  addSelectedTest(test);
                },

                hideOnLoading: true,
                builder: (context, controller, focusNode) {
                  return SizedBox(
                    height: 35,
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        final selectedCategoryId = labBillingBloc
                            .selectedCategoriesTest.value?.orgTestCategoryId;

                        final filteredTests = (selectedCategoryId == null ||
                                selectedCategoryId == 0 ||
                                (selectedCategoryId is String &&
                                    selectedCategoryId.toString().isEmpty))
                            ? state.tests
                            : state.tests
                                .where((t) =>
                                    t.testCategoryId == selectedCategoryId)
                                .toList();

                        final selectedTest = filteredTests.firstWhereOrNull(
                          (t) => t.name?.toLowerCase() == value.toLowerCase(),
                        );

                        if (selectedTest != null) {
                          addSelectedTest(selectedTest);
                        }
                      },
                      controller: controller,
                      focusNode: focusNode,
                      onTap: () {
                        controller.clear();
                        _controller.clear();
                        labBillingBloc.selectedTest.value = null;
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(top: 4, bottom: 4, left: 6),
                        hintText: 'Search by Test',
                        hintStyle: TextStyle(
                          color: AppColors.matteBlack,
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? InkWell(
                                child:
                                    const Icon(Icons.clear_rounded, size: 16),
                                onTap: () {
                                  controller.clear();
                                  _controller.clear();
                                  labBillingBloc.selectedTest.value = null;
                                  focusNode.requestFocus();
                                },
                              )
                            : const Icon(Icons.search_rounded, size: 16),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          borderSide:
                              BorderSide(color: AppColors.error, width: 0.7),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          borderSide: BorderSide(
                              color: AppColors.matteBlack, width: 0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          borderSide:
                              BorderSide(color: AppColors.border, width: 0.7),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          borderSide:
                              BorderSide(color: AppColors.error, width: 0.7),
                        ),
                      ),
                    ),
                  );
                },
                constraints: BoxConstraints(
                  maxHeight: 300,
                  minWidth: MediaQuery.of(context).size.width * 0.5,
                ),
              );
            },
          );
        } else if (state is TestError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        return const Center(child: Text("No data available"));
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
