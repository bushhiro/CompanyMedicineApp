import 'package:flutter/material.dart';
import 'package:work_app/data/repositories/analysis_repository.dart';
import '../../data/models/patient.dart';
import '../data/models/analysis.dart';
import '../data/models/reception.dart';
import '../presentation/screens/analysis_screen.dart';
import '../theme/app_colors.dart';
import '../ui/dialogs/add_flg_dialog.dart';
import '../ui/dialogs/add_vaccination_dialog.dart';
import 'action_buttons.dart';


class CustomPatientCard extends StatefulWidget {
  final PatientResponse patient;
  final AnalysisRepository analysisRepository; // добавляем


  const CustomPatientCard({
    super.key,
    required this.patient,
    required this.analysisRepository,
  });

  @override
  State<CustomPatientCard> createState() => _CustomPatientCardState();
}

class _CustomPatientCardState extends State<CustomPatientCard> {
  final GlobalKey _specialistsButtonKey = GlobalKey();
  final GlobalKey _analysisButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  Future<Map<String, int>> _calculateAnalysisStats(PatientResponse patient) async {
    final orders = await widget.analysisRepository.analysisOrderDao
        .getOrdersByPatient(patient.id);
    final orderItems = orders.expand((o) => o.orderItems).toList();
    final total = orderItems.length;
    final done = orderItems.where((i) => i.isCompleted).length;
    return {"total": total, "done": done};
  }

