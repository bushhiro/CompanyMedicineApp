import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:work_app/data/models/patient.dart';
import 'package:work_app/widgets/action_buttons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class AnalysisScreen extends StatefulWidget {
  final PatientResponse patient;
  const AnalysisScreen({super.key, required this.patient});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;
  List<dynamic> _analyses = [];
  List<dynamic> _filteredAnalyses = [];

  final TextEditingController _searchController = TextEditingController();

  final Map<int, Map<String, bool>> _checkboxStates = {};

  @override
  void initState() {
    super.initState();
    _fetchAnalyses();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalyses() async {
    const url = 'http://192.168.29.112:65322/api/v1/analysis';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = (jsonData['data'] as List<dynamic>?) ?? [];

        setState(() {
          _analyses = data;
          _filteredAnalyses = List.from(data);
          for (var item in data) {
            final id = item['id'] is int
                ? item['id'] as int
                : int.tryParse(item['id'].toString()) ?? 0;
            _checkboxStates.putIfAbsent(id, () => {"done": false, "debt": false});
          }
          _isLoading = false;
        });
      } else {
        throw Exception("Ошибка загрузки анализов: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Ошибка при загрузке анализов: $e");
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filteredAnalyses = List.from(_analyses));
      return;
    }

    setState(() {
      _filteredAnalyses = _analyses.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final code = (item['code'] ?? '').toString().toLowerCase();
        return title.contains(query) || code.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CustomAppBar(
        subtitle: "Лабораторные исследования",
        title: widget.patient.fullName,
        showDrawerButton: true,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.primaryTextColor),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryTextColor),
                hintText: "Поиск по названию или коду...",
                hintStyle: const TextStyle(color: AppColors.primaryTextColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Поле "Лабораторные исследования"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Лабораторные исследования",
                  style: TextStyle(
                    color: AppColors.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Номер направления",
                  style: TextStyle(
                    color: AppColors.primaryTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Введите номер направления",
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.primaryTextColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Список анализов
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAnalyses.isEmpty
                ? const Center(
              child: Text(
                "Анализы не найдены",
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filteredAnalyses.length,
              itemBuilder: (context, index) {
                final item = _filteredAnalyses[index];
                final id = item['id'] is int
                    ? item['id'] as int
                    : int.tryParse(item['id'].toString()) ?? 0;
                final code = (item['code'] ?? '').toString();
                final title = (item['title'] ?? '').toString();
                final priceVal = item['price'];
                final priceStr = priceVal != null ? "${priceVal.toString()} ₽" : "-";

                final state = _checkboxStates.putIfAbsent(
                    id, () => {"done": false, "debt": false});

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  code,
                                  style: const TextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: AppColors.extraButtonColor,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: state["done"],
                                  onChanged: (v) {
                                    setState(() {
                                      state["done"] = v ?? false;
                                      if (v == true) state["debt"] = false;
                                      _checkboxStates[id] = state;
                                    });
                                  },
                                  activeColor: AppColors.extraButtonColor,
                                ),
                                const Text(
                                  "Сдан",
                                  style: TextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              priceStr,
                              style: const TextStyle(
                                color: AppColors.primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: state["debt"],
                                  onChanged: (v) {
                                    setState(() {
                                      state["debt"] = v ?? false;
                                      if (v == true) state["done"] = false;
                                      _checkboxStates[id] = state;
                                    });
                                  },
                                  activeColor: AppColors.errorColor,
                                ),
                                const Text(
                                  "Долг",
                                  style: TextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Кнопка "Сохранить" внизу по центру
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ActionButtons(
                alignment: Alignment.center,
                openLabel: "Сохранить",
                showOpen: true,
                onOpen: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}