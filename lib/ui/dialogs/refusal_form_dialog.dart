import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class RefusalFormDialog extends StatefulWidget {
  final int patientId;

  const RefusalFormDialog({super.key, required this.patientId});

  @override
  State<RefusalFormDialog> createState() => _RefusalFormDialogState();
}

class _RefusalFormDialogState extends State<RefusalFormDialog> {
  String? _vaccineType;
  DateTime? _refusalDate;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  Map<String, List<String>> _dictionary = {};
  Map<String, int> _valueToIdMap = {};

  @override
  void initState() {
    super.initState();
    _fetchManuals();
  }

  /// Загрузка справочников
  Future<void> _fetchManuals() async {
    try {
      final url = Uri.parse('http://192.168.29.112:65322/api/v1/manuals');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'] as List<dynamic>;

        final Map<String, List<String>> dict = {};
        final Map<String, int> map = {};

        for (var item in data) {
          final type = item['type']?.toString() ?? '';
          final value = item['value']?.toString() ?? '';
          final id = item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0;

          if (type == 'vaccine_title') {
            dict[type] = dict[type] ?? [];
            if (!dict[type]!.contains(value)) dict[type]!.add(value);
            map[value] = id;
          }
        }

        setState(() {
          _dictionary = dict;
          _valueToIdMap = map;
          _loading = false;
        });
      } else {
        throw Exception('Ошибка получения справочников: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Ошибка при загрузке manuals: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final types = _dictionary['vaccine_title'] ?? [];

    return AlertDialog(
      backgroundColor: AppColors.primaryColor,
      title: const Text("Добавить отказ"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Тип прививки"),
              value: _vaccineType,
              items: types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _vaccineType = v),
            ),
            const SizedBox(height: 10),
            _buildDatePicker(context, "Дата отказа"),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
              icon: const Icon(Icons.add_a_photo, color: AppColors.secondaryTextColor),
              label: const Text(
                "Добавить фото",
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
            ),
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.file(File(_pickedImage!.path), height: 100),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
          child: const Text("Отмена", style: TextStyle(color: AppColors.secondaryTextColor)),
        ),
        ElevatedButton(
          onPressed: _saveRefusal,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
          child: const Text("Сохранить", style: TextStyle(color: AppColors.secondaryTextColor)),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _refusalDate == null
                ? "$label: не выбрана"
                : "$label: ${DateFormat('dd.MM.yyyy').format(_refusalDate!)}",
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.buttonColor),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (picked != null) setState(() => _refusalDate = picked);
          },
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _saveRefusal() async {
    if (_vaccineType == null || _refusalDate == null || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Все поля и фото обязательны для заполнения")),
      );
      return;
    }

    try {
      final uri = Uri.parse('http://192.168.29.112:65322/api/v1/vaccines/refusals');
      final request = http.MultipartRequest('POST', uri);

      final titleId = _valueToIdMap[_vaccineType] ?? 0;

      if (titleId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка: не удалось найти ID для типа прививки ($_vaccineType)")),
        );
        return;
      }

      request.fields.addAll({
        'patient_id': widget.patientId.toString(),
        'title_id': titleId.toString(),
        'date': DateFormat('yyyy-MM-dd').format(_refusalDate!),
      });

      final ext = _pickedImage!.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? 'image/png'
          : (ext == 'jpg' || ext == 'jpeg'
          ? 'image/jpeg'
          : 'application/octet-stream');

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _pickedImage!.path,
        contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
      ));

      // DEBUG
      debugPrint("=== DEBUG REFUSAL UPLOAD ===");
      request.fields.forEach((k, v) => debugPrint("$k: $v"));
      debugPrint("File: ${_pickedImage!.path}");

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: $respStr");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Отказ успешно добавлен")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при добавлении отказа: $respStr")),
        );
      }
    } catch (e, stack) {
      debugPrint("ERROR: $e");
      debugPrintStack(stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при добавлении отказа: $e")),
      );
    }
  }
}