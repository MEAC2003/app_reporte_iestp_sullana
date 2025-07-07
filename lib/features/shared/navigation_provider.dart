import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Método para actualizar sin notificar (evita loops)
  void setIndexSilently(int index) {
    _currentIndex = index;
  }

  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }
}
