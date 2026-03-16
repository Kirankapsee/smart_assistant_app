import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/suggestions_repository.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/mock_api_service.dart';
import 'presentation/cubits/chat/chat_cubit.dart';
import 'presentation/cubits/suggestions/suggestions_cubit.dart';
import 'presentation/cubits/theme/theme_cubit.dart';
import 'presentation/screens/main_shell.dart';

// ─────────────────────────────────────────────────────────────
// 🔧 ENVIRONMENT SWITCH
//
// true  → uses MockApiService (no backend needed, works offline)
// false → uses real ApiService (calls AppConstants.baseUrl)
//
// Set to false and update AppConstants.baseUrl before submission.
// ─────────────────────────────────────────────────────────────
const bool useMock = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const SmartAssistantApp());
}

class SmartAssistantApp extends StatelessWidget {
  const SmartAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the correct API implementation based on the flag above.
    final apiService = useMock ? MockApiService() : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => SuggestionsCubit(
            repository: SuggestionsRepository(apiService: apiService),
          ),
        ),
        BlocProvider(
          create: (_) => ChatCubit(
            repository: ChatRepository(apiService: apiService),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) => MaterialApp(
          title: 'Smart Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const MainShell(),
        ),
      ),
    );
  }
}
