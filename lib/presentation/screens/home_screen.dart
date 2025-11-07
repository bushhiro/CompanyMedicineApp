import 'package:flutter/material.dart';
import '../../../data/models/patient_group.dart'; // здесь твоя модель Organization
import '../../data/repositories/organization_repository_impl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_organization_card.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';
import '../../widgets/action_buttons.dart';
import '../screens/patient_group_screen.dart';

class HomeScreen extends StatefulWidget {
  final String doctorName;
  final int doctorId;

  const HomeScreen({super.key, required this.doctorName, required this.doctorId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final OrganizationRepository _repository;
  List<Organization> _allOrganizations = [];
  String _searchQuery = "";
  bool _isLoading = true; // <-- индикатор загрузки
  String? _error;

  @override
  void initState() {
    super.initState();

    _repository = OrganizationRepository(
      remoteService: OrganizationImpl(baseUrl: 'http://192.168.29.112:65322/api/v1'),
    );

    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orgs = await _repository.getOrganizations();
      if (mounted) {
        setState(() {
          _allOrganizations = orgs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _allOrganizations = [];
        });
      }
    }
  }

  List<Organization> _applyFilters() {
    if (_searchQuery.isEmpty) return _allOrganizations;
    return _allOrganizations
        .where((org) => org.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrganizations = _applyFilters();

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CustomAppBar(
        title: "Список организаций",
        subtitle: "Всего организаций: ${filteredOrganizations.length}",
        showDrawerButton: true,
        showSearchField: true,
        onSearch: (query) => setState(() {
          _searchQuery = query;
        }),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          ActionButtons(
            reloadOrganizations: _loadOrganizations,
            showRefresh: true,
            refreshLabel: "Обновить список",
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // <-- индикатор
                : _error != null
                ? Center(child: Text("Ошибка: $_error"))
                : filteredOrganizations.isEmpty
                ? const Center(child: Text("Организации не найдены"))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredOrganizations.length,
              itemBuilder: (context, index) {
                final org = filteredOrganizations[index];
                return OrganizationCard(
                  logo: Icons.local_hospital,
                  name: org.title,
                  onOpen: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientGroupsScreen(
                          organizationName: org.title,
                          organizationId: org.id.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}