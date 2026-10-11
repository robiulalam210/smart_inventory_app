/// Payroll মডেল — server: /api/payroll/… (টাকার মান string হিসেবে আসে)
double payNum(dynamic v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

class SalarySlip {
  final int id;
  final String month; // yyyy-MM-dd (মাসের ১ তারিখ)
  final String status; // paid | unpaid
  final int staffId;
  final String staffName;
  final String designation;
  final String employeeId;
  final double basic, commission, bonus, otherAddition, advanceDeduction, otherDeduction, net;
  final String? paidDate;
  final int? accountId;
  final String accountName;
  final String paymentMethod;
  final String note;
  final double openAdvance;

  const SalarySlip({
    required this.id,
    required this.month,
    required this.status,
    required this.staffId,
    required this.staffName,
    required this.designation,
    required this.employeeId,
    required this.basic,
    required this.commission,
    required this.bonus,
    required this.otherAddition,
    required this.advanceDeduction,
    required this.otherDeduction,
    required this.net,
    required this.paidDate,
    required this.accountId,
    required this.accountName,
    required this.paymentMethod,
    required this.note,
    required this.openAdvance,
  });

  bool get isPaid => status == 'paid';
  double get additions => commission + bonus + otherAddition;
  double get deductions => advanceDeduction + otherDeduction;
  double get gross => basic + additions;

  factory SalarySlip.fromJson(Map<String, dynamic> j) => SalarySlip(
        id: (j['id'] as num).toInt(),
        month: '${j['month'] ?? ''}',
        status: '${j['status'] ?? 'unpaid'}',
        staffId: (j['staff_id'] as num?)?.toInt() ?? 0,
        staffName: '${j['staff_name'] ?? ''}',
        designation: '${j['designation'] ?? ''}',
        employeeId: '${j['employee_id'] ?? ''}',
        basic: payNum(j['basic']),
        commission: payNum(j['commission']),
        bonus: payNum(j['bonus']),
        otherAddition: payNum(j['other_addition']),
        advanceDeduction: payNum(j['advance_deduction']),
        otherDeduction: payNum(j['other_deduction']),
        net: payNum(j['net']),
        paidDate: j['paid_date']?.toString(),
        accountId: (j['account_id'] as num?)?.toInt(),
        accountName: '${j['account_name'] ?? ''}',
        paymentMethod: '${j['payment_method'] ?? ''}',
        note: '${j['note'] ?? ''}',
        openAdvance: payNum(j['open_advance']),
      );
}

class SlipSummary {
  final int slips, paidCount, unpaidCount;
  final double totalNet, paid, unpaid;
  const SlipSummary({
    this.slips = 0,
    this.paidCount = 0,
    this.unpaidCount = 0,
    this.totalNet = 0,
    this.paid = 0,
    this.unpaid = 0,
  });

  factory SlipSummary.fromJson(Map<String, dynamic> j) => SlipSummary(
        slips: (j['slips'] as num?)?.toInt() ?? 0,
        paidCount: (j['paid_count'] as num?)?.toInt() ?? 0,
        unpaidCount: (j['unpaid_count'] as num?)?.toInt() ?? 0,
        totalNet: payNum(j['total_net']),
        paid: payNum(j['paid']),
        unpaid: payNum(j['unpaid']),
      );
}

class SlipPage {
  final List<SalarySlip> items;
  final int count;
  final int totalPages;
  final SlipSummary summary;
  const SlipPage(this.items, this.count, this.totalPages, this.summary);
}

class SalaryAdvance {
  final int id;
  final int staffId;
  final String staffName;
  final double amount, deducted, remaining;
  final String date, accountName, paymentMethod, note;

  const SalaryAdvance({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.amount,
    required this.deducted,
    required this.remaining,
    required this.date,
    required this.accountName,
    required this.paymentMethod,
    required this.note,
  });

  factory SalaryAdvance.fromJson(Map<String, dynamic> j) => SalaryAdvance(
        id: (j['id'] as num).toInt(),
        staffId: (j['staff_id'] as num?)?.toInt() ?? 0,
        staffName: '${j['staff_name'] ?? ''}',
        amount: payNum(j['amount']),
        deducted: payNum(j['deducted']),
        remaining: payNum(j['remaining']),
        date: '${j['date'] ?? ''}',
        accountName: '${j['account_name'] ?? ''}',
        paymentMethod: '${j['payment_method'] ?? ''}',
        note: '${j['note'] ?? ''}',
      );
}

class AdvanceData {
  final List<SalaryAdvance> items;
  final Map<int, double> balances; // staffId → এখনো বাকি অগ্রিম
  const AdvanceData(this.items, this.balances);
}

class StaffOption {
  final int id;
  final String name, designation;
  final double salary;
  const StaffOption(this.id, this.name, this.designation, this.salary);

  factory StaffOption.fromJson(Map<String, dynamic> j) => StaffOption(
        (j['id'] as num).toInt(),
        '${j['name'] ?? ''}',
        '${j['designation'] ?? ''}',
        payNum(j['salary']),
      );
}

class AccountOption {
  final int id;
  final String name;
  final double balance;
  const AccountOption(this.id, this.name, this.balance);
}

class ReportRow {
  final int staffId;
  final String staffName, designation;
  final int months;
  final double basic, additions, deductions, net, paid, unpaid;
  const ReportRow({
    required this.staffId,
    required this.staffName,
    required this.designation,
    required this.months,
    required this.basic,
    required this.additions,
    required this.deductions,
    required this.net,
    required this.paid,
    required this.unpaid,
  });

  factory ReportRow.fromJson(Map<String, dynamic> j) => ReportRow(
        staffId: (j['staff_id'] as num?)?.toInt() ?? 0,
        staffName: '${j['staff_name'] ?? ''}',
        designation: '${j['designation'] ?? ''}',
        months: (j['months'] as num?)?.toInt() ?? 0,
        basic: payNum(j['basic']),
        additions: payNum(j['additions']),
        deductions: payNum(j['deductions']),
        net: payNum(j['net']),
        paid: payNum(j['paid']),
        unpaid: payNum(j['unpaid']),
      );
}

class PayrollReport {
  final List<ReportRow> rows;
  final double basic, additions, deductions, net, paid, unpaid, advancesGiven;
  final int staff;
  const PayrollReport(this.rows,
      {this.basic = 0,
      this.additions = 0,
      this.deductions = 0,
      this.net = 0,
      this.paid = 0,
      this.unpaid = 0,
      this.advancesGiven = 0,
      this.staff = 0});
}
