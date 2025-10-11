// Helper to convert HTML to plain text
import 'dart:io';
import '../../data/model/single_report_model.dart';
import '/core/core.dart';

import 'package:path_provider/path_provider.dart';

String htmlToPlainText(String html) {
  final document = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  return html.replaceAll(document, '').trim();
}

// Helper to convert Uint8List bytes to temporary File
Future<File> bytesToFile(Uint8List bytes, String filename) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$filename');
  await file.writeAsBytes(bytes);
  return file;
}
class BuildPathologyTable extends StatefulWidget {
   const BuildPathologyTable({super.key,required this.details});
final  List<Detail> details;
  @override
  State<BuildPathologyTable> createState() => _BuildPathologyTableState();
}

class _BuildPathologyTableState extends State<BuildPathologyTable> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius),
          topRight: Radius.circular(AppSizes.radius)),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(2),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radius),
                    topRight: Radius.circular(AppSizes.radius))),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Test Parameter',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Result',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child:
                Text('Unit', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Normal Value',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          ...widget.details.map((item) {
            final showOptions = item.parameter?.showOptions == 1;

            final rawOptions = item.parameter?.options ??
                []; // might be a List<String> or malformed

// Flatten and split if needed
            final options = rawOptions
                .expand((e) =>
            e.contains(',') ? e.split(',') : [e]) // split comma if any
                .map((e) => e.trim()) // trim spaces
                .where((e) => e.isNotEmpty) // remove empty
                .toList();

// Determine the selected dropdown value
            final dropdownValue = (item.result != null &&
                options.any(
                        (op) => op.toLowerCase() == item.result!.toLowerCase()))
                ? options.firstWhere(
                    (op) => op.toLowerCase() == item.result!.toLowerCase())
                : (options.isNotEmpty ? options.first : null);

            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(item.parameterName ?? ''),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: showOptions
                      ? DropdownButtonFormField<String>(
                    value: dropdownValue,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                    ),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.blue),
                    dropdownColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        item.result = val;
                      });
                    },
                    items: options
                        .map((op) => DropdownMenuItem<String>(
                      value: op,
                      child: Text(
                        op,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                        .toList(),
                    validator: (val) => val == null || val.isEmpty
                        ? "Please select a value"
                        : null,
                  )
                      : TextFormField(
                    controller:
                    TextEditingController(text: item.result ?? ""),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (val) {
                      item.result = val;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(item.parameter?.parameterUnit ?? ''),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(item.parameter?.referenceValue ?? ''),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}



List<String> parseOptions(dynamic rawOptions) {
  if (rawOptions == null) return [];

  // If already a List<String>, just return it
  if (rawOptions is List<String>) {
    return rawOptions
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // If it's a String, split by line breaks or commas
  if (rawOptions is String) {
    return rawOptions
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Fallback: convert to string
  return [rawOptions.toString()];
}