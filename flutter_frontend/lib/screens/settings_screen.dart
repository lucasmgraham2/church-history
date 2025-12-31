import 'package:flutter/material.dart';
import 'package:church_history_explorer/services/auth_service.dart';
import 'package:church_history_explorer/services/settings_service.dart';
import 'package:church_history_explorer/screens/login_screen.dart';

// Convert to StatefulWidget
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Add state variables
  final SettingsService _settingsService = SettingsService();
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings from the service
  Future<void> _loadSettings() async {
    final notifications = await _settingsService.areNotificationsEnabled();
    final theme = await _settingsService.getThemeMode();
    setState(() {
      _notificationsEnabled = notifications;
      _themeMode = theme;
      _isLoading = false;
    });
  }

  // Helper function to show a feature that is coming soon
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon!')),
    );
  }
  
  // Helper function to get theme name as a string
  String get _themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
      default:
        return 'System Default';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper function to create list tiles for settings
    Widget buildSettingsTile({
      required String title,
      required IconData icon,
      required VoidCallback onTap,
      String? subtitle,
    }) {
      return ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      // Show loading indicator while settings are loaded
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Loading...'),
                ],
              ),
            )
          : ListView(
              children: [
                const SizedBox(height: 16),
                // Account Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                buildSettingsTile(
                  title: 'Change Password',
                  icon: Icons.lock_outline,
                  onTap: _showComingSoon,
                ),
                const Divider(),

                // Preferences Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (bool value) async {
                    await _settingsService.setNotificationsEnabled(value);
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifications ${value ? "enabled" : "disabled"}'),
                      ),
                    );
                  },
                ),
                buildSettingsTile(
                  title: 'Appearance',
                  subtitle: _themeModeName,
                  icon: Icons.palette_outlined,
                  onTap: () {
                    // Show a dialog to change the theme
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Choose Theme'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<ThemeMode>(
                              title: const Text('Light Mode'),
                              value: ThemeMode.light,
                              groupValue: _themeMode,
                              onChanged: (ThemeMode? value) async {
                                if (value != null) {
                                  await _settingsService.setThemeMode(value);
                                  setState(() => _themeMode = value);
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('Dark Mode'),
                              value: ThemeMode.dark,
                              groupValue: _themeMode,
                              onChanged: (ThemeMode? value) async {
                                if (value != null) {
                                  await _settingsService.setThemeMode(value);
                                  setState(() => _themeMode = value);
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('System Default'),
                              value: ThemeMode.system,
                              groupValue: _themeMode,
                              onChanged: (ThemeMode? value) async {
                                if (value != null) {
                                  await _settingsService.setThemeMode(value);
                                  setState(() => _themeMode = value);
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),

                // About Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                buildSettingsTile(
                  title: 'About Church History Explorer',
                  icon: Icons.info_outline,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Church History Explorer',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Church History Explorer',
                    );
                  },
                ),
                const Divider(),
                
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await AuthService().logout();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
    );
  }
}