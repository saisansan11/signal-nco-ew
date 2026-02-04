import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/constants.dart';

/// EW Mission Planner Widget - ฝึกวางแผนภารกิจ EW จริง
/// รวม ES, EA, EP concepts เข้าด้วยกัน
/// เรียนรู้การตัดสินใจในสถานการณ์จำลอง
class EWMissionPlannerWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const EWMissionPlannerWidget({super.key, this.onComplete});

  @override
  State<EWMissionPlannerWidget> createState() => _EWMissionPlannerWidgetState();
}

class _EWMissionPlannerWidgetState extends State<EWMissionPlannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _signalController;

  // Mission state
  MissionPhase _currentPhase = MissionPhase.planning;
  int _missionScore = 0;
  int _currentScenarioIndex = 0;

  // Assets
  final List<FriendlyAsset> _friendlyAssets = [];
  final List<EnemyEmitter> _enemyEmitters = [];

  // Player decisions
  final Map<String, bool> _esDecisions = {};
  final Map<String, bool> _eaDecisions = {};
  final Map<String, bool> _epDecisions = {};

  // Scenario
  late MissionScenario _currentScenario;

  final List<MissionScenario> _scenarios = [
    MissionScenario(
      id: 'scenario_1',
      name: 'ภารกิจลาดตระเวน',
      description: 'หน่วยลาดตระเวนต้องเคลื่อนผ่านพื้นที่ที่มีเรดาร์ข้าศึก',
      briefing: '''
ภารกิจ: ลาดตระเวนพื้นที่ กริด 1234
ข้าศึก: ตรวจพบสถานีเรดาร์ 2 แห่ง
เวลา: 06:00-18:00

คำสั่งผู้บังคับบัญชา:
- รักษาความลับในการเคลื่อนที่
- รวบรวมข่าวสารเกี่ยวกับที่ตั้งข้าศึก
- หลีกเลี่ยงการถูกตรวจจับ
''',
      friendlyAssets: [
        FriendlyAsset(
          id: 'recon_team',
          name: 'หน่วยลาดตระเวน',
          type: AssetType.groundUnit,
          position: const Offset(0.2, 0.7),
          hasRadio: true,
          hasJammer: false,
        ),
        FriendlyAsset(
          id: 'support_hq',
          name: 'บก.สนับสนุน',
          type: AssetType.commandPost,
          position: const Offset(0.1, 0.9),
          hasRadio: true,
          hasJammer: true,
        ),
      ],
      enemyEmitters: [
        EnemyEmitter(
          id: 'radar_1',
          name: 'เรดาร์ตรวจการณ์',
          type: EmitterType.searchRadar,
          position: const Offset(0.6, 0.3),
          frequency: 9500,
          power: 1000,
          range: 0.4,
          isActive: true,
        ),
        EnemyEmitter(
          id: 'radar_2',
          name: 'เรดาร์ติดตาม',
          type: EmitterType.trackingRadar,
          position: const Offset(0.8, 0.5),
          frequency: 16000,
          power: 500,
          range: 0.25,
          isActive: true,
        ),
      ],
      correctESDecisions: {'detect_radar_1': true, 'detect_radar_2': true, 'df_radar_1': true},
      correctEADecisions: {'jam_radar_1': false, 'jam_radar_2': false},
      correctEPDecisions: {'radio_silence': true, 'use_secure_comms': true, 'avoid_radar_zone': true},
    ),
    MissionScenario(
      id: 'scenario_2',
      name: 'ภารกิจโจมตี',
      description: 'สนับสนุนการโจมตีด้วยการรบกวนเรดาร์ข้าศึก',
      briefing: '''
ภารกิจ: สนับสนุน EW ให้การโจมตีทางอากาศ
ข้าศึก: ระบบป้องกันภัยทางอากาศ
เวลา: H-10 ถึง H+30

คำสั่งผู้บังคับบัญชา:
- รบกวนเรดาร์ป้องกันภัยทางอากาศ
- ป้องกันระบบสื่อสารฝ่ายเรา
- รายงานผลการรบกวน
''',
      friendlyAssets: [
        FriendlyAsset(
          id: 'ew_platform',
          name: 'แท่น EW',
          type: AssetType.ewPlatform,
          position: const Offset(0.3, 0.6),
          hasRadio: true,
          hasJammer: true,
        ),
        FriendlyAsset(
          id: 'strike_aircraft',
          name: 'ฝูงบินโจมตี',
          type: AssetType.aircraft,
          position: const Offset(0.15, 0.8),
          hasRadio: true,
          hasJammer: false,
        ),
      ],
      enemyEmitters: [
        EnemyEmitter(
          id: 'sam_radar',
          name: 'เรดาร์ SAM',
          type: EmitterType.samRadar,
          position: const Offset(0.7, 0.35),
          frequency: 6000,
          power: 2000,
          range: 0.35,
          isActive: true,
        ),
        EnemyEmitter(
          id: 'aaa_radar',
          name: 'เรดาร์ AAA',
          type: EmitterType.aaaRadar,
          position: const Offset(0.75, 0.45),
          frequency: 12000,
          power: 800,
          range: 0.2,
          isActive: true,
        ),
        EnemyEmitter(
          id: 'enemy_comms',
          name: 'สถานีสื่อสาร',
          type: EmitterType.communication,
          position: const Offset(0.65, 0.4),
          frequency: 300,
          power: 100,
          range: 0.3,
          isActive: true,
        ),
      ],
      correctESDecisions: {'detect_sam_radar': true, 'detect_aaa_radar': true, 'detect_enemy_comms': true},
      correctEADecisions: {'jam_sam_radar': true, 'jam_aaa_radar': true, 'jam_enemy_comms': false},
      correctEPDecisions: {'use_eccm': true, 'coordinate_timing': true},
    ),
  ];

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _signalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadScenario(0);
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenarioIndex = index;
      _currentScenario = _scenarios[index];
      _friendlyAssets.clear();
      _friendlyAssets.addAll(_currentScenario.friendlyAssets);
      _enemyEmitters.clear();
      _enemyEmitters.addAll(_currentScenario.enemyEmitters);
      _esDecisions.clear();
      _eaDecisions.clear();
      _epDecisions.clear();
      _currentPhase = MissionPhase.planning;
    });
  }

  void _evaluateMission() {
    int score = 0;
    int maxScore = 0;

    // Evaluate ES decisions
    for (var entry in _currentScenario.correctESDecisions.entries) {
      maxScore += 10;
      if (_esDecisions[entry.key] == entry.value) {
        score += 10;
      }
    }

    // Evaluate EA decisions
    for (var entry in _currentScenario.correctEADecisions.entries) {
      maxScore += 15;
      if (_eaDecisions[entry.key] == entry.value) {
        score += 15;
      }
    }

    // Evaluate EP decisions
    for (var entry in _currentScenario.correctEPDecisions.entries) {
      maxScore += 10;
      if (_epDecisions[entry.key] == entry.value) {
        score += 10;
      }
    }

    setState(() {
      _missionScore = (score / maxScore * 100).round();
      _currentPhase = MissionPhase.debrief;
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _signalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.militaryGreen.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.militaryGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 12),

          // Phase indicator
          _buildPhaseIndicator(),
          const SizedBox(height: 12),

          // Main content based on phase
          Expanded(
            child: _buildPhaseContent(),
          ),

          // Navigation
          const SizedBox(height: 12),
          _buildNavigation(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.militaryGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.military_tech,
            color: AppColors.militaryGreen,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EW Mission Planner',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.militaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _currentScenario.name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Scenario selector
        DropdownButton<int>(
          value: _currentScenarioIndex,
          items: _scenarios.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(
                'สถานการณ์ ${entry.key + 1}',
                style: AppTextStyles.labelMedium,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) _loadScenario(value);
          },
          dropdownColor: AppColors.surface,
          underline: const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: MissionPhase.values.map((phase) {
          final isActive = _currentPhase == phase;
          final isPast = _currentPhase.index > phase.index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isActive
                              ? phase.color
                              : isPast
                                  ? phase.color.withValues(alpha: 0.5)
                                  : AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive || isPast ? phase.color : AppColors.border,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: isPast
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  '${phase.index + 1}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phase.nameTh,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isActive ? phase.color : AppColors.textSecondary,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (phase != MissionPhase.values.last)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast ? phase.color : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case MissionPhase.planning:
        return _buildPlanningPhase();
      case MissionPhase.es:
        return _buildESPhase();
      case MissionPhase.ea:
        return _buildEAPhase();
      case MissionPhase.ep:
        return _buildEPPhase();
      case MissionPhase.execution:
        return _buildExecutionPhase();
      case MissionPhase.debrief:
        return _buildDebriefPhase();
    }
  }

  Widget _buildPlanningPhase() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Briefing
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, color: AppColors.info, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'คำสั่งยุทธการ',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentScenario.briefing,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tactical map
          AspectRatio(
            aspectRatio: 1.5,
            child: _buildTacticalMap(),
          ),
          const SizedBox(height: 12),

          // Asset summary
          _buildAssetSummary(),
        ],
      ),
    );
  }

  Widget _buildTacticalMap() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: Listenable.merge([_radarController, _signalController]),
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _TacticalMapPainter(
                friendlyAssets: _friendlyAssets,
                enemyEmitters: _enemyEmitters,
                radarProgress: _radarController.value,
                signalProgress: _signalController.value,
                showRadarCoverage: true,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAssetSummary() {
    return Row(
      children: [
        // Friendly
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'ฝ่ายเรา',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ..._friendlyAssets.map((asset) => Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    '• ${asset.name}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Enemy
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dangerous, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'ข้าศึก',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ..._enemyEmitters.map((emitter) => Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    '• ${emitter.name}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildESPhase() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.esColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.esColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.esColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Electronic Support (ES)',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.esColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'เลือกมาตรการ ES ที่จะใช้:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ES options for each emitter
          ..._enemyEmitters.map((emitter) => _buildESOption(emitter)),
        ],
      ),
    );
  }

  Widget _buildESOption(EnemyEmitter emitter) {
    final detectKey = 'detect_${emitter.id}';
    final dfKey = 'df_${emitter.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(emitter.type.icon, color: emitter.type.color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  emitter.name,
                  style: AppTextStyles.titleSmall,
                ),
              ),
              Text(
                '${emitter.frequency} MHz',
                style: AppTextStyles.codeMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDecisionChip(
                  'ตรวจจับสัญญาณ',
                  _esDecisions[detectKey] ?? false,
                  (value) => setState(() => _esDecisions[detectKey] = value),
                  AppColors.esColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDecisionChip(
                  'หาทิศทาง (DF)',
                  _esDecisions[dfKey] ?? false,
                  (value) => setState(() => _esDecisions[dfKey] = value),
                  AppColors.esColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEAPhase() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.eaColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.eaColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.eaColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Electronic Attack (EA)',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.eaColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'เลือกเป้าหมายที่จะรบกวน:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '⚠️ พิจารณาให้ดี: การรบกวนจะเปิดเผยตำแหน่งของเรา',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // EA options
          ..._enemyEmitters.map((emitter) => _buildEAOption(emitter)),
        ],
      ),
    );
  }

  Widget _buildEAOption(EnemyEmitter emitter) {
    final jamKey = 'jam_${emitter.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _eaDecisions[jamKey] == true
              ? AppColors.eaColor.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(emitter.type.icon, color: emitter.type.color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emitter.name, style: AppTextStyles.titleSmall),
                Text(
                  'กำลังส่ง: ${emitter.power} W | ระยะ: ${(emitter.range * 100).toInt()} km',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _eaDecisions[jamKey] ?? false,
            onChanged: (value) => setState(() => _eaDecisions[jamKey] = value),
            activeColor: AppColors.eaColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEPPhase() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.epColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.epColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, color: AppColors.epColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Electronic Protection (EP)',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.epColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'เลือกมาตรการป้องกัน:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // EP options based on scenario
          _buildEPOptionCard('radio_silence', 'งดใช้วิทยุ', 'ลดโอกาสถูกตรวจจับด้วย DF', Icons.volume_off),
          _buildEPOptionCard('use_secure_comms', 'ใช้การสื่อสารปลอดภัย', 'COMSEC + TRANSEC', Icons.lock),
          _buildEPOptionCard('use_eccm', 'ใช้มาตรการ ECCM', 'FHSS, Spread Spectrum', Icons.security),
          _buildEPOptionCard('avoid_radar_zone', 'หลีกเลี่ยงพื้นที่เรดาร์', 'เลือกเส้นทางรอบนอก', Icons.alt_route),
          _buildEPOptionCard('coordinate_timing', 'ประสานเวลา', 'รบกวนพร้อมกับการโจมตี', Icons.timer),
        ],
      ),
    );
  }

  Widget _buildEPOptionCard(String key, String title, String description, IconData icon) {
    final isSelected = _epDecisions[key] ?? false;

    return GestureDetector(
      onTap: () => setState(() => _epDecisions[key] = !isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.epColor.withValues(alpha: 0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.epColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.epColor.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.epColor : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.epColor : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.epColor : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.rocket_launch,
          size: 64,
          color: AppColors.warning,
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
        const SizedBox(height: 16),
        Text(
          'กำลังปฏิบัติภารกิจ...',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'รอประเมินผล',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
        ),
      ],
    );
  }

  Widget _buildDebriefPhase() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getScoreColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getScoreColor().withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  '$_missionScore%',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: _getScoreColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getScoreText(),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _getScoreColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Decision review
          _buildDecisionReview('ES Decisions', _esDecisions, _currentScenario.correctESDecisions, AppColors.esColor),
          _buildDecisionReview('EA Decisions', _eaDecisions, _currentScenario.correctEADecisions, AppColors.eaColor),
          _buildDecisionReview('EP Decisions', _epDecisions, _currentScenario.correctEPDecisions, AppColors.epColor),

          // Try again button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _loadScenario(_currentScenarioIndex),
              icon: const Icon(Icons.replay),
              label: const Text('ลองอีกครั้ง'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionReview(
    String title,
    Map<String, bool> decisions,
    Map<String, bool> correct,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          ...correct.entries.map((entry) {
            final userDecision = decisions[entry.key] ?? false;
            final isCorrect = userDecision == entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key.replaceAll('_', ' '),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Text(
                    userDecision ? 'ใช่' : 'ไม่',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDecisionChip(
    String label,
    bool isSelected,
    ValueChanged<bool> onChanged,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      children: [
        if (_currentPhase.index > 0 && _currentPhase != MissionPhase.debrief)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentPhase = MissionPhase.values[_currentPhase.index - 1];
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('ก่อนหน้า'),
            ),
          ),
        if (_currentPhase.index > 0 && _currentPhase != MissionPhase.debrief)
          const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (_currentPhase == MissionPhase.execution) {
                _evaluateMission();
              } else if (_currentPhase != MissionPhase.debrief) {
                setState(() {
                  _currentPhase = MissionPhase.values[_currentPhase.index + 1];
                });
              }
            },
            icon: Icon(
              _currentPhase == MissionPhase.ep
                  ? Icons.rocket_launch
                  : _currentPhase == MissionPhase.execution
                      ? Icons.assessment
                      : Icons.arrow_forward,
            ),
            label: Text(
              _currentPhase == MissionPhase.ep
                  ? 'ปฏิบัติภารกิจ'
                  : _currentPhase == MissionPhase.execution
                      ? 'ดูผลลัพธ์'
                      : 'ถัดไป',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPhase.color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor() {
    if (_missionScore >= 80) return AppColors.success;
    if (_missionScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreText() {
    if (_missionScore >= 80) return 'ภารกิจสำเร็จ!';
    if (_missionScore >= 60) return 'ผ่านเกณฑ์';
    return 'ต้องปรับปรุง';
  }
}

/// Tactical Map Painter
class _TacticalMapPainter extends CustomPainter {
  final List<FriendlyAsset> friendlyAssets;
  final List<EnemyEmitter> enemyEmitters;
  final double radarProgress;
  final double signalProgress;
  final bool showRadarCoverage;

  _TacticalMapPainter({
    required this.friendlyAssets,
    required this.enemyEmitters,
    required this.radarProgress,
    required this.signalProgress,
    required this.showRadarCoverage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    _drawBackground(canvas, size);

    // Radar coverage
    if (showRadarCoverage) {
      _drawRadarCoverage(canvas, size);
    }

    // Enemy emitters
    _drawEnemyEmitters(canvas, size);

    // Friendly assets
    _drawFriendlyAssets(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Grid
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 10; i++) {
      canvas.drawLine(
        Offset(size.width * i / 10, 0),
        Offset(size.width * i / 10, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 10),
        Offset(size.width, size.height * i / 10),
        gridPaint,
      );
    }

    // Terrain features (simple representation)
    final terrainPaint = Paint()
      ..color = AppColors.militaryOlive.withValues(alpha: 0.2);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.2),
        width: size.width * 0.4,
        height: size.height * 0.15,
      ),
      terrainPaint,
    );
  }

  void _drawRadarCoverage(Canvas canvas, Size size) {
    for (var emitter in enemyEmitters) {
      if (!emitter.isActive) continue;

      final center = Offset(
        emitter.position.dx * size.width,
        emitter.position.dy * size.height,
      );
      final radius = emitter.range * size.width;

      // Coverage area
      final coveragePaint = Paint()
        ..color = AppColors.error.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, coveragePaint);

      // Sweep line
      final sweepAngle = radarProgress * 2 * math.pi;
      final sweepEnd = Offset(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      );

      final sweepPaint = Paint()
        ..color = AppColors.error.withValues(alpha: 0.5)
        ..strokeWidth = 2;

      canvas.drawLine(center, sweepEnd, sweepPaint);

      // Coverage border
      final borderPaint = Paint()
        ..color = AppColors.error.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(center, radius, borderPaint);
    }
  }

  void _drawEnemyEmitters(Canvas canvas, Size size) {
    for (var emitter in enemyEmitters) {
      final pos = Offset(
        emitter.position.dx * size.width,
        emitter.position.dy * size.height,
      );

      // Emitter marker
      final markerPaint = Paint()
        ..color = emitter.type.color
        ..style = PaintingStyle.fill;

      // Diamond shape
      final path = Path()
        ..moveTo(pos.dx, pos.dy - 10)
        ..lineTo(pos.dx + 8, pos.dy)
        ..lineTo(pos.dx, pos.dy + 10)
        ..lineTo(pos.dx - 8, pos.dy)
        ..close();

      canvas.drawPath(path, markerPaint);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: emitter.name,
          style: TextStyle(
            color: emitter.type.color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 12),
      );
    }
  }

  void _drawFriendlyAssets(Canvas canvas, Size size) {
    for (var asset in friendlyAssets) {
      final pos = Offset(
        asset.position.dx * size.width,
        asset.position.dy * size.height,
      );

      // Asset marker (circle)
      final markerPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, 8, markerPaint);

      // Outline
      final outlinePaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(pos, 12, outlinePaint);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: asset.name,
          style: const TextStyle(
            color: AppColors.success,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalMapPainter oldDelegate) => true;
}

// Models

enum MissionPhase {
  planning,
  es,
  ea,
  ep,
  execution,
  debrief;

  String get nameTh {
    switch (this) {
      case MissionPhase.planning:
        return 'วางแผน';
      case MissionPhase.es:
        return 'ES';
      case MissionPhase.ea:
        return 'EA';
      case MissionPhase.ep:
        return 'EP';
      case MissionPhase.execution:
        return 'ปฏิบัติ';
      case MissionPhase.debrief:
        return 'สรุป';
    }
  }

  Color get color {
    switch (this) {
      case MissionPhase.planning:
        return AppColors.info;
      case MissionPhase.es:
        return AppColors.esColor;
      case MissionPhase.ea:
        return AppColors.eaColor;
      case MissionPhase.ep:
        return AppColors.epColor;
      case MissionPhase.execution:
        return AppColors.warning;
      case MissionPhase.debrief:
        return AppColors.primary;
    }
  }
}

class MissionScenario {
  final String id;
  final String name;
  final String description;
  final String briefing;
  final List<FriendlyAsset> friendlyAssets;
  final List<EnemyEmitter> enemyEmitters;
  final Map<String, bool> correctESDecisions;
  final Map<String, bool> correctEADecisions;
  final Map<String, bool> correctEPDecisions;

  MissionScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.briefing,
    required this.friendlyAssets,
    required this.enemyEmitters,
    required this.correctESDecisions,
    required this.correctEADecisions,
    required this.correctEPDecisions,
  });
}

class FriendlyAsset {
  final String id;
  final String name;
  final AssetType type;
  final Offset position;
  final bool hasRadio;
  final bool hasJammer;

  FriendlyAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.hasRadio,
    required this.hasJammer,
  });
}

