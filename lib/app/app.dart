import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../feature/common/presentation/cubit/theme_cubit.dart';
import '../feature/splash/presentation/pages/mobile_splash_screen.dart';
import '/feature/account_transfer/presentation/bloc/account_transfer/account_transfer_bloc.dart';
import '/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import '/feature/expense/expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '/feature/expense/presentation/bloc/expense_list/expense_bloc.dart';
import '/feature/money_receipt/presentation/bloc/money_receipt/money_receipt_bloc.dart';
import '/feature/purchase/presentation/bloc/create_purchase/create_purchase_bloc.dart';
import '/feature/purchase/presentation/bloc/purchase_bloc.dart';
import '/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart';
import '/feature/report/presentation/bloc/sales_report_bloc/sales_report_bloc.dart';
import '/feature/return/purchase_return/presentation/bloc/purchase_return/purchase_return_bloc.dart';
import '/feature/sales/presentation/bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';
import '/feature/sales/presentation/bloc/possale/possale_bloc.dart';
import '/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import '/feature/users_list/presentation/bloc/users/user_bloc.dart';
import '../core/core.dart';
import '../feature/accounts/presentation/bloc/account/account_bloc.dart';
import '../feature/expense/expense_sub_head/presentation/bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../feature/feature.dart';
import '../feature/products/brand/presentation/bloc/brand/brand_bloc.dart';
import '../feature/products/categories/presentation/bloc/categories/categories_bloc.dart';
import '../feature/products/groups/presentation/bloc/groups/groups_bloc.dart';
import '../feature/products/product/presentation/bloc/products/products_bloc.dart';
import '../feature/products/soruce/presentation/bloc/source/source_bloc.dart';
import '../feature/products/unit/presentation/bloc/unit/unti_bloc.dart';
import '../feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../feature/report/presentation/bloc/customer_due_advance_bloc/customer_due_advance_bloc.dart';
import '../feature/report/presentation/bloc/customer_ledger_bloc/customer_ledger_bloc.dart';
import '../feature/report/presentation/bloc/expense_report_bloc/expense_report_bloc.dart';
import '../feature/report/presentation/bloc/profit_loss_bloc/profit_loss_bloc.dart';
import '../feature/report/presentation/bloc/purchase_report/purchase_report_bloc.dart';
import '../feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart';
import '../feature/report/presentation/bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart';
import '../feature/report/presentation/bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart';
import '../feature/report/presentation/bloc/top_products_bloc/top_products_bloc.dart';
import '../feature/return/bad_stock/bad_stock_list/bad_stock_list_bloc.dart';
import '../feature/return/sales_return/presentation/sales_return_bloc/sales_return_bloc.dart';
import '../feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../feature/supplier/presentation/bloc/supplier_payment/supplier_payment_bloc.dart';
import '../feature/transactions/presentation/bloc/transactions/transaction_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityBloc()),
        BlocProvider(
          create: (context) => DashboardBloc(), // ✅ Pass the instance
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            connectivityBloc: context.read<ConnectivityBloc>(),
            authService: AuthService(),
          ),
        ),
        BlocProvider(create: (context) => SplashBloc()),

        BlocProvider(create: (context) => PrintLayoutBloc(PrintLayoutRepoDb())),

        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => BrandBloc()),
        BlocProvider(create: (_) => UnitBloc()),
        BlocProvider(create: (_) => CategoriesBloc()),

        BlocProvider(create: (_) => GroupsBloc()),
        BlocProvider(create: (_) => SourceBloc()),
        BlocProvider(create: (_) => ProductsBloc()),
        BlocProvider(create: (_) => AccountBloc()),
        BlocProvider(create: (_) => CustomerBloc()),
        BlocProvider(create: (_) => ExpenseBloc()),
        BlocProvider(create: (_) => ExpenseHeadBloc()),
        BlocProvider(create: (_) => ExpenseSubHeadBloc()),
        BlocProvider<ThemeCubit>(
          create: (_) {
            final cubit = ThemeCubit();
            // async load saved prefs (do not await here)
            cubit.loadFromStorage();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => PosSaleBloc()),
        BlocProvider(create: (_) => CreatePosSaleBloc()),
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => SupplierListBloc()),
        BlocProvider(create: (_) => SupplierPaymentBloc()),
        BlocProvider(create: (_) => SupplierInvoiceBloc()),
        BlocProvider(create: (_) => CreatePurchaseBloc()),
        BlocProvider(create: (_) => PurchaseBloc()),
        BlocProvider(create: (_) => MoneyReceiptBloc()),
        BlocProvider(create: (_) => SalesReportBloc()),
        BlocProvider(create: (_) => PurchaseReportBloc()),
        BlocProvider(create: (_) => ProfitLossBloc()),
        BlocProvider(create: (_) => TopProductsBloc()),
        BlocProvider(create: (_) => LowStockBloc()),
        BlocProvider(create: (_) => StockReportBloc()),
        BlocProvider(create: (_) => CustomerLedgerBloc()),
        BlocProvider(create: (_) => CustomerLedgerBloc()),
        BlocProvider(create: (_) => CustomerDueAdvanceBloc()),
        BlocProvider(create: (_) => SupplierDueAdvanceBloc()),
        BlocProvider(create: (_) => SupplierLedgerBloc()),
        BlocProvider(create: (_) => ExpenseReportBloc()),

        BlocProvider(create: (_) => SalesReturnBloc()),
        BlocProvider(create: (_) => PurchaseReturnBloc()),
        BlocProvider(create: (_) => BadStockListBloc()),
        BlocProvider(create: (_) => TransactionBloc()),
        BlocProvider(create: (_) => AccountTransferBloc()),
      ],

      child: BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (previous, current) => previous.themeMode != current.themeMode,
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            /// ----------- 🌍 Localization Setup -----------
            localizationsDelegates: [
              ...context.localizationDelegates,     // EasyLocalization delegates
              // FlutterQuillLocalizations.delegate,   // 👈 Required for Quill
            ],
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            /// ----------- 🎨 Theming Setup -----------
            theme: AppTheme.light(context),
            darkTheme: AppTheme.dark(context),
            themeMode: themeState.themeMode,
            title: AppConstants.appName,
            home: Responsive.isMobile(context)
                ? MobileSplashScreen()
                : SplashScreen(),
          );
        },
      ),

      // child: Center(
      //   child: MaterialApp(
      //     localizationsDelegates: [
      //       // quill.FlutterQuillLocalizations.delegate, // <-- add this
      //       GlobalMaterialLocalizations.delegate,
      //       GlobalWidgetsLocalizations.delegate,
      //       GlobalCupertinoLocalizations.delegate,
      //     ],
      //     supportedLocales: const [
      //       Locale('en', ''), // English
      //       // Add other locales if needed
      //     ],
      //     title: AppConstants.appName,
      //     debugShowCheckedModeBanner: false,
      //     theme: AppTheme.light(context),
      //
      //   ),
      // ),
    );
  }
}
