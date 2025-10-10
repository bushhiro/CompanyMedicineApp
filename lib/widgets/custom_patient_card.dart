import 'package:flutter/material.dart';

/// Карточка одного пациента внутри списка группы.
/// Адаптирована для экрана PatientsListScreen.
class CustomPatientCard extends StatefulWidget {
  final String fullName;
  final String position;
  final String workplace;
  final String birthDate;
  final int age;
  final int specialistsDone;
  final int specialistsTotal;
  final int testsDone;
  final int testsTotal;
  final VoidCallback onContact;
  final VoidCallback onExamine;
  final List<Map<String, dynamic>> specialists;

  const CustomPatientCard({
    super.key,
    required this.fullName,
    required this.position,
    required this.workplace,
    required this.birthDate,
    required this.age,
    required this.specialistsDone,
    required this.specialistsTotal,
    required this.testsDone,
    required this.testsTotal,
    required this.onContact,
    required this.onExamine,
    required this.specialists,
  });

  @override
  State<CustomPatientCard> createState() => _CustomPatientCardState();
}

class _CustomPatientCardState extends State<CustomPatientCard> {
  final GlobalKey _specialistsButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _showSpecialistsPanel = false;

  void _toggleSpecialistsPanel() {
    if (_showSpecialistsPanel) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final renderBox =
    _specialistsButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: 400,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.specialists
                        .map(
                          (s) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                s["title"],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              s["status"] ? "Пройдено" : "Не пройдено",
                              style: TextStyle(
                                color: s["status"]
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _showSpecialistsPanel = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showSpecialistsPanel = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Общая инфо"),
                Tab(text: "Прививки"),
                Tab(text: "ФЛГ"),
                Tab(text: "Согласие"),
              ],
            ),
            SizedBox(
              height: 270,
              child: TabBarView(
                children: [
                  _buildTabContent(showVaccinationButton: false, title: "Общая информация"),
                  _buildTabContent(showVaccinationButton: true, title: "Прививки пациента"),
                  _buildTabContent(showVaccinationButton: false, title: "Флюорография"),
                  _buildTabContent(showVaccinationButton: false, title: "Информированное согласие"),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onContact,
                      child: const Text("Контактные данные"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onExamine,
                      child: const Text("Осмотреть"),
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

  Widget _buildTabContent({required String title, bool showVaccinationButton = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Левая панель: краткая инфо о пациенте
        Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.fullName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  softWrap: true),
              const SizedBox(height: 4),
              Text(widget.position,
                  style: const TextStyle(fontSize: 14), softWrap: true),
              const SizedBox(height: 4),
              Text(widget.workplace,
                  style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Text("Дата рождения: ${widget.birthDate}",
                  style: const TextStyle(fontSize: 12)),
              Text("Возраст: ${widget.age}",
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                key: _specialistsButtonKey,
                onPressed: _toggleSpecialistsPanel,
                icon: const Icon(Icons.person, size: 18),
                label: Text(
                    "Специалисты ${widget.specialistsDone}/${widget.specialistsTotal}"),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.science, size: 18),
                label: Text(
                    "Анализы ${widget.testsDone}/${widget.testsTotal}"),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        // Правая часть: контент вкладки
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Text(title, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}