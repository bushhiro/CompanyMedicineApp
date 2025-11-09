import 'package:flutter/material.dart';
import 'package:work_app/data/models/patient.dart';
import 'package:work_app/data/repositories/analysis_repository.dart';
import 'package:work_app/widgets/action_buttons.dart';
import '../../data/models/analysis.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class AnalysisScreen extends StatefulWidget {
  final PatientResponse patient;
  final AnalysisRepository analysisRepository;

  const AnalysisScreen({
    super.key,
    required this.patient,
    required this.analysisRepository,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;
  List<AnalysisOrderItemResponse> _assignedAnalyses = [];
  List<AnalysisOrderItemResponse> _filteredAnalyses = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _orderNumberController = TextEditingController();
  final Map<int, Map<String, bool>> _checkboxStates = {};

  @override
  void initState() {
    super.initState();
    _loadAssignedAnalyses();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedAnalyses() async {
    setState(() => _isLoading = true);
    try {
      // Получаем назначенные анализы из локальной базы через DAO
      final orders = await widget.analysisRepository.analysisOrderDao
          .getOrdersByPatient(widget.patient.id);

      final assignedItems = orders.isNotEmpty
          ? orders.last.orderItems
          : <AnalysisOrderItemResponse>[];

      final checkboxStates = <int, Map<String, bool>>{};
      for (var item in assignedItems) {
        checkboxStates[item.analysis.id] = {
          "done": item.isCompleted,
          "debt": !item.isCompleted,
        };
      }

      setState(() {
        _assignedAnalyses = assignedItems;
        _filteredAnalyses = List.from(assignedItems);
        _checkboxStates.clear();
        _checkboxStates.addAll(checkboxStates);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Ошибка загрузки назначенных анализов: $e");
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filteredAnalyses = List.from(_assignedAnalyses));
      return;
    }

    setState(() {
      _filteredAnalyses = _assignedAnalyses.where((item) {
        final title = item.analysis.title.toLowerCase();
        final code = item.analysis.code.toLowerCase();
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.primaryTextColor),
              decoration: InputDecoration(
                prefixIcon:
                const Icon(Icons.search, color: AppColors.primaryTextColor),
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
                  controller: _orderNumberController,
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAnalyses.isEmpty
                ? const Center(
              child: Text(
                "Назначенные анализы отсутствуют",
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: _filteredAnalyses.length,
              itemBuilder: (context, index) {
                final item = _filteredAnalyses[index];
                final id = item.analysis.id;
                final state = _checkboxStates[id]!;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
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
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.analysis.code,
                                  style: const TextStyle(
                                    color:
                                    AppColors.primaryTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.analysis.title,
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
                                      _checkboxStates[id] = {
                                        "done": v ?? false,
                                        "debt": v == true
                                            ? false
                                            : _checkboxStates[id]?["debt"] ??
                                            false,
                                      };
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
                              "${item.analysis.price} ₽",
                              style: const TextStyle(
                                color: AppColors.primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: state["debt"],
                                  onChanged: (v) {
                                    setState(() {
                                      _checkboxStates[id] = {
                                        "done": v == true
                                            ? false
                                            : _checkboxStates[id]?["done"] ??
                                            false,
                                        "debt": v ?? false,
                                      };
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ActionButtons(
                alignment: Alignment.center,
                openLabel: "Сохранить",
                showOpen: true,
                onOpen: () async {
                  final orderNumber = _orderNumberController.text.trim();

                  final updatedItems = _assignedAnalyses.map((item) {
                    final state = _checkboxStates[item.analysis.id]!;
                    return AnalysisOrderItemResponse(
                      id: item.id,
                      analysisId: item.analysis.id,
                      analysis: item.analysis,
                      isCompleted: state["done"] ?? false,
                    );
                  }).toList();

                  await widget.analysisRepository.savePatientAnalysisOrders(
                    widget.patient.id,
                    updatedItems,
                    orderNumber: orderNumber.isEmpty ? null : orderNumber,
                  );

                  // Перезагружаем данные из базы после сохранения
                  await _loadAssignedAnalyses();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Статусы анализов сохранены")),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}