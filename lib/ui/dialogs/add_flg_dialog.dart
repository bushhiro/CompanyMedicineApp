import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';

class AddFlgDialog extends StatefulWidget {
  final int patientId; // Добавим ID пациента, чтобы передавать его в POST-запрос

  const AddFlgDialog({super.key, required this.patientId});

  @override
  State<AddFlgDialog> createState() => _AddFlgDialogState();
}

class _AddFlgDialogState extends State<AddFlgDialog> {
  final _formKey = GlobalKey<FormState>();
  final _organizationController = TextEditingController();
  final _numberController = TextEditingController();
  final _resultController = TextEditingController();
  final _dateController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _organizationController.dispose();
    _numberController.dispose();
    _resultController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, добавьте фото.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uri = Uri.parse("http://192.168.29.112:65322/api/v1/flgs"); // замените на ваш эндпоинт
    final request = http.MultipartRequest('POST', uri)
      ..fields['patient_id'] = widget.patientId.toString()
      ..fields['organization'] = _organizationController.text
      ..fields['number'] = _numberController.text
      ..fields['result'] = _resultController.text
      ..fields['date'] = _convertToIsoDate(_dateController.text);

    request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

    final response = await request.send();
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Флюорография успешно добавлена.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: ${response.statusCode}")),
      );
    }
  }

  String _convertToIsoDate(String date) {
    // Преобразуем из DD.MM.YYYY в YYYY-MM-DD
    final parts = date.split('.');
    if (parts.length != 3) return date;
    return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primaryColor,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Добавить флюорографию",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Поле даты
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Дата",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      _dateController.text =
                      "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}";
                    }
                  },
                  validator: (v) => v == null || v.isEmpty ? "Введите дату" : null,
                ),
                const SizedBox(height: 16),

                // Организация
                TextFormField(
                  controller: _organizationController,
                  decoration: InputDecoration(
                    labelText: "Организация",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Введите организацию" : null,
                ),
                const SizedBox(height: 16),

                // Номер
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: "Номер (инд.)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Введите номер" : null,
                ),
                const SizedBox(height: 16),

                // Результат
                TextFormField(
                  controller: _resultController,
                  decoration: InputDecoration(
                    labelText: "Результат",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Введите результат" : null,
                ),

                const SizedBox(height: 16),

                // Кнопка выбора фото
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                      ),
                      child: const Text(
                        "Добавить фото",
                        style: TextStyle(color: AppColors.secondaryTextColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedFile != null)
                      Expanded(
                        child: Text(
                          _selectedFile!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.secondaryTextColor),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Кнопки управления
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                      ),
                      child: const Text(
                        "Отмена",
                        style: TextStyle(color: AppColors.secondaryTextColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text(
                        "Сохранить",
                        style: TextStyle(color: AppColors.secondaryTextColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}