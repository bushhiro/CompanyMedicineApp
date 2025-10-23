import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

class VaccinationFormDialog extends StatefulWidget {
  const VaccinationFormDialog({super.key});

  @override
  State<VaccinationFormDialog> createState() => _VaccinationFormDialogState();
}

class _VaccinationFormDialogState extends State<VaccinationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _certificateController = TextEditingController();
  final _resultController = TextEditingController();
  DateTime? _selectedDate;

  String? _vaccineType;
  String? _drug;
  String? _dose;
  String? _place;
  String? _method;
  String? _location;

  final _dictionary = {
    "vaccineTypes": ["АКДС", "Корь", "Грипп", "COVID-19"],
    "drugs": ["Препарат А", "Препарат Б"],
    "doses": ["0.5 мл", "1 мл"],
    "places": ["Плечо", "Бедро"],
    "methods": ["Подкожно", "Внутримышечно"],
    "locations": ["Клиника №1", "Поликлиника №2"],
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryColor,
      title: const Text("Добавить прививку"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown("Тип прививки", _vaccineType, _dictionary["vaccineTypes"]!, (v) => _vaccineType = v),
              _buildTextField("Номер прививки", _numberController),
              _buildDropdown("Препарат", _drug, _dictionary["drugs"]!, (v) => _drug = v),
              _buildDropdown("Доза", _dose, _dictionary["doses"]!, (v) => _dose = v),
              _buildDropdown("Место", _place, _dictionary["places"]!, (v) => _place = v),
              _buildDropdown("Метод", _method, _dictionary["methods"]!, (v) => _method = v),
              _buildDropdown("Место проведения", _location, _dictionary["locations"]!, (v) => _location = v),
              _buildTextField("Номер сертификата", _certificateController),
              _buildTextField("Результат", _resultController),
              const SizedBox(height: 10),
              _buildDatePicker(context, "Дата проведения прививки"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_a_photo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor
                ),
                label: const Text(
                  "Добавить фото",
                  style: TextStyle(color: AppColors.secondaryTextColor),
                ),
              ),
            ],
          ),
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
            style: TextStyle(color: AppColors.secondaryTextColor),),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(
          child: Text(_selectedDate == null
              ? "$label: не выбрана"
              : "$label: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}"),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
        ),
      ],
    );
  }
}