import '../../../../../core/widgets/web_ui.dart';
//
// import '../../../../../core/configs/configs.dart';
// import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
//
// class SampleCollectionScreen extends StatefulWidget {
//   const SampleCollectionScreen({super.key});
//
//   @override
//   State<SampleCollectionScreen> createState() => _TransactionScreenState();
// }
//
// class _TransactionScreenState extends State<SampleCollectionScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final isBigScreen =
//         Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
//     return Container(
//       color: W.canvas(context),
//       child: SafeArea(
//         child: ResponsiveRow(
//           spacing: 0,
//           runSpacing: 0,
//           children: [
//             if (isBigScreen) _buildSidebar(),
//             _buildContentArea(isBigScreen),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSidebar() {
//     return ResponsiveCol(
//       xs: 0,
//       sm: 1,
//       md: 1,
//       lg: 2,
//       xl: 2,
//       child: Container(
//         decoration: BoxDecoration(color: W.surface(context)),
//         child: const Sidebar(),
//       ),
//     );
//   }
//
//   Widget _buildContentArea(bool isBigScreen) {
//     return ResponsiveCol(
//       xs: 12,
//       sm: 12,
//       md: 12,
//       lg: 10,
//       xl: 10,
//       child: Container(color: W.canvas(context), ),
//     );
//   }
// }
//
