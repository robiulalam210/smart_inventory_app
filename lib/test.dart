// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
//
// class SearchAndAddDemo extends StatefulWidget {
//   const SearchAndAddDemo({super.key});
//
//   @override
//   State<SearchAndAddDemo> createState() => _SearchAndAddDemoState();
// }
//
// class _SearchAndAddDemoState extends State<SearchAndAddDemo> {
//   final TextEditingController _controller = TextEditingController();
//
//   final List<String> _items = ['Apple', 'Banana', 'Orange', 'Mango'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Search & Add Demo")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: TypeAheadField<String>(
//           controller: _controller,
//           suggestionsCallback: (pattern) {
//             if (pattern.isEmpty) return [];
//
//             final results = _items
//                 .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
//                 .toList();
//
//             // if no match → return add option
//             if (results.isEmpty) {
//               return ['➕ Add "$pattern"'];
//             }
//             return results;
//           },
//           itemBuilder: (context, suggestion) {
//             return ListTile(title: Text(suggestion));
//           },
//           onSelected: (suggestion) {
//             if (suggestion.startsWith("➕ Add")) {
//               final newItem = suggestion.replaceAll(RegExp(r'➕ Add "|"$'), '');
//               setState(() => _items.add(newItem));
//               _controller.text = newItem;
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Added "$newItem"')),
//               );
//             } else {
//               _controller.text = suggestion;
//             }
//           },
//           builder: (context, controller, focusNode) {
//             return TextField(
//               controller: controller,
//               focusNode: focusNode,
//               decoration: InputDecoration(
//                 hintText: "Search or Add Fruit",
//                 suffixIcon: controller.text.isNotEmpty
//                     ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () => controller.clear(),
//                 )
//                     : const Icon(Icons.search),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
