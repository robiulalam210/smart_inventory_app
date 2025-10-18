import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:smart_inventory/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import 'package:smart_inventory/feature/expense/expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import 'package:smart_inventory/feature/expense/presentation/bloc/expense_list/expense_bloc.dart';
import 'package:smart_inventory/feature/money_receipt/presentation/bloc/money_receipt/money_receipt_bloc.dart';
import 'package:smart_inventory/feature/purchase/presentation/bloc/create_purchase/create_purchase_bloc.dart';
import 'package:smart_inventory/feature/purchase/presentation/bloc/purchase_bloc.dart';
import 'package:smart_inventory/feature/sales/presentation/bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';
import 'package:smart_inventory/feature/sales/presentation/bloc/possale/possale_bloc.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import 'package:smart_inventory/feature/users_list/presentation/bloc/users/user_bloc.dart';
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

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityBloc()),
        BlocProvider(
          create: (context) => DashboardBloc(dbHelper), // ✅ Pass the instance
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            connectivityBloc: context.read<ConnectivityBloc>(),
            authService: AuthService(),
          ),
        ),
        BlocProvider(
          create: (context) => SplashBloc(authBloc: context.read<AuthBloc>()),
        ),


        BlocProvider(
          create: (context) => SyncBloc(
            syncRepo: SetupAllSyncRepo(dbHelper),
            unSyncRepo: UnSyncRepo(),
          ),
        ),

        BlocProvider(create: (context) => PrintLayoutBloc(PrintLayoutRepoDb())),

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

        BlocProvider(create: (_) => PosSaleBloc()),
        BlocProvider(create: (_) => CreatePosSaleBloc()),
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => SupplierListBloc()),
        BlocProvider(create: (_) => CreatePurchaseBloc()),
        BlocProvider(create: (_) => PurchaseBloc()),
        BlocProvider(create: (_) => MoneyReceiptBloc()),
      ],
      child: Center(
        child: MaterialApp(
          localizationsDelegates: [
            quill.FlutterQuillLocalizations.delegate, // <-- add this
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            // Add other locales if needed
          ],
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(context),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
