import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/web_ui.dart';
import '../../../../desktop/widgets/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';
import '../widgets/sale_list_view.dart';

/// Sale List (ডেস্কটপ) — ওয়েবের Sale List পেজের মতো। ফিল্টার, মোট হিসাব, টেবিল ও
/// পাতা বদলের সব কাজ [SaleListView] এ; এই স্ক্রিন শুধু সাইডবারসহ কাঠামো দেয়।
class PosSaleScreen extends StatefulWidget {
  const PosSaleScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<PosSaleScreen> {
  final GlobalKey<SaleListViewState> _list = GlobalKey<SaleListViewState>();

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: W.canvas(context),
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => ResponsiveCol(
        xs: 0,
        sm: 1,
        md: 1,
        lg: 2,
        xl: 2,
        child: Container(color: W.surface(context), child: const Sidebar()),
      );

  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async => _list.currentState?.refresh(),
        color: AppColors.primaryColor(context),
        child: Container(
          color: W.canvas(context),
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<CreatePosSaleBloc, CreatePosSaleState>(
            listener: (context, state) {
              if (state is CreatePosSaleLoading) {
                appLoader(context, "Creating POS Sale...");
              } else if (state is CreatePosSaleSuccess) {
                Navigator.pop(context);
                _list.currentState?.refresh();
              } else if (state is CreatePosSaleFailed) {
                if (context.mounted) {
                  Navigator.pop(context);
                  appAlertDialog(
                    context,
                    state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Dismiss"),
                      ),
                    ],
                  );
                }
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SaleListView(key: _list),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
