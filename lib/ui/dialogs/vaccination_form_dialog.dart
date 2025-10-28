import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/vaccination_service.dart';
import '../../theme/app_colors.dart';

class VaccinationFormDialog extends StatefulWidget {
  final int patientId; // Добавляем ID пациента

  const VaccinationFormDialog({super.key, required this.patientId});

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

  // Словари для маппинга значений на ID
  final _dictionary = {
    "vaccineTypes": ["АКДС", "Корь", "Грипп", "COVID-19"],
    "drugs": ["Препарат А", "Препарат Б"],
    "doses": ["0.5 мл", "1 мл"],
    "places": ["Плечо", "Бедро"],
    "methods": ["Подкожно", "Внутримышечно"],
    "locations": ["Клиника №1", "Поликлиника №2"],
  };

  // Маппинг значений на ID (замените на реальные ID из вашей БД)
  final _valueToIdMap = {
    "vaccineTypes": {"АКДС": 1, "Корь": 2, "Грипп": 3, "COVID-19": 4},
    "drugs": {"Препарат А": 1, "Препарат Б": 2},
    "doses": {"0.5 мл": 1, "1 мл": 2},
    "places": {"Плечо": 1, "Бедро": 2},
    "methods": {"Подкожно": 1, "Внутримышечно": 2},
    "locations": {"Клиника №1": 1, "Поликлиника №2": 2},
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
              backgroundColor: AppColors.buttonColor
          ),
          child: const Text(
            "Отмена",
            style: TextStyle(color: AppColors.secondaryTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: _saveVaccination,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor
          ),
          child: const Text(
            "Сохранить",
            style: TextStyle(color: AppColors.secondaryTextColor),
          ),
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
      validator: (value) => value == null ? "Поле обязательно" : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? "Поле обязательно" : null,
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              errorText: _selectedDate == null ? "Дата обязательна" : null,
            ),
            controller: TextEditingController(
                text: _selectedDate == null ? "" : DateFormat('dd.MM.yyyy').format(_selectedDate!)
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
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

  Future<void> _saveVaccination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Выберите дату проведения прививки")),
      );
      return;
    }

    // Формируем данные для отправки
    final vaccinationData = {
      "body_part_id": _valueToIdMap["places"]![_place] ?? 0,
      "certificate_number_id": int.tryParse(_certificateController.text) ?? 0,
      "date": DateFormat('yyyy-MM-dd').format(_selectedDate!), // Формат для сервера
      "dose_id": _valueToIdMap["doses"]![_dose] ?? 0,
      "medication_id": _valueToIdMap["drugs"]![_drug] ?? 0,
      "method_id": _valueToIdMap["methods"]![_method] ?? 0,
      "number_id": int.tryParse(_numberController.text) ?? 0,
      "patient_id": widget.patientId, // ID пациента из параметра
      "place_id": _valueToIdMap["locations"]![_location] ?? 0,
      "result_id": int.tryParse(_resultController.text) ?? 0,
      "title_id": _valueToIdMap["vaccineTypes"]![_vaccineType] ?? 0,
    };

    print("Vaccination data to save: $vaccinationData");

    try {
      await VaccinationService(baseUrl: 'http://192.168.29.112:65322/api/v1').addVaccination(
        patientId: widget.patientId,
        bodyPartId: _valueToIdMap["places"]![_place] ?? 0,
        certificateNumberId: int.tryParse(_certificateController.text) ?? 0,
        date: _selectedDate!,
        doseId: _valueToIdMap["doses"]![_dose] ?? 0,
        medicationId: _valueToIdMap["drugs"]![_drug] ?? 0,
        methodId: _valueToIdMap["methods"]![_method] ?? 0,
        numberId: int.tryParse(_numberController.text) ?? 0,
        placeId: _valueToIdMap["locations"]![_location] ?? 0,
        resultId: int.tryParse(_resultController.text) ?? 0,
        titleId: _valueToIdMap["vaccineTypes"]![_vaccineType] ?? 0,
      );

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Прививка успешно добавлена")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при добавлении прививки: $e")),
      );
    }

    Navigator.pop(context, vaccinationData); // Возвращаем данные обратно
  }
}