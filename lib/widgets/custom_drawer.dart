import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/routes.dart';
import '../theme/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Удаляем токен и возможные другие данные
    await prefs.remove('token');
    await prefs.remove('doctor_id');
    await prefs.remove('organization_id');

    // Очищаем весь кеш, если требуется полное обнуление сессии
    // await prefs.clear();

    // Возврат на экран авторизации
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login, // экран авторизации
            (route) => false, // очистка истории навигации
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryColor,
      child: Column(
        children: [
          // --- Заголовок Drawer ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryColor,
            child: Row(
              children: [
                // Лого (заглушка)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business, // заглушка логотипа
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Квант.ВОП",
                    style: TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.buttonColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Контент Drawer ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Выездной осмотр",
                style: TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.folder, color: AppColors.buttonColor),
            title: const Text(
              "Список организаций",
              style: TextStyle(color: AppColors.primaryTextColor, fontSize: 12),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.buttonColor),
            title: const Text(
              "Скачанные списки",
              style: TextStyle(color: AppColors.primaryTextColor, fontSize: 12),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.downloadedLists);
            },
          ),

          const Spacer(),


          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.exit_to_app, color: AppColors.buttonColor),
              title: const Text(
                "Выйти",
                style: TextStyle(color: AppColors.buttonColor, fontSize: 15),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    title: const Text("Выход из аккаунта",),
                    content: const Text("Вы действительно хотите выйти из аккаунта?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Отмена", style: TextStyle(color: AppColors.buttonColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Выйти", style: TextStyle(color: AppColors.buttonColor)),
                      ),
                    ],
                  )
                );
                if (confirm!) await _logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}