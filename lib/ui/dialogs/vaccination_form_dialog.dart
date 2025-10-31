import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../theme/app_colors.dart';

class VaccinationFormDialog extends StatefulWidget {
  final int patientId;

  const VaccinationFormDialog({super.key, required this.patientId});

  @override
  State<VaccinationFormDialog> createState() => _VaccinationFormDialogState();
}

class _VaccinationFormDialogState extends State<VaccinationFormDialog> {
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _certificateController = TextEditingController();
  final _resultController = TextEditingController();
  DateTime? _selectedDate;

  Map<String, int> _valueToIdMap = {}; // динамическая мапа
  Map<String, List<String>> _dictionary = {}; // динамические списки
  bool _loading = true;

  String? _vaccineType;
  String? _drug;
  String? _dose;
  String? _place;
  String? _method;
  String? _location;

  @override
  void initState() {
    super.initState();
    _fetchManuals();
  }

  Future<void> _fetchManuals() async {
    try {
      final url = Uri.parse('http://192.168.29.112:65322/api/v1/manuals');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'] as List<dynamic>;

        // Сбор уникальных значений по типам
        final Map<String, List<String>> dict = {};
        final Map<String, Map<String, int>> valueMap = {};

        for (var item in data) {
          final type = item['type'] as String;
          final value = item['value'].toString();
          final id = item['id'] as int;

          dict[type] = dict[type] ?? [];
          if (!dict[type]!.contains(value)) dict[type]!.add(value);

          valueMap[type] = valueMap[type] ?? {};
          valueMap[type]![value] = id;
        }

        setState(() {
          _dictionary = dict;
          _valueToIdMap = valueMap.map((k, v) => MapEntry(k, v[_getDefaultKeyForType(k)] ?? 0));
          _loading = false;
        });
      } else {
        throw Exception('Ошибка получения справочников: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении manuals: $e');
      setState(() => _loading = false);
    }
  }

  String _getDefaultKeyForType(String type) {
    // Возвращает первый ключ, чтобы инициализировать valueToIdMap
    return _dictionary[type]?.first ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      backgroundColor: AppColors.primaryColor,
      title: const Text("Добавить прививку"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown("vaccine_title", "Тип прививки", _vaccineType, (v) => setState(() => _vaccineType = v)),
              _buildTextField("Номер прививки", _numberController),
              _buildDropdown("vaccine_medication", "Препарат", _drug, (v) => setState(() => _drug = v)),
              _buildDropdown("vaccine_dose", "Доза", _dose, (v) => setState(() => _dose = v)),
              _buildDropdown("vaccine_body_part", "Место", _place, (v) => setState(() => _place = v)),
              _buildDropdown("vaccine_method", "Метод", _method, (v) => setState(() => _method = v)),
              _buildDropdown("vaccine_place", "Место проведения", _location, (v) => setState(() => _location = v)),
              _buildTextField("Номер сертификата", _certificateController),
              _buildTextField("Результат", _resultController),
              const SizedBox(height: 10),
              _buildDatePicker(context, "Дата проведения прививки"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _pickedImage = image;
                    });
                  }
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text(
                  "Добавить фото",
                  style: TextStyle(color: AppColors.secondaryTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (_pickedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(File(_pickedImage!.path), height: 100),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
          child: const Text("Отмена", style: TextStyle(color: AppColors.secondaryTextColor)),
        ),
        ElevatedButton(
          onPressed: _saveVaccination,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
          child: const Text("Сохранить", style: TextStyle(color: AppColors.secondaryTextColor)),
        ),
      ],
    );
  }

  Widget _buildDropdown(String typeKey, String label, String? value, Function(String?) onChanged) {
    final items = _dictionary[typeKey] ?? [];
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value ?? (items.isNotEmpty ? items.first : null),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Поле обязательно" : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (v) => v == null || v.isEmpty ? "Поле обязательно" : null,
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
              text: _selectedDate == null ? "" : DateFormat('dd.MM.yyyy').format(_selectedDate!),
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
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    try {
      // Начальный URL
      Uri uri = Uri.parse('http://192.168.29.112:65322/api/v1/vaccines/');
      var request = http.MultipartRequest('POST', uri);

      // Добавляем поля формы
      request.fields.addAll({
        'patient_id': widget.patientId.toString(),
        'title_id': (_valueToIdMap["vaccine_title"] ?? 0).toString(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'result_id': int.tryParse(_resultController.text)?.toString() ?? '0',
        'medication_id': (_valueToIdMap["vaccine_medication"] ?? 0).toString(),
        'dose_id': (_valueToIdMap["vaccine_dose"] ?? 0).toString(),
        'number_id': int.tryParse(_numberController.text)?.toString() ?? '0',
        'certificate_number_id': int.tryParse(_certificateController.text)?.toString() ?? '0',
        'body_part_id': (_valueToIdMap["vaccine_body_part"] ?? 0).toString(),
        'method_id': (_valueToIdMap["vaccine_method"] ?? 0).toString(),
        'place_id': (_valueToIdMap["vaccine_place"] ?? 0).toString(),
      });

      // Добавляем файл, если выбран
      if (_pickedImage != null) {
        final ext = _pickedImage!.path.split('.').last.toLowerCase();
        final mimeType = ext == 'png'
            ? 'image/png'
            : (ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'application/octet-stream');

        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _pickedImage!.path,
          contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
        ));
      }

      var streamedResponse = await request.send();

// Обработка редиректа 307
      if (streamedResponse.statusCode == 307) {
        final location = streamedResponse.headers['location'];
        if (location != null) {
          uri = location.startsWith('http')
              ? Uri.parse(location)
              : Uri.parse('http://192.168.29.112:65322$location');

          var redirectedRequest = http.MultipartRequest('POST', uri);
          redirectedRequest.fields.addAll(request.fields);

          // Если файл был выбран, создаем новый MultipartFile
          if (_pickedImage != null) {
            final ext = _pickedImage!.path.split('.').last.toLowerCase();
            final mimeType = ext == 'png'
                ? 'image/png'
                : (ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'application/octet-stream');

            redirectedRequest.files.add(await http.MultipartFile.fromPath(
              'file',
              _pickedImage!.path,
              contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
            ));
          }

          streamedResponse = await redirectedRequest.send();
        }
      }

      final respStr = await streamedResponse.stream.bytesToString();
      debugPrint("RESPONSE STATUS: ${streamedResponse.statusCode}");
      debugPrint("RESPONSE BODY: $respStr");

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Прививка успешно добавлена")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при добавлении прививки: $respStr")),
        );
      }
    } catch (e, stack) {
      debugPrint("ERROR: $e");
      debugPrintStack(stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при добавлении прививки: $e")),
      );
    }
  }
}