import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

class TitresFormDialog extends StatefulWidget {
  const TitresFormDialog({super.key});

  @override
  State<TitresFormDialog> createState() => _TitresFormDialogState();
}

class _TitresFormDialogState extends State<TitresFormDialog> {
  String? _titreType;
  DateTime? _date;
  final _countController = TextEditingController();

  final _types = ["COVID-19", "Гепатит B", "Краснуха"];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавить титры"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "Тип титров"),
              items: _types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _titreType = v),
            ),
            const SizedBox(height: 8),
            _buildDatePicker(context, "Дата исследования"),
            TextField(
              controller: _countController,
              decoration: const InputDecoration(labelText: "Количество титров"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor
              ),
              icon: const Icon(Icons.add_a_photo, color: AppColors.secondaryTextColor),
              label: const Text("Добавить фото",
                style: TextStyle(color: AppColors.secondaryTextColor),),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor),
            child: const Text("Отмена",
              style: TextStyle(color: AppColors.secondaryTextColor),)),
        ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor),
            child: const Text("Сохранить",
              style: TextStyle(color: AppColors.secondaryTextColor),)),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(
          child: Text(_date == null
              ? "$label: не выбрана"
              : "$label: ${DateFormat('dd.MM.yyyy').format(_date!)}"),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.buttonColor,),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (picked != null) setState(() => _date = picked);
          },
        ),
      ],
    );
  }
}