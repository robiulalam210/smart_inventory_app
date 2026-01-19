import 'package:google_fonts/google_fonts.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/user_model.dart';

class UserTableCard extends StatelessWidget {
  final List<UsersListModel> users;
  final VoidCallback? onUserTap;

  const UserTableCard({
    super.key,
    required this.users,
    this.onUserTap,
  });

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return _isMobile(context)
        ? _buildMobileList(context)
        : _buildDesktopTable(context);
  }

  // =========================
  // 📱 MOBILE VIEW
  // =========================
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(AppSizes.radius),

            border: Border.all(
              color: AppColors.greyColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mobileHeader(user,context),
                const SizedBox(height: 6),
                _mobileInfo('Email', user.email,context),
                _mobileInfo('Phone', user.phone,context),
                _mobileInfo('Role', user.role,context),
                _mobileInfo('Company', user.company?.name,context),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.green),
                    onPressed: () => _showViewDialog(context, user),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mobileHeader(UsersListModel user, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Name
        Expanded(
          child: Text(
            user.fullName?.trim().isNotEmpty == true
                ? user.fullName!
                : (user.username ?? 'Unknown'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        // Status Chip
        _statusChip(_getUserStatus(user)),
      ],
    );
  }

  Widget _mobileInfo(String label, String? value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value ?? "N/A"}',
        style: AppTextStyle.body(context),
      ),
    );
  }

  // =========================
  // 💻 DESKTOP VIEW
  // =========================
  Widget _buildDesktopTable(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Scrollbar(
        controller: verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: verticalController,
          child: Scrollbar(
            controller: horizontalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: DataTable(
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 40,
                  columnSpacing: 8,
                  horizontalMargin: 12,
                  dividerThickness: 0.5,
                  headingRowHeight: 40,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.primaryColor(context),
                  ),
                  headingTextStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  dataTextStyle: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  columns: const [
                    DataColumn(label: Text('No.')),
                    DataColumn(label: Text('Full Name')),
                    DataColumn(label: Text('User Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Company')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: users.asMap().entries.map((entry) {
                    final user = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${entry.key + 1}')),
                      DataCell(Text(
                          (user.fullName ?? "N/A").trim()))
                      ,  DataCell(Text(
                          '${user.username ?? ""} ')),
                      DataCell(Text(user.email ?? 'N/A')),
                      DataCell(Text(user.role ?? 'N/A')),
                      DataCell(Text(user.phone ?? 'N/A')),
                      DataCell(Text(user.company?.name ?? 'N/A')),
                      DataCell(_statusChip(_getUserStatus(user))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility,
                              size: 18, color: Colors.green),
                          onPressed: () =>
                              _showViewDialog(context, user),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // 🔹 COMMON WIDGETS
  // =========================
  bool _getUserStatus(UsersListModel user) {
    return user.isActive ?? false;
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // 🧾 VIEW DIALOG (RESPONSIVE)
  // =========================
  void _showViewDialog(BuildContext context, UsersListModel user) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            color: AppColors.bottomNavBg(context),
            width: MediaQuery.of(context).size.width < 768
                ? double.infinity
                : AppSizes.width(context) * 0.4,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Details',
                      style: AppTextStyle.cardLevelHead(context)),
                  const SizedBox(height: 16),
                  _detailRow('Full Name',
                      '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim(),context),
                  _detailRow('Username', user.username,context),
                  _detailRow('Email', user.email,context),
                  _detailRow('Role', user.role,context),
                  _detailRow('Phone', user.phone,context),
                  _detailRow('Company', user.company?.name,context),
                  _detailRow('Status',
                      _getUserStatus(user) ? 'Active' : 'Inactive',context),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String? value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                 TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: AppColors.text(context))),
          ),
          Expanded(
            child: Text(value ?? 'N/A',
                style:  TextStyle(fontSize: 12,color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🚫 EMPTY STATE
  // =========================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('No Users Found',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
