import 'package:flutter/material.dart';
import 'package:church_history_explorer/services/auth_service.dart';
import 'package:church_history_explorer/services/church_history_service.dart';
import 'package:church_history_explorer/screens/login_screen.dart';
import 'package:church_history_explorer/screens/settings_screen.dart';
import 'package:church_history_explorer/screens/era_detail_screen.dart';
import 'package:church_history_explorer/screens/ai_assistant_screen.dart';
import 'package:church_history_explorer/models/church_history_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _historyService = ChurchHistoryService();
  Map<String, dynamic>? _userProfile;
  List<ChurchHistoryEra> _eras = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userResult = await _authService.getCurrentUser();
    final historyResult = await _historyService.getChurchHistory();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (userResult['success']) {
          _userProfile = userResult['data'];
        }
        if (historyResult['success']) {
          _eras = historyResult['eras'] as List<ChurchHistoryEra>;
        }
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  List<ChurchHistoryEra> get _filteredEras {
    if (_searchQuery.isEmpty) return _eras;
    return _eras.where((era) {
      return era.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          era.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church History Explorer'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search church history...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Eras list
                Expanded(
                  child: _filteredEras.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No history data available'
                                    : 'No results found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEras.length,
                          itemBuilder: (context, index) {
                            final era = _filteredEras[index];
                            return _buildEraCard(context, era);
                          },
                        ),
                ),
              ],
            ),
      // Floating Action Button for AI Assistant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AiAssistantScreen(),
            ),
          );
        },
        label: const Text('Ask AI'),
        icon: const Icon(Icons.smart_toy),
        tooltip: 'Ask the Church History AI Assistant',
      ),
    );
  }

  Widget _buildEraCard(BuildContext context, ChurchHistoryEra era) {
    final eraColor = _hexToColor(era.color);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EraDetailScreen(era: era),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                eraColor.withOpacity(0.2),
                eraColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: eraColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and year range
                Row(
                  children: [
                    Icon(
                      Icons.church,
                      color: eraColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            era.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: eraColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${era.startYear} - ${era.endYear}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: eraColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: eraColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  era.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Event count
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 18,
                      color: eraColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${era.events.length} events',
                      style: TextStyle(
                        fontSize: 13,
                        color: eraColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}