  void _showContactDialog() {
    final p = widget.patient;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Контактные данные пациента"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ФИО: ${p.fullName}"),
            const SizedBox(height: 4),
            Text("Телефон: ${p.contactInfo.phone}"),
            Text("Email: ${p.contactInfo.email}"),
            Text("Адрес: ${p.contactInfo.address}"),
          ],
        ),
        actions: [
          ActionButtons(
            showOpen: true,
            onOpen: () => Navigator.pop(context),
            openLabel: "Закрыть",
          ),
        ],
      ),
    );
  }

  void _showExamineDialog() {
    showDialog(
      context: context,
      builder: (_) => AddVaccinationDialog(patientId: widget.patient.id,),
    );
  }

  void _toggleOverlay({required bool forSpecialists}) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    final key = forSpecialists ? _specialistsButtonKey : _analysisButtonKey;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy - 10 + size.height,
              width: 400,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.patientCardStatusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: forSpecialists
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: (widget.patient.receptions)
                        .map<Widget>((item) {
                      final title = item.specialization?.title ?? "Неизвестно";
                      final done = item.isCompleted;
                      return _buildOverlayRow(title, done);
                    }).toList(),
                  )
                      : FutureBuilder<List<AnalysisOrderItemResponse>>(
                    future: widget.analysisRepository.analysisOrderDao
                        .getOrdersByPatient(widget.patient.id)
                        .then((orders) => orders.expand((o) => o.orderItems).toList()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Назначенные анализы отсутствуют"));
                      }
                      final analysisItems = snapshot.data!;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: analysisItems.map<Widget>((analysisItem) {
                          final title = analysisItem.analysis.title;
                          final done = analysisItem.isCompleted;
                          return _buildOverlayRow(title, done);
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOverlayRow(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12))),
          Text(done ? "Пройдено" : "Не пройдено",
              style: TextStyle(
                color: done ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final specialistsTotal = p.specializations.length;
    final specialistsDone =
        p.receptions.where((r) => r.isCompleted).length;
    final testsTotal = p.analysisOrder.orderItems.length;
    final testsDone = p.analysisOrder.orderItems
        .where((a) => a.isCompleted)
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderColor, width: 2),
      ),
      color: AppColors.primaryColor,
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: AppColors.primaryTextColor,
              tabs: [
                Tab(text: "Общая информация"),
                Tab(text: "Прививки"),
                Tab(text: "ФЛГ"),
                Tab(text: "Согласие"),
              ],
            ),
            SizedBox(
              height: 280,
              child: TabBarView(
                children: [
                  _buildGeneralInfoTab(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
                  _buildVaccinesTab(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
                  _buildFlgTab(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
                  _buildConsentTab(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ActionButtons(
                      showOpen: true,
                      openLabel: "Контактные данные",
                      onOpen: _showContactDialog,
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ActionButtons(
                      showOpen: true,
                      openLabel: "Осмотреть пациента",
                      onOpen: () => showReceptionsDialog(context, widget.patient.receptions, widget.patient),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftInfo(PatientResponse p, int specialistsDone, int specialistsTotal,
      int testsDone, int testsTotal) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      color: AppColors.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.fullName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              softWrap: true),
          const SizedBox(height: 2),
          const Text("Основное", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(p.position, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            "Дата рождения: ${p.birthDate.day.toString().padLeft(2, '0')}.${p.birthDate.month.toString().padLeft(2, '0')}.${p.birthDate.year}",
            style: const TextStyle(fontSize: 12),
          ),
          Text("Возраст: ${p.age} лет", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            key: _specialistsButtonKey,
            onPressed: () => _toggleOverlay(forSpecialists: true),
            icon: const Icon(Icons.person, size: 18),
            label: Text("Специалисты $specialistsDone/$specialistsTotal",
                style: TextStyle(color: AppColors.primaryTextColor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 32),
              textStyle: const TextStyle(fontSize: 12),
              iconColor: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          FutureBuilder<Map<String, int>>(
            future: _calculateAnalysisStats(p),
            builder: (context, snapshot) {
              final total = snapshot.data?["total"] ?? 0;
              final done = snapshot.data?["done"] ?? 0;
              return ElevatedButton.icon(
                key: _analysisButtonKey,
                onPressed: () => _toggleOverlay(forSpecialists: false),
                icon: const Icon(Icons.science, size: 18),
                label: Text("Анализы $done/$total",
                    style: TextStyle(color: AppColors.primaryTextColor)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 32),
                  textStyle: const TextStyle(fontSize: 12),
                  iconColor: AppColors.primaryTextColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoTab(PatientResponse p, int specialistsDone, int specialistsTotal,
      int testsDone, int testsTotal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftInfo(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FutureBuilder<List<AnalysisOrderResponse>>(
              future: widget.analysisRepository.analysisOrderDao.getOrdersByPatient(p.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) return const SizedBox.shrink();

                final orderItems =
                snapshot.data!.expand((o) => o.orderItems).toList();

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statusBadge("ФЛГ", p.flgs.isNotEmpty),
                    _statusBadge(
                      "Прививки",
                      p.vaccines.isNotEmpty,
                      p.vaccines.isNotEmpty ? "${p.vaccines.length} шт." : null,
                    ),
                    if (orderItems.isNotEmpty)
                      ...orderItems.map((item) {
                        final title = item.analysis.title;
                        final done = item.isCompleted;
                        return _statusBadge(title, done, done ? "✓" : "✗");
                      })
                    else
                      _statusBadge("Анализы", false),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Прививки
  Widget _buildVaccinesTab(PatientResponse p, int specialistsDone, int specialistsTotal,
      int testsDone, int testsTotal) {
    final vaccines = p.vaccines;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftInfo(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: vaccines.isNotEmpty
                        ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: vaccines.length,
                      itemBuilder: (context, i) {
                        final v = vaccines[i];
                        return Card(
                          color: Colors.green.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.vaccines, color: Colors.green),
                            title: Text(v.title,
                                style: const TextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "Дата: ${v.date.day.toString().padLeft(2, '0')}.${v.date.month.toString().padLeft(2, '0')}.${v.date.year}",
                                style: const TextStyle(color: AppColors.primaryTextColor)),
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Text("Прививки не найдены",
                          style: TextStyle(color: AppColors.primaryTextColor)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: ElevatedButton(
                      onPressed: _showExamineDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryTextColor,
                        side: const BorderSide(color: AppColors.borderColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.edit, size: 30, color: AppColors.extraButtonColor),
                          SizedBox(height: 6),
                          Text(
                            "Добавить прививку",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.primaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ФЛГ
  Widget _buildFlgTab(PatientResponse p, int specialistsDone, int specialistsTotal,
      int testsDone, int testsTotal) {
    final flgs = p.flgs;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftInfo(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: flgs.isNotEmpty
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: flgs.length,
                    itemBuilder: (context, index) {
                      final f = flgs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(f.organization),
                          subtitle: Text("Номер: ${f.number}\nРезультат: ${f.result}"),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => AddFlgDialog(patientId: widget.patient.id),
                      );
                      if (result != null) setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit, size: 40, color: Colors.blue),
                        SizedBox(height: 6),
                        Text(
                          "Добавить ФЛГ",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => AddFlgDialog(patientId: widget.patient.id),
                    );
                    if (result != null) setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit, size: 40, color: Colors.black),
                      SizedBox(height: 6),
                      Text(
                        "Добавить ФЛГ",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Согласие
  Widget _buildConsentTab(PatientResponse p, int specialistsDone, int specialistsTotal,
      int testsDone, int testsTotal) {
    return Row(
      children: [
        _buildLeftInfo(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Center(
            child: Text(
              "Информированное согласие пациента пока не загружено.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 120,
          height: 120,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(8),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.edit, size: 40, color: Colors.blue),
                SizedBox(height: 6),
                Text(
                  "Добавить Соглашение",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _statusBadge(String label, bool hasData, [String? detail]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasData ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasData ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: hasData ? Colors.green.shade900 : Colors.red.shade900)),
          if (detail != null) ...[
            const SizedBox(width: 6),
            Text(detail, style: TextStyle(fontSize: 12, color: hasData ? Colors.green.shade700 : Colors.red.shade700)),
          ]
        ],
      ),
    );
  }
}

void showReceptionsDialog(BuildContext context, List<ReceptionResponse> receptions, PatientResponse patient) {
  showDialog(
    context: context,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      return AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: Text('Осмотр пациента ${patient.fullName}',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: SizedBox(
          width: screenWidth * 0.5,
          height: screenHeight * 0.25,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (receptions.isEmpty)
                  const Text(
                    "Нет доступных заключений.",
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                ...receptions.map((reception) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: screenWidth * 0.5 * 0.8, // 80% от ширины диалога
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: AppColors.secondaryTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          showReceptionFormDialog(context, reception); // Открываем форму
                        },
                        child: Text(
                          "Заключение врача: ${reception.specialization?.title ?? 'Без названия'}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),

                SizedBox(height: 8,),

                SizedBox(
                  width: screenWidth*0.5 * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnalysisScreen(
                            patient: patient,
                            analysisRepository: AnalysisRepository(
                                remoteService: AnalysisRemoteService(baseUrl: 'http://192.168.29.112:65322/api/v1'))
                        )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.secondaryTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                        "Медсестра"
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Закрыть",
              style: TextStyle(color: AppColors.primaryTextColor),
            ),
          ),
        ],
      );
    },
  );
}

/// Второй диалог — форма заключения
void showReceptionFormDialog(BuildContext context, ReceptionResponse reception) {
  showDialog(
    context: context,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      // Достаём поля формы (fields)
      final fieldsData = reception.template.fields;
      final fields = (fieldsData) as List;

      return AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Форма заключения: ${reception.specialization?.title ?? 'Врач'}",
          style: const TextStyle(color: AppColors.primaryTextColor),
        ),
        content: SizedBox(
          width: screenWidth * 0.75,
          height: screenHeight * 0.75,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.map((field) {
                final fieldName = field['name'] ?? '';
                final fieldTitle = field['title'] ?? '';
                final tag = field['tag'] ?? 'input';
                final value = reception.data[fieldName]?.toString() ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: TextEditingController(text: value),
                    keyboardType: tag == 'number'
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: fieldTitle,
                      labelStyle: const TextStyle(color: AppColors.hintColor),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.hintColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.hintColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.secondaryTextColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.secondaryTextColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: реализовать сохранение данных формы
              Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          ),
        ],
      );
    },
  );
}