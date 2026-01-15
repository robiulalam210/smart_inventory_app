import 'package:flutter/material.dart';
import '../configs/configs.dart';

class AppDropdown<T> extends FormField<T> {
  AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    T? value,
    required this.itemList,
    required this.onChanged,
    this.isSearch = false,
    this.isNeedAll = false,
    this.allItem,
    this.isLabel = false,
    super.validator,
  }) : super(
    initialValue: value,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<T> state) {
      final context = state.context;
      final bool showLabel = !(isLabel ?? false);
      final bool isMobile = Responsive.isMobile(context);

      // ---------- SAFE LIST ----------
      final List<T> items = [...itemList];
      final List<String> displayTexts =
      itemList.map((e) => e.toString()).toList();

      if (isNeedAll && allItem != null) {
        items.insert(0, allItem as T);
        displayTexts.insert(0, allItem.toString());
      }

      final TextEditingController controller = TextEditingController(
        text: state.value?.toString() ?? "",
      );

      OverlayEntry? overlayEntry;

      void removeOverlay() {
        overlayEntry?.remove();
        overlayEntry = null;
      }

      void showOverlay() {
        removeOverlay();

        final RenderBox renderBox =
        context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero);

        overlayEntry = OverlayEntry(
          builder: (_) {
            return Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: Material(
                elevation: 4,
                color: AppColors.bottomNavBg(context),
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: displayTexts.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (_, index) {
                      return InkWell(
                        onTap: () {
                          final selectedItem = items[index];
                          state.didChange(selectedItem);
                          onChanged(selectedItem);
                          controller.text = displayTexts[index];
                          removeOverlay();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Text(
                            displayTexts[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.text(context),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );

        Overlay.of(context).insert(overlayEntry!);
      }

      return SizedBox(
        height: showLabel
            ? (isMobile ? 83 : 66)
            : (isMobile ? 60 : 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- LABEL ----------
            if (showLabel)
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text(context),
                    ),
                  ),
                  if (isRequired)
                    const Text("*",
                        style: TextStyle(color: Colors.red)),
                ],
              ),
            if (showLabel) const SizedBox(height: 4),

            // ---------- INPUT ----------
            SizedBox(
              height: isMobile ? 40 : 36,
              child: TextField(
                controller: controller,
                readOnly: !isSearch,
                onTap: showOverlay,
                onChanged: (v) {
                  if (isSearch) {
                    state.didChange(null);
                    showOverlay();
                  }
                },
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: state.hasError
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: state.hasError
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? InkWell(
                    onTap: () {
                      controller.clear();
                      state.didChange(null);
                      onChanged(null);
                      removeOverlay();
                    },
                    child: const Icon(
                        Icons.clear,
                        size: 18),
                  )
                      : InkWell(
                    onTap: showOverlay,
                    child: const Icon(
                        Icons.arrow_drop_down,
                        size: 20),
                  ),
                ),
              ),
            ),

            // ---------- ERROR TEXT ----------
            if (state.hasError)
              Padding(
                padding:
                const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.red,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  final String label;
  final String hint;
  final bool isRequired;
  final bool? isLabel;
  final bool isSearch;
  final bool isNeedAll;
  final T? allItem;
  final List<T> itemList;
  final void Function(T?) onChanged;
}
