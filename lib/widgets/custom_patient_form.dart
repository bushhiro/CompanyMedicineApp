import 'package:flutter/material.dart';
import '../data/repositories/patient_repository.dart';

class AddPatientFormDialog extends StatefulWidget {
  final int groupId;

  const AddPatientFormDialog({super.key, required this.groupId});

  @override
  State<AddPatientFormDialog> createState() => _AddPatientFormDialogState();
}

class _AddPatientFormDialogState extends State<AddPatientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _snilsRefused = false;

  // Контроллеры для всех полей
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _snilsController = TextEditingController();
  final _documentTypeController = TextEditingController();
  final _docSeriesController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _policyController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _positionController = TextEditingController();
  final _divisionController = TextEditingController();
  final _harmPointController = TextEditingController();
  final _examinationTypeController = TextEditingController();
  final _examinationViewController = TextEditingController();
  final _emailController = TextEditingController();

  // Поля для дропдаунов
  String _gender = "Мужской"; // для дропдауна
  bool get _isMale => _gender == "Мужской"; // для отправки на сервер

  String _examinationType = "Предварительный";
  String _harmPoint = "Норма";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Добавить пациента"),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Два столбца
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextField("Фамилия", _lastNameController),
                            _buildTextField("Отчество", _middleNameController),
                            _buildTextField("Телефон", _phoneController,
                                keyboardType: TextInputType.phone),
                            _buildTextField("Тип документа", _documentTypeController),
                            _buildTextField("Серия документа", _docSeriesController),
                            _buildTextField("Адрес", _addressController),
                            _buildTextField("Место работы", _workplaceController),
                            _buildTextField("Подразделение", _divisionController),
                            _buildDropdown(
                              "Вид осмотра",
                              _examinationType,
                              ["Предварительный", "Профосмотр", "Специальный"],
                                  (v) => setState(() => _examinationType = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextField("Имя", _firstNameController),
                            _buildDatePickerField("Дата рождения", _birthDateController),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField("СНИЛС", _snilsController),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    const Text("Отказ"),
                                    Checkbox(
                                      value: _snilsRefused,
                                      onChanged: (v) {
                                        setState(() {
                                          _snilsRefused = v ?? false;
                                          if (_snilsRefused) _snilsController.clear();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            _buildDropdown(
                              "Пол",
                              _gender,
                              ["Мужской", "Женский"],
                                  (v) => setState(() => _gender = v!),
                            ),
                            _buildTextField("Номер документа", _docNumberController),
                            _buildTextField("Полис", _policyController),
                            _buildTextField("Должность", _positionController),
                            _buildDropdown(
                              "Пункт вредности",
                              _harmPoint,
                              ["Норма", "Повышенный", "Экстремальный"],
                                  (v) => setState(() => _harmPoint = v!),
                            ),
                            _buildTextField("Тип осмотра", _examinationViewController),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Электронная почта", _emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Добавить пациента"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          validator: (value) =>
          value == null || value.isEmpty ? "Поле обязательно" : null,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onTap: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            controller.text =
            "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
          }
        },
        validator: (value) =>
        value == null || value.isEmpty ? "Поле обязательно" : null,
      ),
    );
  }

  Widget _buildDropdown(
      String label, String selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            items: options
                .map((option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fullName =
        "${_lastNameController.text} ${_firstNameController.text} ${_middleNameController.text}";

    final birthDate = DateTime.tryParse(_birthDateController.text) ?? DateTime.now();

    try {
      await AddPatientService(baseUrl: 'http://10.0.2.2:8081/api/v1').addPatient(
        groupId: widget.groupId,
        fullName: fullName,
        birthDate: birthDate,
        isMale: _isMale, // <- теперь корректно булево значение
        position: _positionController.text,
        division: _divisionController.text,
        examinationTypeId: int.tryParse(_examinationTypeController.text) ?? 4,
        examinationViewId: int.tryParse(_examinationViewController.text) ?? 5,
        harmPointId: int.tryParse(_harmPointController.text) ?? 1,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        docNumber: _docNumberController.text,
        docSeries: _docSeriesController.text,
        snils: _snilsRefused ? "" : _snilsController.text,
        oms: _policyController.text,
        documentTypeId: int.tryParse(_documentTypeController.text),
      );

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пациент успешно добавлен")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при добавлении пациента: $e")),
      );
    }
  }
}