enum AssetType {
  groundUnit,
  commandPost,
  ewPlatform,
  aircraft,
}

class EnemyEmitter {
  final String id;
  final String name;
  final EmitterType type;
  final Offset position;
  final double frequency;
  final double power;
  final double range;
  bool isActive;

  EnemyEmitter({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.frequency,
    required this.power,
    required this.range,
    required this.isActive,
  });
}

enum EmitterType {
  searchRadar,
  trackingRadar,
  samRadar,
  aaaRadar,
  communication;

  IconData get icon {
    switch (this) {
      case EmitterType.searchRadar:
        return Icons.radar;
      case EmitterType.trackingRadar:
        return Icons.track_changes;
      case EmitterType.samRadar:
        return Icons.rocket_launch;
      case EmitterType.aaaRadar:
        return Icons.gps_fixed;
      case EmitterType.communication:
        return Icons.cell_tower;
    }
  }

  Color get color {
    switch (this) {
      case EmitterType.searchRadar:
        return AppColors.radarColor;
      case EmitterType.trackingRadar:
        return AppColors.warning;
      case EmitterType.samRadar:
        return AppColors.error;
      case EmitterType.aaaRadar:
        return AppColors.droneColor;
      case EmitterType.communication:
        return AppColors.radioColor;
    }
  }
}
