import 'package:flutter/material.dart';
import '../configs/configs.dart';

const double _kMenuCapHeight = 240;
const double _kMenuVerticalMargin = 6;

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
    this.isLabel = true,
    super.validator,
  }) : super(
    initialValue: value,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<T> state) {
      final context = state.context;

      final GlobalKey fieldKey = GlobalKey();
      OverlayEntry? overlayEntry;
      bool isOpen = false;

      final TextEditingController controller =
      TextEditingController(text: state.value?.toString() ?? '');

      /// ---------- ITEMS ----------
      final List<T> items = [...itemList];
      if (isNeedAll && allItem != null) {
        items.insert(0, allItem as T);
      }
      List<T> filteredItems = [...items];

      Rect? _getFieldRect() {
        final box =
        fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return null;
        final pos = box.localToGlobal(Offset.zero);
        return Rect.fromLTWH(
          pos.dx,
          pos.dy,
          box.size.width,
          box.size.height,
        );
      }

      void _removeOverlay() {
        overlayEntry?.remove();
        overlayEntry = null;
        isOpen = false;
      }

      OverlayEntry _createOverlay() {
        return OverlayEntry(
          builder: (context) {
            final media = MediaQuery.of(context);
            final fieldRect = _getFieldRect();
            if (fieldRect == null) return const SizedBox.shrink();

            final keyboard = media.viewInsets.bottom;
            final screenHeight = media.size.height;

            final spaceBelow = screenHeight -
                keyboard -
                fieldRect.bottom -
                _kMenuVerticalMargin;
            final spaceAbove =
                fieldRect.top - media.padding.top - _kMenuVerticalMargin;

            final bool showAbove =
                spaceAbove > spaceBelow && spaceAbove > 100;

            final double maxHeight = (showAbove
                ? spaceAbove
                : spaceBelow)
                .clamp(80.0, _kMenuCapHeight);

            final double top = showAbove
                ? fieldRect.top - maxHeight - _kMenuVerticalMargin
                : fieldRect.bottom + _kMenuVerticalMargin;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: Stack(
                children: [
                  Positioned(
                    left: fieldRect.left,
                    top: top,
                    width: fieldRect.width,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints:
                        BoxConstraints(maxHeight: maxHeight),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final item = filteredItems[index];
                            return InkWell(
                              onTap: () {
                                controller.text = item.toString();
                                state.didChange(item);
                                onChanged(item);
                                _removeOverlay();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                child: Text(
                                  item.toString(),
                                  style:
                                  AppTextStyle.body(context),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      void _showOverlay() {
        if (filteredItems.isEmpty) return;
        if (overlayEntry == null) {
          overlayEntry = _createOverlay();
          Overlay.of(context, rootOverlay: true)
              .insert(overlayEntry!);
          isOpen = true;
        } else {
          overlayEntry!.markNeedsBuild();
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- LABEL ----------
          if (isLabel) ...[
            Row(
              children: [
                Text(
                  label,
                  style: AppTextStyle
                      .labelDropdownTextStyle(context),
                ),
                if (isRequired)
                  const Text('*',
                      style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 4),
          ],

          /// ---------- FIELD ----------
          SizedBox(
            key: fieldKey,
            height: 55, // 🔒 FIXED HEIGHT
            child: TextField(
              controller: controller,
              readOnly: !isSearch,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              onTap: () {
                filteredItems = [...items];
                _showOverlay();
              },
              onChanged: (value) {
                if (!isSearch) return;
                filteredItems = items
                    .where((e) => e
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()))
                    .toList();
                _showOverlay();
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.greyColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.only(
                    right: 8,left: 0, bottom: 0,top: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? Colors.red
                        : AppColors.greyColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? Colors.red
                        : AppColors.primaryColor(context),
                  ),
                ),

                /// ---------- CLEAR + DROPDOWN ----------
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.text.isNotEmpty)
                      InkWell(
                        onTap: () {
                          controller.clear();
                          state.didChange(null);
                          onChanged(null);
                          _removeOverlay();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.close, size: 18),
                        ),
                      ),
                    InkWell(
                      onTap: () =>
                      isOpen ? _removeOverlay() : _showOverlay(),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ---------- ERROR ----------
          if (state.hasError)
            Padding(
              padding:
              const EdgeInsets.only(top: 4, left: 6),
              child: Text(
                state.errorText!,
                style:
                AppTextStyle.errorTextStyle(context),
              ),
            ),
        ],
      );
    },
  );

  final String label;
  final String hint;
  final bool isRequired;
  final bool isLabel;
  final bool isSearch;
  final bool isNeedAll;
  final T? allItem;
  final List<T> itemList;
  final void Function(T?) onChanged;
}
