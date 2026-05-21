import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'SplashPage/view/SplashPage.dart';
import 'core/app_theme.dart';
import 'core/shared_prefs.dart';
import 'core/theme_cubit.dart';
import 'Auth/LoginPage/viewmodel/LogInCubit.dart';
import 'Auth/SignUpPage/viewmodel/SignUpCubit.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/presentation/viewmodels/home_cubit.dart';
import 'features/search/data/datasources/search_remote_data_source.dart';
import 'features/search/data/repositories/search_repository_impl.dart';
import 'features/search/presentation/viewmodels/search_cubit.dart';
import 'features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'features/wishlist/presentation/viewmodels/wishlist_cubit.dart';
import 'features/cart/presentation/viewmodels/cart_cubit.dart';
import 'features/chat/presentation/viewmodels/chat_cubit.dart';
import 'features/notifications/presentation/viewmodels/notification_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await AppPrefs.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => SignUpCubit()),
        BlocProvider(
          create: (_) => HomeCubit(
            repository: HomeRepositoryImpl(
              dataSource: HomeRemoteDataSourceImpl(
                client: Supabase.instance.client,
              ),
            ),
          )..loadInitial(),
        ),
        BlocProvider(
          create: (_) => SearchCubit(
            repository: SearchRepositoryImpl(
              dataSource: SearchRemoteDataSourceImpl(
                client: Supabase.instance.client,
              ),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => WishlistCubit(
            dataSource: WishlistRemoteDataSourceImpl(
              client: Supabase.instance.client,
            ),
          ),
        ),
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => ChatCubit()),
        BlocProvider(create: (_) => NotificationCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
