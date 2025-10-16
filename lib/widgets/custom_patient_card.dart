import 'package:flutter/material.dart';
import '../../data/models/patient.dart';

/// Карточка одного пациента внутри списка группы.
/// Отображает вкладки: Общая информация, Прививки, ФЛГ, Согласие.
class CustomPatientCard extends StatefulWidget {
  final PatientResponse patient;
  final VoidCallback onContact;
  final VoidCallback onExamine;

  const CustomPatientCard({
    super.key,
    required this.patient,
    required this.onContact,
    required this.onExamine,
  });

  @override
  State<CustomPatientCard> createState() => _CustomPatientCardState();
}

class _CustomPatientCardState extends State<CustomPatientCard> {
  @override
  Widget build(BuildContext context) {
    final p = widget.patient;

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
              height: 280,
              child: TabBarView(
                children: [
                  _buildGeneralInfoTab(p),
                  _buildVaccinesTab(p),
                  _buildFlgTab(p),
                  _buildConsentTab(p),
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

  // ======== ВКЛАДКА: ОБЩАЯ ИНФОРМАЦИЯ ========
  Widget _buildGeneralInfoTab(PatientResponse p) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _infoRow("ФИО", p.fullName),
        _infoRow(
          "Дата рождения",
          "${p.birthDate.day.toString().padLeft(2, '0')}.${p.birthDate.month.toString().padLeft(2, '0')}.${p.birthDate.year}",
        ),
        _infoRow("Возраст", "${p.age} лет"),
        _infoRow("Пол", p.isMale ? "Мужской" : "Женский"),
        _infoRow("Должность", p.position),
        _infoRow("Подразделение", p.division),
        const Divider(),
        _infoRow("Телефон", p.contactInfo.phone),
        _infoRow("Email", p.contactInfo.email),
        _infoRow("Адрес", p.contactInfo.address),
      ],
    );
  }

  // ======== ВКЛАДКА: ПРИВИВКИ ========
  Widget _buildVaccinesTab(PatientResponse p) {
    if (p.vaccines == null || p.vaccines!.isEmpty) {
      return const Center(child: Text("Нет данных о прививках"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: p.vaccines!.length,
      itemBuilder: (context, index) {
        final v = p.vaccines![index];
        return ListTile(
          leading: const Icon(Icons.vaccines, color: Colors.blue),
          title: Text(v.title),
          subtitle: Text(
            "Дата: ${v.date.day.toString().padLeft(2, '0')}.${v.date.month.toString().padLeft(2, '0')}.${v.date.year}",
          ),
        );
      },
    );
  }

  // ======== ВКЛАДКА: ФЛГ ========
  Widget _buildFlgTab(PatientResponse p) {
    if (p.flg == null) {
      return const Center(child: Text("Нет данных о ФЛГ"));
    }

    final flg = p.flg!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Номер", flg.number),
          _infoRow("Результат", flg.result),
          _infoRow("Организация", flg.organization),
          _infoRow("Выполнено", flg.isCompleted ? "Да" : "Нет"),
        ],
      ),
    );
  }

  // ======== ВКЛАДКА: СОГЛАСИЕ ========
  Widget _buildConsentTab(PatientResponse p) {
    return const Center(
      child: Text(
        "Информированное согласие пациента пока не загружено.",
        style: TextStyle(fontSize: 13, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ======== УТИЛИТА ДЛЯ ВЫВОДА ПОЛЕЙ ========
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}