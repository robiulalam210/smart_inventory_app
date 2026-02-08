// import '../configs/configs.dart';
//
// class AppDropdown<T> extends FormField<T> {
//   AppDropdown({
//     super.key,
//     required this.label,
//     required this.hint,
//     this.isRequired = false,
//     this.isLabel = false,
//     this.isSearch = false,
//     this.isNeedAll = false,
//     this.allItem,
//     T? value,
//     required this.itemList,
//     required this.onChanged,
//     String Function(T)? itemLabel,
//     super.validator,
//   }) : super(
//     initialValue: value,
//     autovalidateMode: AutovalidateMode.onUserInteraction,
//     builder: (FormFieldState<T> state) {
//       final context = state.context;
//
//       // Use local variable for itemLabel
//       final labelFn = itemLabel ?? (T item) => item.toString();
//
//       // Prepare items
//       final List<T> items = [...itemList];
//       if (isNeedAll && allItem != null) {
//         items.insert(0, allItem as T);
//       }
//
//       final displayText =
//       state.value != null ? labelFn(state.value as T) : '';
//
//       void showDropdown() {
//         FocusScope.of(context).unfocus();
//         Future.delayed(const Duration(milliseconds: 50), () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             useSafeArea: true,
//             builder: (sheetContext) {
//               return _DropdownBottomSheet<T>(
//                 items: items,
//                 selectedValue: state.value,
//                 hint: hint,
//                 isSearch: isSearch,
//                 itemLabel: labelFn,
//                 onChanged: (value) {
//                   state.didChange(value);
//                   onChanged(value);
//                   Navigator.pop(sheetContext);
//                 },
//               );
//             },
//           );
//         });
//       }
//
//       void handleClear() {
//         state.didChange(null);
//         onChanged(null);
//       }
//
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isLabel) ...[
//             Row(
//               children: [
//                 Text(label,
//                     style: AppTextStyle.labelDropdownTextStyle(context)),
//                 if (isRequired)
//                   const Text('*', style: TextStyle(color: Colors.red)),
//               ],
//             ),
//             const SizedBox(height: 4),
//           ],
//           SizedBox(
//             height: 35,
//             child: InkWell(
//               onTap: showDropdown,
//               borderRadius: BorderRadius.circular(AppSizes.radius),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: state.hasError
//                         ? Colors.red
//                         : AppColors.greyColor(context),
//                     width: 1,
//                   ),
//                   borderRadius: BorderRadius.circular(AppSizes.radius),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         displayText.isEmpty ? hint : displayText,
//                         style: TextStyle(
//                           color: displayText.isEmpty
//                               ? AppColors.greyColor(context)
//                               : AppColors.text(context),
//                           fontSize: 14,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (displayText.isNotEmpty)
//                           InkWell(
//                             onTap: handleClear,
//                             borderRadius: BorderRadius.circular(12),
//                             child: Padding(
//                               padding: const EdgeInsets.all(4),
//                               child: Icon(Icons.close,
//                                   size: 18,
//                                   color: AppColors.greyColor(context)),
//                             ),
//                           ),
//                         Icon(Icons.keyboard_arrow_down,
//                             color: AppColors.greyColor(context)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (state.hasError)
//             Padding(
//               padding: const EdgeInsets.only(top: 4, left: 6),
//               child: Text(
//                 state.errorText!,
//                 style: AppTextStyle.errorTextStyle(context),
//               ),
//             ),
//         ],
//       );
//     },
//   );
//
//   final String label;
//   final String hint;
//   final bool isRequired;
//   final bool isLabel;
//   final bool isSearch;
//   final bool isNeedAll;
//   final T? allItem;
//   final List<T> itemList;
//   final void Function(T?) onChanged;
// }
//
// class _DropdownBottomSheet<T> extends StatefulWidget {
//   final List<T> items;
//   final T? selectedValue;
//   final String hint;
//   final bool isSearch;
//   final String Function(T) itemLabel;
//   final ValueChanged<T?> onChanged;
//
//   const _DropdownBottomSheet({
//     required this.items,
//     required this.selectedValue,
//     required this.hint,
//     required this.isSearch,
//     required this.itemLabel,
//     required this.onChanged,
//   });
//
//   @override
//   State<_DropdownBottomSheet<T>> createState() =>
//       _DropdownBottomSheetState<T>();
// }
//
// class _DropdownBottomSheetState<T> extends State<_DropdownBottomSheet<T>> {
//   late List<T> filteredItems;
//   late TextEditingController searchController;
//
//   @override
//   void initState() {
//     super.initState();
//     filteredItems = widget.items;
//     searchController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
//
//   void _filterItems(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredItems = widget.items;
//       } else {
//         filteredItems = widget.items
//             .where((item) =>
//             widget.itemLabel(item).toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.9,
//       builder: (context, scrollController) {
//         return SafeArea(
//           child: Container(
//             constraints: const BoxConstraints(minHeight: 200),
//             decoration: BoxDecoration(
//               color: AppColors.bottomNavBg(context),
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Select',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primaryColor(context))),
//                       IconButton(
//                           icon: Icon(Icons.close, color: AppColors.grey),
//                           onPressed: () => Navigator.pop(context)),
//                     ],
//                   ),
//                 ),
//
//                 // Optional search
//                 if (widget.isSearch)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
//                     child: TextField(
//                       controller: searchController,
//                       autofocus: false,
//                       decoration: InputDecoration(
//                         hintText: 'Search ${widget.hint}',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
//                           borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.5), width: 0.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
//                           borderSide: BorderSide(color: AppColors.primaryColor(context), width: 0.5),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
//                           borderSide:  BorderSide(color: AppColors.errorColor(context), width: 0.5),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
//                           borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.5), width: 0.5),
//                         ),
//
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 0, horizontal: 16),
//                       ),
//                       onChanged: _filterItems,
//                     ),
//                   ),
//
//                 // Item list
//                 Expanded(
//                   child: filteredItems.isEmpty
//                       ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.search_off,
//                               size: 64, color: AppColors.greyColor(context)),
//                           const SizedBox(height: 16),
//                           Text('No items found',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   color: AppColors.greyColor(context))),
//                         ],
//                       ),
//                     ),
//                   )
//                       : ListView.builder(
//                     controller: scrollController,
//                     padding: const EdgeInsets.all(8),
//                     itemCount: filteredItems.length,
//                     itemBuilder: (context, index) {
//                       final item = filteredItems[index];
//                       final isSelected = item == widget.selectedValue;
//
//                       return Container(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 4, horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppColors.primaryColor(context)
//                               .withValues(alpha: 0.1)
//                               : AppColors.bottomNavBg(context),
//                           borderRadius:
//                           BorderRadius.circular(AppSizes.radius),
//                           border: Border.all(
//                             color: AppColors.greyColor(context)
//                                 .withValues(alpha: 0.5),
//                             width: 0.5,
//                           ),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 8),
//                         child: InkWell(
//                           onTap: () => widget.onChanged(item),
//                           child: Row(
//                             children: [
//                               if (isSelected)
//                                 Icon(Icons.check_circle,
//                                     color: AppColors.primaryColor(context)),
//                               if (isSelected) const SizedBox(width: 10),
//                               Text(widget.itemLabel(item),
//                                   style: AppTextStyle.body(context).copyWith(
//                                     fontWeight: FontWeight.w500
//                                   )),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import '../configs/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io' show Platform;

