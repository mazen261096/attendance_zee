import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum DialogType { success, error }

class StatusDialog extends StatelessWidget {
  const StatusDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onOk,
  });

  final DialogType type;
  final String title;
  final String message;
  final VoidCallback? onOk;

  factory StatusDialog.success({
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    return StatusDialog(
      type: DialogType.success,
      title: title,
      message: message,
      onOk: onOk,
    );
  }

  factory StatusDialog.error({
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    return StatusDialog(
      type: DialogType.error,
      title: title,
      message: message,
      onOk: onOk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == DialogType.success;
    final color = isSuccess ? AppColors.success : AppColors.error;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onOk?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
