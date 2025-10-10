import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  /// Колбэк для кнопки обновления
  final VoidCallback? reloadOrganizations;

  /// Колбэк для кнопки "Открыть"
  final VoidCallback? onOpen;

  /// Колбэк для удаления конкретного элемента (опционально)
  final VoidCallback? onDelete;

  /// Колбэк для очистки всего списка (опционально)
  final VoidCallback? onClear;

  /// Показать кнопку обновления
  final bool showRefresh;

  /// Показать кнопку очистки
  final bool showClear;

  /// Показать кнопку удаления
  final bool showDelete;

  /// Показать кнопку "Открыть"
  final bool showOpen;

  /// Текст кнопки обновления
  final String refreshLabel;

  /// Текст кнопки очистки
  final String clearLabel;

  /// Текст кнопки удаления
  final String deleteLabel;

  /// Текст кнопки "Открыть"
  final String openLabel;

  const ActionButtons({
     this.reloadOrganizations,
    this.showRefresh = false,
    this.showClear = false,
    this.showDelete = false,
    this.showOpen = false,
    this.refreshLabel = "Обновить",
    this.clearLabel = "Очистить",
    this.deleteLabel = "Удалить",
    this.openLabel = "Открыть",
    this.onDelete,
    this.onClear,
    this.onOpen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (showRefresh)
              ElevatedButton.icon(
                onPressed: reloadOrganizations,
                icon: const Icon(Icons.refresh),
                label: Text(refreshLabel),
              ),
            if (showOpen && onOpen != null)
              ElevatedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.folder_open),
                label: Text(openLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
              ),
            if (showDelete && onDelete != null)
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: Text(deleteLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                ),
              ),
            if (showClear && onClear != null)
              ElevatedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_forever),
                label: Text(clearLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}