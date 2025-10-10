import 'package:flutter/material.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(logo, size: 40, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(name,
                      style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(onPressed: onOpen, child: const Text("Открыть")),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text("Врач организации: $doctor")),
                Text(phone, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}