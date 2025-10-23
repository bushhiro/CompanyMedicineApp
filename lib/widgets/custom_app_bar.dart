import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showDrawerButton;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showSearchField;
  final Function(String)? onSearch;
  final bool showDownloadAll;
  final VoidCallback? onDownloadAll;
  final bool showAddPatient;
  final VoidCallback? onAddPatient;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.showSearchField = false,
    this.onSearch,
    this.showDownloadAll = false,
    this.onDownloadAll,
    this.showAddPatient = false,
    this.onAddPatient,
    this.showDrawerButton = true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      titleSpacing: 0,
      title: Row(
        children: [
          if (widget.showDrawerButton)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (widget.showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            ),

          // Заголовок слева
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleColor),
                ),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.hintColor),
                  ),
              ],
            ),
          ),

          // Поле поиска справа
          if (widget.showSearchField)
            SizedBox(
              width: 400,
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearch,
                decoration: InputDecoration(
                  hintText: "Поиск...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

          if (widget.showDownloadAll)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ElevatedButton.icon(
                onPressed: widget.onDownloadAll,
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Скачать все"),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),

          if (widget.showAddPatient)
            IconButton(
              onPressed: widget.onAddPatient,
              icon: const Icon(Icons.person_add),
            ),
        ],
      ),
    );
  }
}