import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  /// Колбэк для кнопки обновления
  final VoidCallback reloadOrganizations;

  /// Показать кнопку обновления
  final bool showRefresh;

  final bool showDelete;

  /// Показать кнопку очистки
  final bool showClear;

  /// Текст кнопки обновления
  final String refreshLabel;

  /// Текст кнопки очистки
  final String clearLabel;

  /// Колбэк для удаления конкретного элемента (опционально)
  final VoidCallback? onDelete;

  /// Текст кнопки удаления
  final String deleteLabel;

  /// Колбэк для очистки всего списка (опционально)
  final VoidCallback? onClear;

  const ActionButtons({
    required this.reloadOrganizations,
    this.showRefresh = true,
    this.showClear = false,
    this.showDelete = false,
    this.refreshLabel = "Обновить",
    this.clearLabel = "Очистить",
    this.onDelete,
    this.deleteLabel = "Удалить",
    this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRefresh)
              ElevatedButton.icon(
                onPressed: reloadOrganizations,
                icon: const Icon(Icons.refresh),
                label: Text(refreshLabel),
              ),
            if (showRefresh && (showClear || showDelete)) const SizedBox(width: 8),
            if (onDelete != null)
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: Text(deleteLabel),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            if (onDelete != null && (showClear || showRefresh)) const SizedBox(width: 8),
            if (showClear && onClear != null)
              ElevatedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_forever),
                label: Text(clearLabel),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              ),
          ],
        ),
      ),
    );
  }
}