class AppDropdown<T> extends FormField<T> {
  AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.isLabel = false,
    this.isSearch = false,
    this.isNeedAll = false,
    this.allItem,
    T? value,
    required this.itemList,
    required this.onChanged,
     this.onClear,
    String Function(T)? itemLabel,
    super.validator,
  }) : super(
    initialValue: value,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<T> state) {
      final context = state.context;

      // Use local variable for itemLabel
      final labelFn = itemLabel ?? (T item) => item.toString();

      // Prepare items
      final List<T> items = [...itemList];
      if (isNeedAll && allItem != null) {
        items.insert(0, allItem as T);
      }

      final displayText =
      state.value != null ? labelFn(state.value as T) : '';

      void showDropdown() {
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 50), () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            builder: (sheetContext) {
              return _DropdownBottomSheet<T>(
                items: items,
                selectedValue: state.value,
                hint: hint,
                isSearch: isSearch,
                itemLabel: labelFn,
                onChanged: (value) {
                  state.didChange(value);
                  onChanged(value);
                  Navigator.pop(sheetContext);
                },
              );
            },
          );
        });
      }

      void handleClear() {
        state.didChange(null);

        if (onClear != null) {
          onClear!(null);
        }

        onChanged(null);
      }


      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLabel) ...[
            Row(
              children: [
                Text(label,
                    style: AppTextStyle.labelDropdownTextStyle(context)),
                if (isRequired)
                  const Text('*', style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 4),
          ],
          SizedBox(
            height: 35,
            child: InkWell(
              onTap: showDropdown,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red
                        : AppColors.greyColor(context),
                    width: 1,
                  ),
                  borderRadius:
                  BorderRadius.circular(AppSizes.radius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText.isEmpty ? hint : displayText,
                        style: TextStyle(
                          color: displayText.isEmpty
                              ? AppColors.greyColor(context)
                              : AppColors.text(context),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (displayText.isNotEmpty)
                          InkWell(
                            onTap: handleClear,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.close,
                                  size: 18,
                                  color: AppColors.greyColor(context)),
                            ),
                          ),
                        Icon(Icons.keyboard_arrow_down,
                            color: AppColors.greyColor(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6),
              child: Text(
                state.errorText!,
                style: AppTextStyle.errorTextStyle(context),
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
  final void Function(T?)? onClear;
}

class _DropdownBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final String hint;
  final bool isSearch;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownBottomSheet({
    required this.items,
    required this.selectedValue,
    required this.hint,
    required this.isSearch,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  State<_DropdownBottomSheet<T>> createState() =>
      _DropdownBottomSheetState<T>();
}

class _DropdownBottomSheetState<T> extends State<_DropdownBottomSheet<T>> {
  late List<T> filteredItems;
  late TextEditingController searchController;

  // Speech-to-text fields
  SpeechToText? _speech;
  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController = TextEditingController();
    // Initialize speech in a post-frame (or directly) — do not block UI.
    if (widget.isSearch) {
      _initSpeech();
    }
  }

  Future<void> _initSpeech() async {
    // Attempt to initialize SpeechToText where supported. The speech_to_text plugin
    // may not support every platform (Windows support varies). We guard and
    // fail gracefully if initialization is not possible.
    try {
      _speech = SpeechToText();
      // Some platforms (web) cannot import dart:io Platform; the package
      // will fail accordingly. This try/catch ensures app keeps functioning.
      final available = await _speech!.initialize(
        onStatus: (status) {
          // update UI when listening status changes from the plugin side
          if (mounted) {
            setState(() {
              // plugin has its own state; keep our _isListening in sync if needed
            });
          }
        },
        onError: (error) {
          // ignore, handled by available flag; optionally log
        },
      );
      // On some platforms initialize returns true but speech recognition may still
      // be restricted (permissions). available will reflect actual availability.
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _speechAvailable = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_speech != null) {
      if (_isListening) {
        _speech!.stop();
      }
      _speech = null;
    }
    searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where((item) => widget
            .itemLabel(item)
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable || _speech == null) {
      // Speech isn't available on this platform or initialization failed
      // Optionally show a SnackBar or tooltip. We keep behavior silent to avoid surprises.
      return;
    }

    if (_isListening) {
      await _speech!.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    // Start listening. Recognized speech will replace the search content.
    // If you prefer appending instead, modify below to append to searchController.text.
    try {
      await _speech!.listen(
        onResult: (result) {
          if (mounted) {
            final recognized = result.recognizedWords;
            // Replace the query. To APPEND instead, use:
            // final newText = '${searchController.text} $recognized';
            searchController.text = recognized;
            searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: searchController.text.length));
            _filterItems(searchController.text);
          }
        },
        // on-device recognition when supported can be enabled via parameters
        localeId: null,
        // optional: set listenFor, pauseFor, partialResults, etc.
      );
      if (mounted) setState(() => _isListening = true);
    } catch (e) {
      // Starting listening failed — mark unavailable to avoid retries
      if (mounted) {
        setState(() {
        _isListening = false;
        _speechAvailable = false;
      });
      }
    }
  }

  bool get _platformLikelySupportsSpeech {
    // The speech_to_text plugin supports Android, iOS, macOS. Windows support may
    // not be available or may be experimental. We attempt initialization, but we
    // can also short-circuit here to disable mic on unsupported platforms.
    try {
      if (kIsWeb) return false;
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
      // Windows — may or may not be supported depending on plugin version / build.
      // Keep it allowed to attempt initialization; the plugin will fail gracefully.
      if (Platform.isWindows) return true;
    } catch (e) {
      // In environments where Platform isn't available, assume no speech support.
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(minHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor(context))),
                      IconButton(
                          icon: Icon(Icons.close, color: AppColors.grey),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),

                // Optional search with speech button
                if (widget.isSearch)
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.hint}',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Clear button when there is text
                              if (searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    _filterItems('');
                                    // rebuild to hide clear icon
                                    setState(() {});
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.clear),
                                  ),
                                ),
                              // Mic button (enabled only when plugin initialized & available)
                              GestureDetector(
                                onTap: (_platformLikelySupportsSpeech &&
                                    _speechAvailable)
                                    ? _toggleListening
                                    : null,
                                child: Tooltip(
                                  message: _platformLikelySupportsSpeech
                                      ? (_speechAvailable
                                      ? (_isListening
                                      ? 'Stop listening'
                                      : 'Start voice search')
                                      : 'Microphone not available (grant permission or platform unsupported)')
                                      : 'Voice search not supported on this platform',
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      color: (_platformLikelySupportsSpeech &&
                                          _speechAvailable)
                                          ? AppColors.primaryColor(context)
                                          : AppColors.greyColor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                          borderSide: BorderSide(
                              color: AppColors.greyColor(context).withValues(
                                  alpha: 0.5),
                              width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor(context), width: 0.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                          borderSide: BorderSide(
                              color: AppColors.errorColor(context), width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                          borderSide: BorderSide(
                              color: AppColors.greyColor(context).withValues(
                                  alpha: 0.5),
                              width: 0.5),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      onChanged: (v) {
                        _filterItems(v);
                        // Keep UI updated for clear button
                        setState(() {});
                      },
                    ),
                  ),

                // Item list
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64,
                              color: AppColors.greyColor(context)),
                          const SizedBox(height: 16),
                          Text('No items found',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.greyColor(context))),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = item == widget.selectedValue;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor(context)
                              .withValues(alpha: 0.1)
                              : AppColors.bottomNavBg(context),
                          borderRadius:
                          BorderRadius.circular(AppSizes.radius),
                          border: Border.all(
                            color: AppColors.greyColor(context)
                                .withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: InkWell(
                          onTap: () => widget.onChanged(item),
                          child: Row(
                            children: [
                              if (isSelected)
                                Icon(Icons.check_circle,
                                    color: AppColors.primaryColor(context)),
                              if (isSelected) const SizedBox(width: 10),
                              Text(widget.itemLabel(item),
                                  style: AppTextStyle.body(context).copyWith(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}