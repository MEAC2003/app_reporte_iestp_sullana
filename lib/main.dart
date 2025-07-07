import 'package:app_reporte_iestp_sullana/core/config/app_router.dart';
import 'package:app_reporte_iestp_sullana/core/theme/app_theme.dart';
import 'package:app_reporte_iestp_sullana/features/admin/data/datasources/supabase_admin_action_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/admin/domain/repositories/admin_action_repository_impl.dart';
import 'package:app_reporte_iestp_sullana/features/admin/presentation/providers/admin_action_provider.dart';
import 'package:app_reporte_iestp_sullana/features/auth/data/datasources/supabase_auth_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:app_reporte_iestp_sullana/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_reporte_iestp_sullana/features/settings/data/datasources/supabase_users_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/settings/domain/repositories/users_repository_impl.dart';
import 'package:app_reporte_iestp_sullana/features/settings/presentation/providers/users_provider.dart';
import 'package:app_reporte_iestp_sullana/features/shared/shared.dart';
import 'package:app_reporte_iestp_sullana/features/support/presentation/providers/support_provider.dart';
import 'package:app_reporte_iestp_sullana/features/user/data/datasources/supabase_user_action_data_source.dart';
import 'package:app_reporte_iestp_sullana/features/user/domain/repositories/user_action_repository_impl.dart';
import 'package:app_reporte_iestp_sullana/features/user/presentation/providers/user_action_provider.dart';
import 'package:app_reporte_iestp_sullana/services/notification_service.dart';
import 'package:app_reporte_iestp_sullana/services/notification_utils.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZACIÓN DE SERVICIOS BÁSICOS
  await Firebase.initializeApp();
  await NotificationService.init();

  // VERIFICAR ESTADO DE NOTIFICACIONES AL INICIO
  await NotificationUtils.checkOnAppStart();

  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
  await ScreenUtil.ensureScreenSize();

  final authDataSource = SupabaseAuthDataSourceImpl();
  final authRepository = AuthRepositoryImpl(authDataSource);
  final authProvider = AuthProvider(authRepository);

  // Configurar AdminActionProvider
  final adminActionDataSource = SupabaseAdminActionDataSourceImpl();
  final adminActionRepository = AdminActionRepositoryImpl(
    adminActionDataSource,
  );
  final adminActionProvider = AdminActionProvider(adminActionRepository);

  // Agregar estas líneas para UserActionProvider
  final userActionDataSource = SupabaseUserActionDataSourceImpl();
  final userActionRepository = UserActionRepositoryImpl(userActionDataSource);
  final userActionProvider = UserActionProvider(userActionRepository);

  await authProvider.initializeUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
        ChangeNotifierProvider.value(value: userActionProvider),
        ChangeNotifierProvider.value(value: adminActionProvider),
        ChangeNotifierProvider(
          create: (context) => SupportProvider(
            adminActionRepository: AdminActionRepositoryImpl(
              SupabaseAdminActionDataSourceImpl(),
            ),
            authProvider: context.read<AuthProvider>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
            title: 'App Reporte IESP Sullana',
            routerConfig: snapshot.data,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
          );
        },
      ),
    );
  }
}
