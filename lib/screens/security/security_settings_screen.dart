// Security Settings Screen for Signal NCO EW
// Allows users to configure PIN, biometric, and session timeout

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants.dart';
import '../../services/security_service.dart';
import 'pin_lock_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final SecurityService _security = SecurityService.instance;
  bool _canUseBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final canUse = await _security.canUseBiometric();
    if (mounted) {
      setState(() => _canUseBiometric = canUse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _security,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('ความปลอดภัย'),
            backgroundColor: AppColors.surface,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security status card
                _buildStatusCard(),
                const SizedBox(height: 24),

                // PIN Lock section
                _buildSectionTitle('ล็อกแอปพลิเคชัน'),
                const SizedBox(height: 12),
                _buildPinSection(),
                const SizedBox(height: 24),

                // Session timeout section
                _buildSectionTitle('หมดเวลาเซสชัน'),
                const SizedBox(height: 12),
                _buildSessionTimeoutSection(),
                const SizedBox(height: 24),

                // Info section
                _buildInfoSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    final isPinEnabled = _security.isPinEnabled;
    final statusColor = isPinEnabled ? AppColors.success : AppColors.warning;
    final statusText = isPinEnabled ? 'ปลอดภัย' : 'ไม่ได้ตั้งค่า';
    final statusIcon = isPinEnabled ? Icons.shield : Icons.shield_outlined;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.2),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สถานะความปลอดภัย',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isPinEnabled) ...[
                  const SizedBox(height: 4),
                  Text(
                    'แนะนำให้ตั้งรหัส PIN เพื่อป้องกันข้อมูล',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPinSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // PIN toggle
          SwitchListTile(
            title: Text(
              'เปิดใช้รหัส PIN',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'ล็อกแอปด้วยรหัส PIN 4 หลัก',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pin, color: AppColors.primary, size: 24),
            ),
            value: _security.isPinEnabled,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
            onChanged: (value) => _togglePin(value),
          ),

          if (_security.isPinEnabled) ...[
            const Divider(height: 1, indent: 56),

            // Change PIN
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.edit, color: AppColors.warning, size: 24),
              ),
              title: Text(
                'เปลี่ยนรหัส PIN',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: _changePin,
            ),

            // Biometric (mobile only)
            if (_canUseBiometric && !kIsWeb) ...[
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                title: Text(
                  'สแกนลายนิ้วมือ / Face ID',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'ใช้ไบโอเมตริกแทนรหัส PIN',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fingerprint,
                      color: AppColors.success, size: 24),
                ),
                value: _security.isBiometricEnabled,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
                onChanged: (value) => _toggleBiometric(value),
              ),
            ],
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildSessionTimeoutSection() {
    final timeoutMinutes = _security.sessionTimeoutMinutes;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.timer, color: AppColors.primary, size: 24),
            ),
            title: Text(
              'ล็อกอัตโนมัติหลังไม่ใช้งาน',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              timeoutMinutes == 0
                  ? 'ปิดใช้งาน'
                  : '$timeoutMinutes นาที',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: _showTimeoutPicker,
            enabled: _security.isPinEnabled,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'เกี่ยวกับความปลอดภัย',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoItem(text: 'ข้อมูลความก้าวหน้าถูกเข้ารหัสเก็บในเครื่อง'),
          _InfoItem(text: 'รหัส PIN ถูกเข้ารหัสด้วย SHA-256'),
          _InfoItem(text: 'ใส่ PIN ผิด 5 ครั้งจะถูกล็อก 5 นาที'),
          if (!kIsWeb)
            _InfoItem(text: 'รองรับสแกนลายนิ้วมือและ Face ID'),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  // ============== Actions ==============

  Future<void> _togglePin(bool enable) async {
    if (enable) {
      // Navigate to PIN setup
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinLockScreen(
            mode: PinScreenMode.setup,
            onPinSet: () {
              Navigator.pop(context);
              _showSnackBar('ตั้งรหัส PIN เรียบร้อยแล้ว');
            },
          ),
        ),
      );
    } else {
      // Confirm before disabling
      final confirmed = await _showConfirmDialog(
        'ปิดรหัส PIN',
        'คุณต้องการปิดรหัส PIN หรือไม่?\nข้อมูลจะยังคงถูกเข้ารหัส',
      );
      if (confirmed == true) {
        await _security.disablePin();
        _showSnackBar('ปิดรหัส PIN แล้ว');
      }
    }
  }

  Future<void> _changePin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinLockScreen(
          mode: PinScreenMode.setup,
          onPinSet: () {
            Navigator.pop(context);
            _showSnackBar('เปลี่ยนรหัส PIN เรียบร้อยแล้ว');
          },
        ),
      ),
    );
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (enable) {
      // Test biometric first
      final success = await _security.authenticateWithBiometric();
      if (success) {
        await _security.enableBiometric();
        _showSnackBar('เปิดใช้ไบโอเมตริกแล้ว');
      } else {
        _showSnackBar('ไม่สามารถยืนยันไบโอเมตริกได้');
      }
    } else {
      await _security.disableBiometric();
      _showSnackBar('ปิดไบโอเมตริกแล้ว');
    }
  }

  void _showTimeoutPicker() {
    final options = [
      {'label': 'ปิดใช้งาน', 'value': 0},
      {'label': '1 นาที', 'value': 1},
      {'label': '5 นาที', 'value': 5},
      {'label': '15 นาที', 'value': 15},
      {'label': '30 นาที', 'value': 30},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          'ล็อกอัตโนมัติ',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final isSelected =
                _security.sessionTimeoutMinutes == option['value'];
            return ListTile(
              title: Text(
                option['label'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                _security.setSessionTimeout(option['value'] as int);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String text;

  const _InfoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
