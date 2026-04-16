import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  bool get isDarkMode => state == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    emit(isOn ? ThemeMode.dark : ThemeMode.light);
  }

  void cycleTheme() {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }
}
