import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

class ExemptionFormDialog extends StatefulWidget {
  const ExemptionFormDialog({super.key});

  @override
  State<ExemptionFormDialog> createState() => _ExemptionFormDialogState();
}

class _ExemptionFormDialogState extends State<ExemptionFormDialog> {
  String? _vaccineType;
  DateTime? _date;
  final _numberController = TextEditingController();
  final _types = ["АКДС", "Грипп", "Корь", "COVID-19"];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавить медотвод"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: "Тип прививки"),
            items: _types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _vaccineType = v),
          ),
          const SizedBox(height: 8),
          _buildDatePicker(context, "Дата медотвода"),
          TextField(
            controller: _numberController,
            decoration: const InputDecoration(labelText: "Номер медотвода"),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor),
            child: Text("Отмена",
              style: TextStyle(color: AppColors.secondaryTextColor))),
        ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor),
            child: const Text("Сохранить",
              style: TextStyle(color: AppColors.secondaryTextColor))),
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