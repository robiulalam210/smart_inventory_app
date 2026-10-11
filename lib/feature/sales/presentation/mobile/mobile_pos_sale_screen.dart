import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/configs/configs.dart';
import 'package:meherinMart/feature/sales/presentation/widgets/sale_list_view.dart';
import 'package:meherinMart/feature/sales/presentation/mobile/create_pos_sale/mobile_create_pos_sale.dart';

/// Sales (মোবাইল) — ওয়েবের Sale List পেজের মতো। ফিল্টার, মোট হিসাব, কার্ড ও
/// পাতা বদলের সব কাজ [SaleListView] এ।
class MobilePosSaleScreen extends StatefulWidget {
  const MobilePosSaleScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<MobilePosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<MobilePosSaleScreen> {
  final GlobalKey<SaleListViewState> _list = GlobalKey<SaleListViewState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text("Sales", style: AppTextStyle.titleMedium(context)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor(context),
        foregroundColor: AppColors.onColor(AppColors.primaryColor(context)),
        onPressed: () async {
          await AppRoutes.push(context, const MobileCreatePosSale());
          // নতুন sale save করে ফিরলে তালিকা ও মোট হিসাব নতুন করে আসে
          _list.currentState?.refresh();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Sale'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _list.currentState?.refresh(),
          color: AppColors.primaryColor(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            child: SaleListView(key: _list),
          ),
        ),
      ),
    );
  }
}
