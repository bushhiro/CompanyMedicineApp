import 'package:flutter/material.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/repositories/manual_repository.dart';
import '../../theme/app_colors.dart';

class AddPatientFormDialog extends StatefulWidget {
  final int groupId;

  const AddPatientFormDialog({super.key, required this.groupId});

  @override
  State<AddPatientFormDialog> createState() => _AddPatientFormDialogState();
}

class _AddPatientFormDialogState extends State<AddPatientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _snilsRefused = false;
  bool _isLoading = true;

  final _patientRepository =
  PatientRepositoryRemote(baseUrl: 'http://192.168.29.112:65322/api/v1');

  late final ManualRepository _manualRepository;

  Map<String, List<Map<String, dynamic>>> manuals = {};

  // Контроллеры
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _snilsController = TextEditingController();
  final _docSeriesController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _policyController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _positionController = TextEditingController();
  final _divisionController = TextEditingController();
  final _emailController = TextEditingController();

  // Dropdown values
  String _gender = "Мужской";
  Map<String, dynamic>? _documentType;
  Map<String, dynamic>? _examinationType;
  Map<String, dynamic>? _examinationView;
  Map<String, dynamic>? _harmPoint;

  @override
  void initState() {
    super.initState();
    _manualRepository = ManualRepository(
      remoteService:
      ManualRemoteService(baseUrl: 'http://192.168.29.112:65322/api/v1'),
    );
    _loadManuals();
  }

  Future<void> _loadManuals() async {
    try {
      final manualsList = await _manualRepository.getManuals();

      // Группируем их по типу
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var item in manualsList) {
        grouped.putIfAbsent(item.type, () => []);
        grouped[item.type]!.add({"id": item.id, "value": item.value});
      }

      setState(() {
        manuals = grouped;
        _isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке справочников: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: const Text("Добавить пациента"),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
                      _buildDropdownManual(
                        "Тип документа",
                        manuals["personal_document_type"],
                        _documentType,
                            (v) => setState(() => _documentType = v),
                      ),
                      _buildTextField("Серия документа", _docSeriesController),
                      _buildTextField("Адрес", _addressController),
                      _buildTextField("Место работы", _workplaceController),
                      _buildTextField("Подразделение", _divisionController),
                      _buildDropdownManual(
                        "Тип осмотра",
                        manuals["patient_examination_type"],
                        _examinationType,
                            (v) => setState(() => _examinationType = v),
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
                            child: _buildTextField("СНИЛС", _snilsController,
                                isRequired: !_snilsRefused),
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
                      _buildDropdown("Пол", _gender, ["Мужской", "Женский"],
                              (v) => setState(() => _gender = v!)),
                      _buildTextField("Номер документа", _docNumberController),
                      _buildTextField("Полис", _policyController),
                      _buildTextField("Должность", _positionController),
                      _buildDropdownManual(
                        "Пункт вредности",
                        manuals["harm_point"],
                        _harmPoint,
                            (v) => setState(() => _harmPoint = v),
                      ),
                      _buildDropdownManual(
                        "Вид осмотра",
                        manuals["patient_examination_view"],
                        _examinationView,
                            (v) => setState(() => _examinationView = v),
                      ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
              onPressed: _submit,
              child: const Text(
                "Добавить пациента",
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
        bool isRequired = true,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (v) {
          if (!isRequired) return null;
          return v == null || v.isEmpty ? "Поле обязательно" : null;
        },
      ),
    );
  }

  Widget _buildDropdownManual(
      String label,
      List<Map<String, dynamic>>? options,
      Map<String, dynamic>? selected,
      ValueChanged<Map<String, dynamic>?> onChanged,
      ) {
    if (options == null || options.isEmpty) {
      return _buildTextField(label, TextEditingController());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: selected,
        items: options
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e["value"].toString())))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Поле обязательно" : null,
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      String selectedValue,
      List<String> options,
      ValueChanged<String?> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: selectedValue,
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
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
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.text =
            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
          }
        },
        validator: (v) => v == null || v.isEmpty ? "Поле обязательно" : null,
      ),
    );
  }

  DateTime _parseDateFromDisplayFormat(String text) {
    try {
      final parts = text.split('.');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(2000, 1, 1);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fullName =
        "${_lastNameController.text} ${_firstNameController.text} ${_middleNameController.text}";
    final birthDate = _parseDateFromDisplayFormat(_birthDateController.text);

    try {
      await _patientRepository.addPatient(
        groupId: widget.groupId,
        fullName: fullName,
        birthDate: birthDate,
        gender: _gender,
        position: _positionController.text,
        division: _divisionController.text,
        examinationTypeId: _examinationType?["id"] ?? 0,
        examinationViewId: _examinationView?["id"] ?? 0,
        harmPointId: _harmPoint?["id"] ?? 0,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        docNumber: _docNumberController.text,
        docSeries: _docSeriesController.text,
        snils: _snilsRefused ? "" : _snilsController.text,
        oms: _policyController.text,
        documentTypeId: _documentType?["id"],
      );

      if (!mounted) return;
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