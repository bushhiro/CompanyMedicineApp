import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;             // опциональный подзаголовок
  final bool showDrawerButton;
  final bool showBackButton;          // опциональная кнопка назад
  final VoidCallback? onBack;         // обработчик кнопки назад
  final bool showSearchField;         // показывать кнопку поиска и поле
  final Function(String)? onSearch;   // колбек при вводе текста
  final bool showDownloadAll;         // показывать кнопку "Скачать все"
  final VoidCallback? onDownloadAll;
  final bool showAddPatient;// обработчик кнопки "Скачать все"
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
    this.showDrawerButton =true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      elevation: 2,
      foregroundColor: Colors.black,
      titleSpacing: 0,
      title: Row(
        children: [
          if (widget.showDrawerButton)
            IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),

          // Кнопка назад (опционально)
          if (widget.showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            ),

          // Заголовок или поле поиска
          Expanded(
            child: _isSearching && widget.showSearchField
                ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Поиск...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: widget.onSearch,
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleColor,
                  ),
                ),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.hintColor,
                    ),
                  ),
              ],
            ),
          ),

          // Кнопка поиска (если поле опционально)
          if (widget.showSearchField)
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    widget.onSearch?.call("");
                  }
                });
              },
            ),

          // Кнопка "Скачать все" (опционально, справа)
          if (widget.showDownloadAll)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: widget.onDownloadAll,
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Скачать все"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),

          if (widget.showAddPatient)
            IconButton(onPressed: widget.onAddPatient, icon: Icon(Icons.person_add))
        ],
      ),
    );
  }
}