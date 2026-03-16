import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/local_storage_service.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final LocalStorageService _storage;

  ThemeCubit({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService(),
        super(ThemeState(isDark: false)) {
    _loadSaved();
  }

  ThemeMode get themeMode =>
      state.isDark ? ThemeMode.dark : ThemeMode.light;

  void _loadSaved() {
    emit(ThemeState(isDark: _storage.loadIsDarkMode()));
  }

  Future<void> toggle() async {
    final newValue = !state.isDark;
    await _storage.saveThemeMode(newValue);
    emit(ThemeState(isDark: newValue));
  }
}
