/// Report kit — সব report screen এই একটা import ব্যবহার করে
library;

import 'package:flutter/material.dart';

import 'report_core.dart';
import 'report_page.dart';

export 'report_core.dart';
export 'report_page.dart';
export 'report_pdf.dart';
export 'report_table.dart';

/// প্রতিটা report এর সাধারণ অংশ: সময়সীমা রাখা, বদলালে আবার আনা,
/// আর desktop / mobile এর মোড়ক।
mixin ReportPeriodMixin<T extends StatefulWidget> on State<T> {
  ReportRangePreset preset = ReportRangePreset.last30;
  DateTimeRange? range = ReportRangePreset.last30.range;

  /// কোন সময়সীমা দিয়ে শুরু (Due/Advance এ "All time")
  ReportRangePreset get defaultPreset => ReportRangePreset.last30;

  /// filter অনুযায়ী data আবার আনা
  void reload();

  void initPeriod() {
    preset = defaultPreset;
    range = defaultPreset.range;
  }

  void onPeriodChanged(ReportRangePreset p, DateTimeRange? r) {
    setState(() {
      preset = p;
      range = r;
    });
    reload();
  }

  String get periodText => ReportFmt.range(range);

  Widget wrapReport({required bool mobile, required String title, required Widget page}) => mobile
      ? ReportMobileShell(title: title, onRefresh: () async => reload(), child: page)
      : ReportDesktopShell(child: page);
}
