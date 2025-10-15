import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../core/core.dart';
import '../feature/feature.dart';
import '../feature/products/brand/presentation/bloc/brand/brand_bloc.dart';
import '../feature/products/categories/presentation/bloc/categories/categories_bloc.dart';
import '../feature/products/groups/presentation/bloc/groups/groups_bloc.dart';
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
            create: (context) =>
                SplashBloc(authBloc: context.read<AuthBloc>())),
        BlocProvider(create: (context) => DoctorBloc()),

        BlocProvider(create: (context) => TestBloc()),
        BlocProvider(create: (context) => TestCategoriesBloc()),
        BlocProvider(create: (context) => InventoryBloc()),

        BlocProvider(create: (context) => SummaryBloc(SummeryRepoDB())),

        BlocProvider(
            create: (context) => SyncBloc(
                syncRepo: SetupAllSyncRepo(dbHelper),
                unSyncRepo: UnSyncRepo())),

        BlocProvider(create: (context) => PrintLayoutBloc(PrintLayoutRepoDb())),



        BlocProvider(
          create: (_) => BrandBloc(),
        ),
        BlocProvider(
          create: (_) => UnitBloc(),
        ),
        BlocProvider(
          create: (_) => CategoriesBloc(),
        ),



        BlocProvider(
          create: (_) => GroupsBloc(),
        ),
        BlocProvider(
          create: (_) => SourceBloc(),
        ),
        // BlocProvider(
        //   create: (_) => ProductsBloc(),
        // ),
        // BlocProvider(
        //   create: (_) => ProductStockBloc(),
        // ),
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
