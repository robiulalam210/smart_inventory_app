import '../feature/sales/presentation/pages/sales_list_screen.dart';
import '/feature/transactions/presentation/bloc/refund/refund_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../core/core.dart';
import '../feature/feature.dart';


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
            create: (context) =>
                SplashBloc(authBloc: context.read<AuthBloc>())),
        BlocProvider(create: (context) => DoctorBloc()),
        BlocProvider(create: (context) => LabBillingBloc()),
        BlocProvider(create: (context) => TransactionBloc()),

        BlocProvider(create: (context) => DueCollectionBloc()),
        BlocProvider(
            create: (context) => InvoiceUnSyncBloc(
                  repository: LabBillingRepository(),
                  connectivityBloc: context.read<ConnectivityBloc>(),
                )),
        BlocProvider(create: (context) => PaymentBloc()),
        BlocProvider(create: (context) => TestBloc()),
        BlocProvider(create: (context) => TestCategoriesBloc()),
        BlocProvider(create: (context) => InventoryBloc()),

        BlocProvider(create: (context) => SummaryBloc(SummeryRepoDB())),
        BlocProvider(
            create: (context) => FinderBloc(finderRepo: FinderRepoDb())),
        BlocProvider(
            create: (context) => SyncBloc(
                syncRepo: SetupAllSyncRepo(dbHelper),
                unSyncRepo: UnSyncRepo())),

        BlocProvider(create: (context) => RefundBloc()),
        BlocProvider(create: (context) => PrintLayoutBloc(PrintLayoutRepoDb())),
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
