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
    builder: (FormFieldState<T> state) {
      final context = state.context;
      final bool showLabel = !(isLabel ?? false);

      // ✅ SAFE LISTS
      final List<T> items = [...itemList];
      final List<String> displayTexts =
      itemList.map((e) => e.toString()).toList();

      // ✅ INSERT "ALL" AS T (NOT STRING)
      if (isNeedAll && allItem != null) {
        items.insert(0, allItem as T);
        displayTexts.insert(0, allItem.toString());
      }

      final TextEditingController controller = TextEditingController(
        text: state.value != null ? state.value.toString() : "",
      );

      final LayerLink layerLink = LayerLink();
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
          builder: (context) {
            return Positioned(
              left: offset.dx,
              width: size.width,
              top: offset.dy + size.height + 4,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: displayTexts.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
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
                            style: const TextStyle(fontSize: 14),
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
        height: showLabel ? 70 : 50,
        child: CompositedTransformTarget(
          link: layerLink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(
                height: 32,
                child: TextField(
                  controller: controller,
                  readOnly: !isSearch,
                  onTap: () {
                    if (!isSearch) showOverlay();
                  },
                  onChanged: (v) {
                    if (isSearch) showOverlay();
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    suffixIcon: controller.text.isNotEmpty
                        ? InkWell(
                      onTap: () {
                        controller.clear();
                        state.didChange(null);
                        removeOverlay();
                      },
                      child: const Icon(Icons.clear, size: 18),
                    )
                        : InkWell(
                      onTap: showOverlay,
                      child: const Icon(
                          Icons.arrow_drop_down,
                          size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
  final T? allItem; // ✅ IMPORTANT
  final List<T> itemList;
  final void Function(T?) onChanged;
}
