import 'package:flutter/material.dart';

class MenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isVisible;

  const MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isVisible = true,
  });
}
