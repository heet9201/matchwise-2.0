import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/feedback_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';
  bool _notificationsEnabled = true;
  bool _hapticsEnabled = true;
  bool _soundsEnabled = true;
  double _detectionSensitivity = 0.8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFeedbackSettings();
  }

  Future<void> _loadFeedbackSettings() async {
    setState(() {
      _hapticsEnabled = feedbackService.hapticsEnabled;
      _soundsEnabled = feedbackService.soundsEnabled;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Account'),
            Tab(text: 'Preferences'),
            Tab(text: 'Privacy'),
            Tab(text: 'Help'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountTab(),
          _buildPreferencesTab(),
          _buildPrivacyTab(),
          _buildHelpTab(),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryGreen,
                child: Text(
                  'JD',
                  style: AppTypography.h2(color: AppColors.textWhite),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'John Doe',
                style: AppTypography.h4(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'john.doe@example.com',
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoCard('Phone', '+1 234 567 8900'),
        _buildInfoCard('Member Since', 'January 2024'),
        _buildInfoCard('Total Comparisons', '47'),
      ],
    );
  }

  Widget _buildPreferencesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPreferenceSection(
          'Language',
          DropdownButton<String>(
            value: _selectedLanguage,
            isExpanded: true,
            items: ['English', 'Spanish', 'French', 'German']
                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: (value) => setState(() => _selectedLanguage = value!),
            underline: const SizedBox(),
          ),
        ),
        _buildPreferenceSection(
          'Theme',
          DropdownButton<String>(
            value: _selectedTheme,
            isExpanded: true,
            items: ['Light', 'Dark', 'Auto']
                .map((theme) =>
                    DropdownMenuItem(value: theme, child: Text(theme)))
                .toList(),
            onChanged: (value) => setState(() => _selectedTheme = value!),
            underline: const SizedBox(),
          ),
        ),
        _buildPreferenceSection(
          'Notifications',
          SizedBox(
            height: 24,
            child: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                feedbackService.toggle();
                setState(() => _notificationsEnabled = value);
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
        ),
        _buildPreferenceSection(
          'Haptic Feedback',
          SizedBox(
            height: 24,
            child: Switch(
              value: _hapticsEnabled,
              onChanged: (value) async {
                await feedbackService.toggle();
                await feedbackService.setHapticsEnabled(value);
                setState(() => _hapticsEnabled = value);
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
        ),
        _buildPreferenceSection(
          'Sound Effects',
          SizedBox(
            height: 24,
            child: Switch(
              value: _soundsEnabled,
              onChanged: (value) async {
                await feedbackService.toggle();
                await feedbackService.setSoundsEnabled(value);
                setState(() => _soundsEnabled = value);
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Auto-Detection Sensitivity',
          style: AppTypography.bodyMedium(color: AppColors.textPrimary)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _detectionSensitivity,
          onChanged: (value) => setState(() => _detectionSensitivity = value),
          activeColor: AppColors.primaryGreen,
          min: 0.5,
          max: 1.0,
        ),
        Text(
          '${(_detectionSensitivity * 100).toInt()}% confidence threshold',
          style: AppTypography.small(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPreferenceSection(
          'Data Retention',
          DropdownButton<String>(
            value: '30 days',
            isExpanded: true,
            items: ['7 days', '30 days', '90 days', 'Forever']
                .map((period) =>
                    DropdownMenuItem(value: period, child: Text(period)))
                .toList(),
            onChanged: (value) {},
            underline: const SizedBox(),
          ),
        ),
        _buildPreferenceSection(
          'Share Analytics',
          SizedBox(
            height: 24,
            child: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.detailBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Export My Data'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Delete Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHelpItem('View Tutorial', Icons.school_outlined, onTap: () {
          context.push(RouteNames.onboarding);
        }),
        _buildHelpItem('FAQ', Icons.help_outline),
        _buildHelpItem('Contact Support', Icons.support_agent),
        _buildHelpItem('Report Bug', Icons.bug_report),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Text(
                'Version ${AppConstants.appVersion}',
                style: AppTypography.small(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: Oct 2025',
                style: AppTypography.caption(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(String label, Widget control) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.body(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: control,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(
          title,
          style: AppTypography.body(color: AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap ?? () {},
      ),
    );
  }
}
