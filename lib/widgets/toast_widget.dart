import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ToastType {
  danger,
  success,
  warning,
}

/// Toast
class Toast {
  Toast._();

  static danger(String text) => ToastWidget(
        type: ToastType.danger,
        text: text,
      );
  static success(String text) => ToastWidget(
        type: ToastType.success,
        text: text,
      );
  static warning(String text) => ToastWidget(
        type: ToastType.warning,
        text: text,
      );
}

/// Toast widget
class ToastWidget extends ConsumerWidget {
  const ToastWidget({super.key, required this.type, required this.text});

  final ToastType type;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: _backgroundColor(type),
      child: ListTile(
        leading: _icon(type),
        title: Text(text),
      ),
    );
  }

  Widget _icon(ToastType type) {
    return switch (type) {
      ToastType.danger => Icon(
          Icons.info,
          color: _backgroundIconColor(ToastType.danger),
        ),
      ToastType.success => Icon(
          Icons.check_circle,
          color: _backgroundIconColor(ToastType.success),
        ),
      ToastType.warning => Icon(
          Icons.warning,
          color: _backgroundIconColor(ToastType.success),
        ),
    };
  }

  Color _backgroundIconColor(ToastType type) {
    return switch (type) {
      ToastType.danger => const Color(0xFFEF665B),
      ToastType.success => const Color(0xFF84D65A),
      ToastType.warning => const Color(0xFFF7C752),
    };
  }

  Color _backgroundColor(ToastType type) {
    return switch (type) {
      ToastType.danger => const Color(0xFFFCE8DB),
      ToastType.success => const Color(0xFFEDFBD8).withOpacity(0.8),
      ToastType.warning => const Color(0xFFFEF7D1),
    };
  }
}
