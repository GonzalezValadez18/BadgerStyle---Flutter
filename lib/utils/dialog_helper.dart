import 'package:flutter/material.dart';

class DialogHelper {
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    _showCustomDialog(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconColor: Colors.green,
      onOk: onOk,
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    _showCustomDialog(
      context: context,
      title: title,
      message: message,
      icon: Icons.warning,
      iconColor: Colors.amber, // Amarillo como solicitaste
    );
  }

  static void _showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                onOk?.call(); // Ejecuta la acción adicional si existe
              },
            ),
          ],
        );
      },
    );
  }
}
