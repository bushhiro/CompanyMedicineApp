import 'package:flutter/material.dart';
import 'package:work_app/theme/app_colors.dart';

import 'action_buttons.dart';

class OrganizationCard extends StatelessWidget {
  final String name;
  final VoidCallback onOpen;
  final IconData logo;

  const OrganizationCard({
    this.logo = Icons.local_hospital,
    required this.name,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 150;

    return SizedBox(
      height: cardHeight,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.borderColor,
            width: 2,
          )
        ),
        child: Column(
          children: [
            Expanded(
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
          ],
        ),
      ),
    );
  }
}