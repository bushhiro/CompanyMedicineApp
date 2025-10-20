import 'package:flutter/material.dart';

class AddFlgDialog extends StatefulWidget {
  const AddFlgDialog({super.key});

  @override
  State<AddFlgDialog> createState() => _AddFlgDialogState();
}

class _AddFlgDialogState extends State<AddFlgDialog> {
  final _formKey = GlobalKey<FormState>();
  final _organizationController = TextEditingController();
  final _numberController = TextEditingController();
  final _resultController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _organizationController.dispose();
    _numberController.dispose();
    _resultController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Добавить ФЛГ",
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

              const SizedBox(height: 24),

              // Кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Отмена"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context, {
                          'date': _dateController.text,
                          'organization': _organizationController.text,
                          'number': _numberController.text,
                          'result': _resultController.text,
                        });
                      }
                    },
                    child: const Text("Сохранить"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}