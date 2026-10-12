import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

/// Purchase এর পণ্য-সারিতে ব্যাচ নম্বর ও মেয়াদ (optional) — মুদির দোকানের জন্য।
/// [row] সারির Map; এখানে লেখা মান `batch_no` ও `expiry_date` (yyyy-MM-dd) নামে Map এ বসে,
/// আর purchase সেভের সময় payload এ যায়। খালি রাখলে কিছু পাঠানো হয় না।
class BatchExpiryFields extends StatefulWidget {
  final Map<String, dynamic> row;
  const BatchExpiryFields({super.key, required this.row});

  @override
  State<BatchExpiryFields> createState() => _BatchExpiryFieldsState();
}

class _BatchExpiryFieldsState extends State<BatchExpiryFields> {
  late final TextEditingController _batch;

  @override
  void initState() {
    super.initState();
    _batch = TextEditingController(text: '${widget.row['batch_no'] ?? ''}');
  }

  @override
  void dispose() {
    _batch.dispose();
    super.dispose();
  }

  String? get _expiry {
    final v = widget.row['expiry_date'];
    return (v == null || '$v'.isEmpty) ? null : '$v';
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pick() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_expiry ?? '') ?? now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 15),
      helpText: 'Expiry date',
    );
    if (picked != null && mounted) setState(() => widget.row['expiry_date'] = _ymd(picked));
  }

  void _quick(int days) {
    final d = DateTime.now().add(Duration(days: days));
    setState(() => widget.row['expiry_date'] = _ymd(d));
  }

  @override
  Widget build(BuildContext context) {
    final exp = _expiry;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 170,
            child: TextField(
              controller: _batch,
              onChanged: (v) => widget.row['batch_no'] = v.trim(),
              decoration: InputDecoration(
                labelText: 'Batch no (optional)',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.event_outlined, size: 16),
            label: Text(exp == null ? 'Expiry date' : 'Expires $exp'),
          ),
          for (final q in const [(30, '+30d'), (90, '+90d'), (180, '+6m'), (365, '+1y')])
            ActionChip(
              label: Text(q.$2, style: const TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
              onPressed: () => _quick(q.$1),
            ),
          if (exp != null)
            IconButton(
              tooltip: 'Clear expiry',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close_rounded, size: 18, color: W.muted(context)),
              onPressed: () => setState(() => widget.row.remove('expiry_date')),
            ),
        ],
      ),
    );
  }
}
