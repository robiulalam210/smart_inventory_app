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

           final LayerLink layerLink = LayerLink();
           OverlayEntry? overlayEntry;
           bool isOpen = false;

           final TextEditingController controller = TextEditingController(
             text: state.value?.toString() ?? "",
           );

           // ---------- ITEMS ----------
           final List<T> items = [...itemList];
           if (isNeedAll && allItem != null) {
             items.insert(0, allItem as T);
           }

           // ---------- SEARCH STATE (PERSISTENT) ----------
           List<T> filteredItems = [...items];

           void closeOverlay() {
             overlayEntry?.remove();
             overlayEntry = null;
             isOpen = false;
           }

           void openOverlay() {
             if (isOpen) return;
             isOpen = true;

             final RenderBox renderBox =
                 context.findRenderObject() as RenderBox;
             final size = renderBox.size;

             overlayEntry = OverlayEntry(
               builder: (_) => GestureDetector(
                 behavior: HitTestBehavior.translucent,
                 onTap: closeOverlay,
                 child: Stack(
                   children: [
                     Positioned(
                       width: size.width,
                       child: CompositedTransformFollower(
                         link: layerLink,
                         offset: Offset(0, size.height + 4),
                         child: Material(
                           elevation: 4,
                           borderRadius: BorderRadius.circular(8),
                           color: AppColors.bottomNavBg(context),
                           child: StatefulBuilder(
                             builder: (context, setOverlayState) {
                               return ConstrainedBox(
                                 constraints: const BoxConstraints(
                                   maxHeight: 220,
                                 ),
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
                                         closeOverlay();
                                       },
                                       child: Padding(
                                         padding: const EdgeInsets.symmetric(
                                           vertical: 6,
                                           horizontal: 12,
                                         ),
                                         child: Text(
                                           item.toString(),
                                           style: AppTextStyle.body(context),
                                         ),
                                       ),
                                     );
                                   },
                                 ),
                               );
                             },
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             );

             Overlay.of(context).insert(overlayEntry!);
           }

           return SizedBox(
             height: showLabel ? (isMobile ? 83 : 68) : (isMobile ? 60 : 50),
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
                         const Text("*", style: TextStyle(color: Colors.red)),
                     ],
                   ),
                 if (showLabel) const SizedBox(height: 4),

                 // ---------- INPUT ----------
                 CompositedTransformTarget(
                   link: layerLink,

                   child: SizedBox(
                     height: isMobile ? 35 : 30, // ✅ proper height
                     child: TextField(
                       maxLines: 1,
                       controller: controller,
                       readOnly: !isSearch,
                       onTap: () {
                         filteredItems = [...items];
                         openOverlay();
                       },
                       onChanged: (value) {
                         if (!isSearch) return;

                         filteredItems = items
                             .where(
                               (e) => e.toString().toLowerCase().contains(
                                 value.toLowerCase(),
                               ),
                             )
                             .toList();

                         if (!isOpen) {
                           openOverlay();
                         } else {
                           overlayEntry?.markNeedsBuild();
                         }
                       },
                       decoration: InputDecoration(
                         hintText: hint,
                         hintStyle: AppTextStyle.body(context),
                         counterStyle: AppTextStyle.body(context),
                         helperStyle: AppTextStyle.body(context),

                         isDense: true,
                         contentPadding: EdgeInsets.zero,

                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(6),
                         ),
                         enabledBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(6),
                           borderSide: BorderSide(
                             color: state.hasError ? Colors.red : Colors.grey,
                           ),
                         ),
                         focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(6),
                           borderSide: BorderSide(
                             color: state.hasError ? Colors.red : Colors.blue,
                           ),
                         ),
                         suffixIcon: InkWell(
                           onTap: () {
                             filteredItems = [...items];
                             openOverlay();
                           },
                           child: Icon(
                             isOpen
                                 ? Icons.arrow_drop_up
                                 : Icons.arrow_drop_down,
                             size: 20,
                           ),
                         ),
                       ),
                     ),
                   ),
                 ),

                 // ---------- ERROR ----------
                 if (state.hasError)
                   Padding(
                     padding: const EdgeInsets.only(top: 2, left: 4),
                     child: Text(
                       state.errorText!,
                       style: const TextStyle(
                         fontSize: 10.5,
                         color: Colors.red,
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
