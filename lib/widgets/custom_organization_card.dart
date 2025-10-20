import 'package:flutter/material.dart';
import 'package:work_app/theme/app_colors.dart';

import 'action_buttons.dart';

class OrganizationCard extends StatelessWidget {
  final String name;
  final String doctor;
  final String phone;
  final VoidCallback onOpen;
  final IconData logo;

  const OrganizationCard({
    this.logo = Icons.local_hospital,
    required this.name,
    required this.doctor,
    required this.phone,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 200; // например
    const double innerRatio = 0.3;

    return SizedBox(
      height: cardHeight,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Верхний блок (70%)
            Expanded(
              flex: ((1 - innerRatio) * 100).toInt(), // 70%
              child: Container(
                color: AppColors.primaryColor,
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(logo, size: 60, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 30),
                    ActionButtons(
                      showOpen: true,
                      onOpen: onOpen,
                      buttonSize: const Size(200, 60), // обратите внимание на имя параметра: buttonSize
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: (innerRatio * 100).toInt(), // 30%
              child: Container(
                color: AppColors.backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Врач организации: $doctor",
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}