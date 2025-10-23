import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_app/ui/dialogs/refusal_form_dialog.dart';
import 'package:work_app/ui/dialogs/titres_form_dialog.dart';
import 'package:work_app/ui/dialogs/vaccination_form_dialog.dart';

import '../../theme/app_colors.dart';
import 'exemption_form_dialog.dart';

class AddVaccinationDialog extends StatelessWidget {
  const AddVaccinationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryColor,
      title: const Text("Выберите действие"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, "Добавить прививку", _showAddVaccinationForm),
          _buildOption(context, "Добавить титры", _showAddTitresForm),
          _buildOption(context, "Добавить отказ", _showAddRefusalForm),
          _buildOption(context, "Добавить медотвод", _showAddExemptionForm),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, Function(BuildContext) onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => onTap(context),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 45),
          backgroundColor: AppColors.buttonColor
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryTextColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- Диалоги ---
  void _showAddVaccinationForm(BuildContext context) {
    showDialog(context: context, builder: (_) => const VaccinationFormDialog());
  }

  void _showAddTitresForm(BuildContext context) {
    showDialog(context: context, builder: (_) => const TitresFormDialog());
  }

  void _showAddRefusalForm(BuildContext context) {
    showDialog(context: context, builder: (_) => const RefusalFormDialog());
  }

  void _showAddExemptionForm(BuildContext context) {
    showDialog(context: context, builder: (_) => const ExemptionFormDialog());
  }
}