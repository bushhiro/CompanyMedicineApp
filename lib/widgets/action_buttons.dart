import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  /// Колбэк для кнопки обновления
  final VoidCallback? reloadOrganizations;

  /// Колбэк для кнопки "Открыть"
  final VoidCallback? onOpen;

  /// Колбэк для удаления конкретного элемента
  final VoidCallback? onDelete;

  /// Колбэк для очистки всего списка
  final VoidCallback? onClear;

  /// Показать кнопку обновления
  final bool showRefresh;

  /// Показать кнопку очистки
  final bool showClear;

  /// Показать кнопку удаления
  final bool showDelete;

  /// Показать кнопку "Открыть"
  final bool showOpen;

  final Size? buttonSize;

  final Alignment alignment;


  /// Текст кнопок
  final String refreshLabel;
  final String clearLabel;
  final String deleteLabel;
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
    this.buttonSize,
    this.alignment = Alignment.centerRight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (showRefresh)
              _buildButton(
                onPressed: reloadOrganizations,
                icon: null,
                label: refreshLabel,
              ),
            if (showOpen && onOpen != null)
              _buildButton(
                onPressed: onOpen,
                label: openLabel,
              ),
            if (showDelete && onDelete != null)
              _buildButton(
                onPressed: onDelete,
                icon: Icons.delete,
                label: deleteLabel,
              ),
            if (showClear && onClear != null)
              _buildButton(
                onPressed: onClear,
                icon: Icons.delete_forever,
                label: clearLabel,
              ),
          ],
        ),
      ),
    );
  }

  /// Унифицированный стиль кнопок
  Widget _buildButton({
    required VoidCallback? onPressed,
    IconData? icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        fixedSize: buttonSize,
        backgroundColor: AppColors.buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}