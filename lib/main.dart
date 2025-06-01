import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/core/theme/app_theme.dart';
import 'package:app_reporte_iestp_sullana/features/auth/data/datasources/supabase_auth_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/datasources/supabase_users_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/settings/domain/repositories/users_repository_impl.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
  await ScreenUtil.ensureScreenSize();

  final authDataSource = SupabaseAuthDataSourceImpl();
  final authRepository = AuthRepositoryImpl(authDataSource);
  final authProvider = AuthProvider(authRepository);

  await authProvider.initializeUser();

  runApp(
    MultiProvider(
      providers: [
        // SOLO una instancia de AuthProvider
        ChangeNotifierProvider.value(value: authProvider),

        // UserProvider que depende de AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            UsersRepositoryImpl(
              SupabaseUsersDataSourceImpl(Supabase.instance.client),
            ),
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previousUserProvider) =>
              previousUserProvider!..updateAuthProvider(authProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => FutureBuilder<GoRouter>(
        future: AppRouter.getRouter(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }
          return MaterialApp.router(
            routerConfig: snapshot.data,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
          );
        },
      ),
    );
  }
}
