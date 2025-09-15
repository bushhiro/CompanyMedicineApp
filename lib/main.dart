import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список организаций',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // тестовые данные
  final List<Map<String, String>> organizations = List.generate(10, (index) {
    return {
      'name': 'Компания №${index + 1}',
      'doctor': 'Доктор Иванов',
      'phone': '123-45-67'
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            // Синяя шапка
            Container(
              height: 100,
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.business, size: 28, color: Colors.blue),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Квант.ВОП',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Список пунктов
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'Выездной осмотр',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Список организаций с hover
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade200,
                      onTap: () {
                        Navigator.pop(context); // закрыть Drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DownloadedListsPage(),
                          ),
                        );
                      },
                      child: const ListTile(
                        leading: Icon(Icons.download),
                        title: Text('Скаченные списки'),
                      ),
                    ),
                  ),
                  //  списки с hover
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      hoverColor: Colors.grey.shade300,
                      onTap: () {},
                      child: const ListTile(
                        leading: Icon(Icons.download),
                        title: Text('Скачанные списки'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка "Выйти" внизу
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
              onTap: null, // пока без функционала
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Поиск...",
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 16),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Список организаций",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Всего организаций: ${organizations.length}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              child: const Text("Обновить список"),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: organizations.length,
              itemBuilder: (context, index) {
                final org = organizations[index];
                return Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.business, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                org['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text("Открыть"),
                            ),
                          ],
                        ),
                      ),
                      // Нижняя затемнённая область
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E2E2E), // тёмно-серый фон
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Врач: ${org['doctor']!}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Телефон: ${org['phone']!}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Внутри main.dart или отдельного файлао
class DownloadedListsPage extends StatelessWidget {
  const DownloadedListsPage({super.key});

  // Тестовые данные
  final List<Map<String, String>> downloadedLists = const [
    {
      'number': '1',
      'date': '15.09.2025 12:00:00',
      'organization': 'Компания №1',
    },
    {
      'number': '2',
      'date': '14.09.2025 10:30:45',
      'organization': 'Компания №2',
    },
    {
      'number': '3',
      'date': '12.09.2025 09:15:12',
      'organization': 'Компания №3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Скачанные списки',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: downloadedLists.length,
        itemBuilder: (context, index) {
          final listItem = downloadedLists[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Левая часть с текстом в столбик
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Список на прохождение медосмотра No. ${listItem['number']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Дата создания: ${listItem['date']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Организация: ${listItem['organization']}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Правая часть с кнопками в столбик, одинаковой ширины
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(160, 50), // увеличенная ширина и высота
                      ),
                      child: const Text('Выгрузить в 1С'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(160, 50), // та же ширина и высота
                      ),
                      child: const Text('Открыть'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}