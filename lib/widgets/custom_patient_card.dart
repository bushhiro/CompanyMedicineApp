import 'package:flutter/material.dart';
import '../../data/models/patient.dart';
import '../data/models/analysis.dart';
import '../data/models/reception.dart';
import '../theme/app_colors.dart';
import '../ui/dialogs/add_flg_dialog.dart';
import '../ui/dialogs/add_vaccination_dialog.dart';
import 'action_buttons.dart';


class CustomPatientCard extends StatefulWidget {
  final PatientResponse patient;

  const CustomPatientCard({
    super.key,
    required this.patient,
  });

  @override
  State<CustomPatientCard> createState() => _CustomPatientCardState();
}

class _CustomPatientCardState extends State<CustomPatientCard> {
  final GlobalKey _specialistsButtonKey = GlobalKey();
  final GlobalKey _analysisButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

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
      builder: (_) => const AddVaccinationDialog(),
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

    final items = forSpecialists
        ? widget.patient.receptions ?? <ReceptionResponse>[]
        : widget.patient.analysisOrder.orderItems ?? [];

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
              top: offset.dy-10 + size.height,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map<Widget>((item) {
                      if (forSpecialists && item is ReceptionResponse) {
                        final title = item.specialization?.title ?? "Неизвестно";
                        final done = item.isCompleted;
                        return _buildOverlayRow(title, done);
                      } else if (!forSpecialists) {
                        final analysisItem = item as AnalysisOrderItemResponse;
                        final title = analysisItem.analysis.title;
                        final done = analysisItem.isCompleted;
                        return _buildOverlayRow(title, done);
                      }
                      return const SizedBox.shrink();
                    }).toList(),
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
    final specialistsTotal = p.specializations?.length ?? 0;
    final specialistsDone =
        p.receptions?.where((r) => r.isCompleted).length ?? 0;
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
                      onOpen: () => Navigator.pop(context),
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
          Text(
            p.fullName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            softWrap: true,
          ),
          const SizedBox(height: 2),
          const Text(
            "Основное",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
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
              textStyle: TextStyle(fontSize: 12),
              iconColor: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            key: _analysisButtonKey,
            onPressed: () => _toggleOverlay(forSpecialists: false),
            icon: const Icon(Icons.science, size: 18),
            label: Text("Анализы $testsDone/$testsTotal",
                style: TextStyle(color: AppColors.primaryTextColor)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 32),
                textStyle: const TextStyle(fontSize: 12),
                iconColor: AppColors.primaryTextColor
            ),
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusBadge("ФЛГ", p.flg != null, p.flg?.result),
                _statusBadge(
                  "Прививки",
                  p.vaccines != null && p.vaccines!.isNotEmpty,
                  p.vaccines != null && p.vaccines!.isNotEmpty
                      ? "${p.vaccines!.length} шт."
                      : null,
                ),
                if (p.analysisOrder.orderItems.isNotEmpty)
                  ...p.analysisOrder.orderItems.map((item) {
                    final title = item.analysis.title;
                    final done = item.isCompleted;
                    return _statusBadge(title, done, done ? "✓" : "✗");
                  })
                else
                  _statusBadge("Анализы", false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Прививки
  Widget _buildVaccinesTab(PatientResponse p, int specialistsDone, int specialistsTotal,
      int testsDone, int testsTotal) {
    final vaccines = p.vaccines ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Левая панель с общей информацией
        _buildLeftInfo(p, specialistsDone, specialistsTotal, testsDone, testsTotal),
        // Правая часть вкладки Прививки
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vaccines.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Список прививок
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vaccines.length,
                          itemBuilder: (context, i) {
                            final v = vaccines[i];
                            return Card(
                              color: Colors.green.shade50,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.vaccines, color: Colors.green),
                                title: Text(v.title),
                                subtitle: Text(
                                    "Дата: ${v.date.day.toString().padLeft(2, '0')}.${v.date.month.toString().padLeft(2, '0')}.${v.date.year}"),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Кнопка "Добавить прививку"
                      Padding(
                        padding: const EdgeInsets.only(top: 55),
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: ElevatedButton(
                            onPressed: _showExamineDialog, // вызываем метод
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.hintColor,
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
                  )
                else
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ElevatedButton(
                        onPressed: _showExamineDialog, // вызываем метод
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.hintColor,
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
    final flg = p.flg;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Левая панель с общей информацией
        _buildLeftInfo(p, 0, 0, 0, 0),
        // Правая часть вкладки ФЛГ
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 75, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (flg != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Текст информации о ФЛГ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow("Организация", flg.organization),
                            _infoRow("Номер", flg.number),
                            _infoRow("Результат", flg.result),
                          ],
                        ),
                      ),
                      // Кнопка "Добавить ФЛГ"
                      SizedBox(
                        width: 120, // квадратная форма
                        height: 120,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => const AddFlgDialog(),
                            );

                            if (result != null) {
                              print("Добавлено ФЛГ: $result");
                              // TODO: реализовать сохранение результата через API
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey, width: 1), // тонкий серый бордер
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // слегка скруглённая
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
                else
                // Если ФЛГ нет, просто показываем кнопку по центру
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          // Обработчик добавления ФЛГ
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
              ],
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
          _buildLeftInfo(widget.patient, 0, 0, 0, 0),
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
            width: 120, // квадратная форма
            height: 120,
            child: ElevatedButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => const AddFlgDialog(),
                );

                if (result != null) {
                  print("Добавлено Соглашение: $result");
                  // TODO: реализовать сохранение результата через API
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey, width: 1), // тонкий серый бордер
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // слегка скруглённая
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 130,
              child:
              Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16),)),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, bool hasData, [String? detail]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasData ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasData ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: hasData ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
          if (detail != null && detail.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              detail,
              style: TextStyle(
                fontSize: 12,
                color: hasData ? Colors.green.shade700 : Colors.red.shade700,
              ),
            )
          ]
        ],
      ),
    );
  }
}
