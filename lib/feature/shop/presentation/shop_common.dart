import 'package:intl/intl.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

/// অর্ডারের status → (লেখা, ব্যাজের রং) — ওয়েবের .pill.st-* এর মতোই:
/// pending লাল-wash, confirmed নীল, delivered সবুজ, cancelled ধূসর + কাটা দাগ
(String, WTone) orderStatusStyle(String status) {
  switch (status) {
    case 'pending':
      return ('Pending', WTone.red);
    case 'confirmed':
      return ('Confirmed', WTone.blue);
    case 'delivered':
      return ('Delivered', WTone.green);
    case 'cancelled':
      return ('Cancelled', WTone.muted);
    default:
      return (status.isEmpty ? '—' : status[0].toUpperCase() + status.substring(1), WTone.neutral);
  }
}

String orderWhen(DateTime? d) => d == null ? '—' : DateFormat('d MMM yyyy, h:mm a').format(d);
