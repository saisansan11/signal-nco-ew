import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

class JammingSimScreen extends StatefulWidget {
  const JammingSimScreen({super.key});

  @override
  State<JammingSimScreen> createState() => _JammingSimScreenState();
}

class _JammingSimScreenState extends State<JammingSimScreen>
    with TickerProviderStateMixin {
  late AnimationController _jammingController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  JammingType _jammingType = JammingType.spot;
  double _jammingPower = 50.0; // 0-100
  double _targetFrequency = 150.0; // MHz
  double _jammingBandwidth = 20.0; // MHz
  bool _isJamming = false;
  double _jsRatio = 0; // dB

  // ECCM features
  bool _eccmEnabled = false;
  EccmType _eccmType = EccmType.frequencyHopping;
  double _eccmEffectiveness = 0;

  // Target signals
  final List<TargetSignal> _targets = [];
  final math.Random _random = math.Random();

  // Particles
  final List<JammingParticle> _particles = [];
  static const int _maxParticles = 100;

  @override
  void initState() {
    super.initState();
    _jammingController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..addListener(_updateParticles);
    _particleController.repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _generateTargets();
    _calculateJSRatio();
  }

  void _generateTargets() {
    _targets.clear();
    // Main target
    _targets.add(TargetSignal(
      id: 0,
      frequency: 150.0,
      power: -60.0,
      name: 'เป้าหมายหลัก',
      color: Colors.green,
      isMainTarget: true,
    ));
    // Secondary targets
    _targets.add(TargetSignal(
      id: 1,
      frequency: 130.0,
      power: -55.0,
      name: 'สัญญาณ 2',
      color: Colors.cyan,
    ));
    _targets.add(TargetSignal(
      id: 2,
      frequency: 170.0,
      power: -65.0,
      name: 'สัญญาณ 3',
      color: Colors.lightGreen,
    ));
  }

  void _updateParticles() {
    if (!_isJamming) {
      _particles.clear();
      return;
    }

    // Remove dead particles
    _particles.removeWhere((p) => p.life <= 0);

    // Update existing particles
    for (final particle in _particles) {
      particle.update();
    }

    // Add new particles
    if (_particles.length < _maxParticles) {
      final centerX = (_targetFrequency - 100) / 100;
      for (int i = 0; i < 3; i++) {
        _particles.add(JammingParticle(
          x: centerX + (_random.nextDouble() - 0.5) * 0.2,
          y: 1.0,
          vx: (_random.nextDouble() - 0.5) * 0.02,
          vy: -_random.nextDouble() * 0.03 - 0.01,
          life: 1.0,
          decay: 0.01 + _random.nextDouble() * 0.02,
          size: 2 + _random.nextDouble() * 4,
          color: _getParticleColor(),
        ));
      }
    }
  }

  Color _getParticleColor() {
    switch (_jammingType) {
      case JammingType.spot:
        return Colors.red;
      case JammingType.barrage:
        return Colors.orange;
      case JammingType.sweep:
        return Colors.yellow;
      case JammingType.deception:
        return Colors.purple;
    }
  }

  void _calculateJSRatio() {
    if (!_isJamming) {
      setState(() {
        _jsRatio = -999;
        _eccmEffectiveness = 0;
        for (final target in _targets) {
          target.isJammed = false;
          target.jammingLevel = 0;
        }
      });
      return;
    }

    final jammingPowerDb = -80 + _jammingPower * 0.8;

    for (final target in _targets) {
      final freqDiff = (_targetFrequency - target.frequency).abs();
      double freqFactor;

      switch (_jammingType) {
        case JammingType.spot:
          freqFactor = freqDiff < 2 ? 1.0 : (freqDiff < 5 ? 0.5 : 0.1);
          break;
        case JammingType.barrage:
          freqFactor = freqDiff < _jammingBandwidth / 2 ? 0.6 : 0.2;
          break;
        case JammingType.sweep:
          freqFactor = freqDiff < 20 ? 0.4 : 0.1;
          break;
        case JammingType.deception:
          freqFactor = freqDiff < 3 ? 0.8 : 0.2;
          break;
      }

      // ECCM reduction
      double eccmReduction = 1.0;
      if (_eccmEnabled) {
        switch (_eccmType) {
          case EccmType.frequencyHopping:
            eccmReduction = _jammingType == JammingType.spot ? 0.2 : 0.5;
            break;
          case EccmType.spreadSpectrum:
            eccmReduction = 0.3;
            break;
          case EccmType.powerManagement:
            eccmReduction = 0.6;
            break;
          case EccmType.nullSteering:
            eccmReduction = 0.4;
            break;
        }
      }

      final jsDb = (jammingPowerDb - target.power) * freqFactor * eccmReduction;
      target.jammingLevel = jsDb;
      target.isJammed = jsDb > 3;
    }

    // Main target J/S ratio
    final mainTarget = _targets.firstWhere((t) => t.isMainTarget);
    setState(() {
      _jsRatio = mainTarget.jammingLevel;
      _eccmEffectiveness = _eccmEnabled ? (1 - _jsRatio / 20).clamp(0.0, 1.0) * 100 : 0;
    });
  }

  void _toggleJamming() {
    setState(() {
      _isJamming = !_isJamming;
    });
    _calculateJSRatio();
  }

  void _toggleEccm() {
    setState(() {
      _eccmEnabled = !_eccmEnabled;
    });
    _calculateJSRatio();
  }

  String _getEffectivenessText() {
    if (!_isJamming) return 'ไม่ได้รบกวน';
    if (_jsRatio > 10) return 'รบกวนได้ผลดีมาก';
    if (_jsRatio > 3) return 'รบกวนได้ผล';
    if (_jsRatio > 0) return 'รบกวนได้บางส่วน';
    if (_jsRatio > -10) return 'รบกวนได้น้อย';
    return 'ไม่มีผล';
  }

  Color _getEffectivenessColor() {
    if (!_isJamming) return Colors.grey;
    if (_jsRatio > 10) return Colors.green;
    if (_jsRatio > 3) return Colors.lightGreen;
    if (_jsRatio > 0) return Colors.orange;
    if (_jsRatio > -10) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  void dispose() {
    _jammingController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'jamming_sim',
      steps: SimulationTutorials.jammingTutorial,
      primaryColor: AppColors.eaColor,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        appBar: AppBar(
          title: const Text('จำลองการรบกวน (ECM)'),
          backgroundColor: const Color(0xFF0a0a1a),
          actions: [
            // ECCM toggle
            IconButton(
              icon: Icon(
                _eccmEnabled ? Icons.shield : Icons.shield_outlined,
                color: _eccmEnabled ? Colors.cyan : Colors.white54,
              ),
              onPressed: _toggleEccm,
              tooltip: 'ECCM (มาตรการต่อต้านการรบกวน)',
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_jamming_sim', false);
                if (mounted) setState(() {});
              },
              tooltip: 'ดูคำแนะนำ',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Enhanced visualization
                _buildVisualization(),

                // Status panel
                _buildStatusPanel(),

                // ECCM panel (if enabled)
                if (_eccmEnabled) _buildEccmPanel(),

                // Jamming type selector
                _buildJammingTypeSelector(),

                // Jamming type description
                _buildJammingDescription(),

                // Controls
                _buildControls(),

                // Target signals
                _buildTargetsList(),

                // Jamming button
                _buildJammingButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualization() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF050510),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isJamming
              ? Colors.red.withValues(alpha: 0.6)
              : Colors.green.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isJamming ? Colors.red : Colors.green)
                .withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Main visualization
            AnimatedBuilder(
              animation: Listenable.merge([
                _jammingController,
                _glowController,
                _particleController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: EnhancedJammingPainter(
                    jammingType: _jammingType,
                    isJamming: _isJamming,
                    jammingPower: _jammingPower,
                    targetFrequency: _targetFrequency,
                    jammingBandwidth: _jammingBandwidth,
                    animationValue: _jammingController.value,
                    glowIntensity: _glowController.value,
                    targets: _targets,
                    particles: _particles,
                    eccmEnabled: _eccmEnabled,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // Corner overlays
            _buildVisualizationOverlays(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildVisualizationOverlays() {
    return Stack(
      children: [
        // Top-left: Mode
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _jammingType.color.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_jammingType.icon, color: _jammingType.color, size: 14),
                const SizedBox(width: 4),
                Text(
                  _jammingType.titleEn,
                  style: TextStyle(
                    color: _jammingType.color,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top-right: Status
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isJamming
                    ? Colors.red.withValues(alpha: 0.8)
                    : Colors.green.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isJamming ? Colors.red : Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: (_isJamming ? Colors.red : Colors.green)
                            .withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isJamming ? 'JAMMING' : 'STANDBY',
                  style: TextStyle(
                    color: _isJamming ? Colors.red : Colors.green,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom-left: Power
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'PWR: ${_jammingPower.toInt()}%',
              style: TextStyle(
                color: Colors.orange.withValues(alpha: 0.9),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        // Bottom-right: Frequency
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'FREQ: ${_targetFrequency.toInt()} MHz',
              style: TextStyle(
                color: Colors.cyan.withValues(alpha: 0.9),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getEffectivenessColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getEffectivenessColor().withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'J/S RATIO',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                _isJamming && _jsRatio > -100
                    ? '${_jsRatio.toStringAsFixed(1)} dB'
                    : '-- dB',
                style: TextStyle(
                  color: _getEffectivenessColor(),
                  fontSize: 24,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _getEffectivenessColor(),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: _getEffectivenessColor().withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              _getEffectivenessText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildEccmPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.cyan, size: 18),
              const SizedBox(width: 8),
              const Text(
                'ECCM ACTIVE',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'ประสิทธิภาพ: ${_eccmEffectiveness.toInt()}%',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EccmType.values.map((type) {
              final isSelected = _eccmType == type;
              return GestureDetector(
                onTap: () {
                  setState(() => _eccmType = type);
                  _calculateJSRatio();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.cyan.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? Colors.cyan
                          : Colors.cyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    type.titleTh,
                    style: TextStyle(
                      color: isSelected ? Colors.cyan : Colors.cyan.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildJammingTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JAMMING TYPE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: JammingType.values.map((type) {
              final isSelected = _jammingType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _jammingType = type);
                      _calculateJSRatio();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? type.color.withValues(alpha: 0.2)
                            : const Color(0xFF0a0a1a),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? type.color
                              : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: type.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            type.icon,
                            color: isSelected ? type.color : Colors.white38,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type.titleEn,
                            style: TextStyle(
                              color: isSelected ? type.color : Colors.white54,
                              fontSize: 9,
                              fontFamily: 'monospace',
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildJammingDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _jammingType.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: _jammingType.color, size: 16),
              const SizedBox(width: 8),
              Text(
                _jammingType.titleTh,
                style: TextStyle(
                  color: _jammingType.color,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _jammingType.descriptionTh,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          _EnhancedSlider(
            label: 'POWER',
            thaiLabel: 'กำลังส่ง (Power)',
            helpText: 'ยิ่งสูง ยิ่งรบกวนได้ผลดี แต่ใช้พลังงานมาก',
            value: _jammingPower,
            min: 0,
            max: 100,
            unit: '%',
            color: Colors.orange,
            onChanged: (value) {
              setState(() => _jammingPower = value);
              _calculateJSRatio();
            },
          ),
          _EnhancedSlider(
            label: 'FREQ',
            thaiLabel: 'ความถี่เป้าหมาย (Frequency)',
            helpText: 'ปรับให้ตรงกับความถี่ของสัญญาณที่ต้องการรบกวน',
            value: _targetFrequency,
            min: 100,
            max: 200,
            unit: 'MHz',
            color: Colors.cyan,
            onChanged: (value) {
              setState(() => _targetFrequency = value);
              _calculateJSRatio();
            },
          ),
          if (_jammingType != JammingType.spot)
            _EnhancedSlider(
              label: 'BW',
              thaiLabel: 'แบนด์วิดท์ (Bandwidth)',
              helpText: 'ความกว้างของย่านความถี่ที่รบกวน ยิ่งกว้าง ครอบคลุมมาก แต่ประสิทธิภาพต่ำ',
              value: _jammingBandwidth,
              min: 5,
              max: 50,
              unit: 'MHz',
              color: Colors.purple,
              onChanged: (value) {
                setState(() => _jammingBandwidth = value);
                _calculateJSRatio();
              },
            ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildTargetsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TARGET SIGNALS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...(_targets.map((target) => _buildTargetItem(target))),
        ],
      ),
    );
  }

  Widget _buildTargetItem(TargetSignal target) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: target.isJammed
            ? Colors.red.withValues(alpha: 0.15)
            : target.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: target.isJammed
              ? Colors.red.withValues(alpha: 0.5)
              : target.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: target.isJammed ? Colors.red : target.color,
              boxShadow: [
                BoxShadow(
                  color: (target.isJammed ? Colors.red : target.color)
                      .withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.name,
                  style: TextStyle(
                    color: target.isMainTarget ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight:
                        target.isMainTarget ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  '${target.frequency.toInt()} MHz @ ${target.power.toInt()} dBm',
                  style: TextStyle(
                    color: target.color.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: target.isJammed
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              target.isJammed ? 'JAMMED' : 'CLEAR',
              style: TextStyle(
                color: target.isJammed ? Colors.red : Colors.green,
                fontSize: 8,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJammingButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _toggleJamming,
          icon: Icon(
            _isJamming ? Icons.stop_rounded : Icons.flash_on_rounded,
            size: 24,
          ),
          label: Text(
            _isJamming ? 'STOP JAMMING' : 'START JAMMING',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isJamming ? Colors.red[700] : Colors.orange[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2);
  }
}

// ============== Enhanced Slider ==============

class _EnhancedSlider extends StatelessWidget {
  final String label;
  final String? thaiLabel;
  final String? helpText;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const _EnhancedSlider({
    required this.label,
    this.thaiLabel,
    this.helpText,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    inactiveTrackColor: color.withValues(alpha: 0.2),
                    thumbColor: color,
                    overlayColor: color.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${value.toInt()} $unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        // Thai label and help text
        if (thaiLabel != null || helpText != null)
          Container(
            margin: const EdgeInsets.only(left: 4, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: color.withValues(alpha: 0.6), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (thaiLabel != null)
                        Text(
                          thaiLabel!,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (helpText != null)
                        Text(
                          helpText!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============== Enhanced Jamming Painter ==============

class EnhancedJammingPainter extends CustomPainter {
  final JammingType jammingType;
  final bool isJamming;
  final double jammingPower;
  final double targetFrequency;
  final double jammingBandwidth;
  final double animationValue;
  final double glowIntensity;
  final List<TargetSignal> targets;
  final List<JammingParticle> particles;
  final bool eccmEnabled;

  final math.Random _random = math.Random();

  EnhancedJammingPainter({
    required this.jammingType,
    required this.isJamming,
    required this.jammingPower,
    required this.targetFrequency,
    required this.jammingBandwidth,
    required this.animationValue,
    required this.glowIntensity,
    required this.targets,
    required this.particles,
    required this.eccmEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);

    // Draw all target signals
    for (final target in targets) {
      _drawTargetSignal(canvas, size, target);
    }

    // Draw jamming effect
    if (isJamming) {
      switch (jammingType) {
        case JammingType.spot:
          _drawSpotJamming(canvas, size);
          break;
        case JammingType.barrage:
          _drawBarrageJamming(canvas, size);
          break;
        case JammingType.sweep:
          _drawSweepJamming(canvas, size);
          break;
        case JammingType.deception:
          _drawDeceptionJamming(canvas, size);
          break;
      }

      // Draw particles
      _drawParticles(canvas, size);
    }

    // Draw ECCM shield effect
    if (eccmEnabled && isJamming) {
      _drawEccmEffect(canvas, size);
    }

    _drawFrequencyScale(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF001008),
        const Color(0xFF000504),
        const Color(0xFF000302),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height - 20), gridPaint);
    }

    for (int i = 0; i <= 5; i++) {
      final y = (size.height - 20) * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawTargetSignal(Canvas canvas, Size size, TargetSignal target) {
    final signalX = ((target.frequency - 100) / 100) * size.width;
    final signalHeight = (size.height - 20) * ((-target.power + 20) / 80).clamp(0.0, 1.0);

    // Signal glow
    final glowPaint = Paint()
      ..color = target.color.withValues(alpha: 0.3 + glowIntensity * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(
      Offset(signalX, size.height - 20 - signalHeight),
      15,
      glowPaint,
    );

    // Signal fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          target.color.withValues(alpha: 0.6),
          target.color.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(
        signalX - 15,
        size.height - 20 - signalHeight,
        30,
        signalHeight,
      ));

    final path = Path();
    path.moveTo(signalX - 15, size.height - 20);
    path.quadraticBezierTo(
      signalX - 5,
      size.height - 20 - signalHeight + 20,
      signalX,
      size.height - 20 - signalHeight,
    );
    path.quadraticBezierTo(
      signalX + 5,
      size.height - 20 - signalHeight + 20,
      signalX + 15,
      size.height - 20,
    );
    path.close();

    canvas.drawPath(path, fillPaint);

    // Signal outline
    final outlinePaint = Paint()
      ..color = target.color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, outlinePaint);

    // Jammed indicator
    if (target.isJammed && isJamming) {
      final jammedPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5 + _random.nextDouble() * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        Offset(signalX, size.height - 20 - signalHeight),
        20,
        jammedPaint,
      );
    }
  }

  void _drawSpotJamming(Canvas canvas, Size size) {
    final jammingX = ((targetFrequency - 100) / 100) * size.width;
    final jammingHeight = (size.height - 20) * (jammingPower / 100) * 0.9;

    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      Offset(jammingX, size.height - 20 - jammingHeight / 2),
      30,
      glowPaint,
    );

    // Jamming noise
    final noisePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..strokeWidth = 2;

    for (int i = -15; i <= 15; i++) {
      final x = jammingX + i * 1.5;
      final noise = _random.nextDouble() * jammingHeight;
      canvas.drawLine(
        Offset(x, size.height - 20),
        Offset(x, size.height - 20 - noise),
        noisePaint..color = Colors.red.withValues(alpha: 0.3 + _random.nextDouble() * 0.5),
      );
    }

    // Center spike with glow
    canvas.drawLine(
      Offset(jammingX, size.height - 20),
      Offset(jammingX, size.height - 20 - jammingHeight),
      Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawLine(
      Offset(jammingX, size.height - 20),
      Offset(jammingX, size.height - 20 - jammingHeight),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3,
    );
  }

  void _drawBarrageJamming(Canvas canvas, Size size) {
    final centerX = ((targetFrequency - 100) / 100) * size.width;
    final halfBandwidth = (jammingBandwidth / 100) * size.width / 2;
    final jammingHeight = (size.height - 20) * (jammingPower / 100) * 0.7;

    // Fill area
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.orange.withValues(alpha: 0.4),
          Colors.orange.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(
        centerX - halfBandwidth,
        size.height - 20 - jammingHeight,
        halfBandwidth * 2,
        jammingHeight,
      ));

    canvas.drawRect(
      Rect.fromLTWH(
        centerX - halfBandwidth,
        size.height - 20 - jammingHeight,
        halfBandwidth * 2,
        jammingHeight,
      ),
      fillPaint,
    );

    // Noise lines
    final noisePaint = Paint()
      ..strokeWidth = 2;

    for (double x = centerX - halfBandwidth; x <= centerX + halfBandwidth; x += 4) {
      final noise = _random.nextDouble() * jammingHeight;
      noisePaint.color = Colors.orange.withValues(alpha: 0.4 + _random.nextDouble() * 0.4);
      canvas.drawLine(
        Offset(x, size.height - 20),
        Offset(x, size.height - 20 - noise),
        noisePaint,
      );
    }

    // Border lines
    final borderPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.6)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(centerX - halfBandwidth, 0),
      Offset(centerX - halfBandwidth, size.height - 20),
      borderPaint,
    );
    canvas.drawLine(
      Offset(centerX + halfBandwidth, 0),
      Offset(centerX + halfBandwidth, size.height - 20),
      borderPaint,
    );
  }

  void _drawSweepJamming(Canvas canvas, Size size) {
    final centerX = ((targetFrequency - 100) / 100) * size.width;
    final halfBandwidth = (jammingBandwidth / 100) * size.width / 2;
    final jammingHeight = (size.height - 20) * (jammingPower / 100) * 0.8;

    final sweepPhase = animationValue * 2 * math.pi * 10;
    final sweepOffset = math.sin(sweepPhase) * halfBandwidth;
    final sweepX = centerX + sweepOffset;

    // Trail
    final trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.yellow.withValues(alpha: 0.0),
          Colors.yellow.withValues(alpha: 0.4),
        ],
        begin: sweepOffset > 0 ? Alignment.centerLeft : Alignment.centerRight,
        end: sweepOffset > 0 ? Alignment.centerRight : Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(
        sweepOffset > 0 ? sweepX - 40 : sweepX,
        size.height - 20 - jammingHeight,
        40,
        jammingHeight,
      ));

    canvas.drawRect(
      Rect.fromLTWH(
        sweepOffset > 0 ? sweepX - 40 : sweepX,
        size.height - 20 - jammingHeight,
        40,
        jammingHeight,
      ),
      trailPaint,
    );

    // Sweep spike with glow
    canvas.drawLine(
      Offset(sweepX, size.height - 20),
      Offset(sweepX, size.height - 20 - jammingHeight),
      Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawLine(
      Offset(sweepX, size.height - 20),
      Offset(sweepX, size.height - 20 - jammingHeight),
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = 3,
    );

    // Range indicator
    final rangePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(centerX - halfBandwidth, 10),
      Offset(centerX + halfBandwidth, 10),
      rangePaint,
    );
    canvas.drawLine(
      Offset(centerX - halfBandwidth, 5),
      Offset(centerX - halfBandwidth, 15),
      rangePaint,
    );
    canvas.drawLine(
      Offset(centerX + halfBandwidth, 5),
      Offset(centerX + halfBandwidth, 15),
      rangePaint,
    );
  }

  void _drawDeceptionJamming(Canvas canvas, Size size) {
    final centerX = ((targetFrequency - 100) / 100) * size.width;
    final jammingHeight = (size.height - 20) * (jammingPower / 100) * 0.6;

    // Create false targets
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;

      final falseX = centerX + i * 20;
      final phase = animationValue * 2 * math.pi + i * 0.5;
      final amplitude = math.sin(phase) * 0.3 + 0.7;

      // False signal glow
      final glowPaint = Paint()
        ..color = Colors.purple.withValues(alpha: 0.2 * amplitude)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(falseX, size.height - 20 - jammingHeight * amplitude),
        12,
        glowPaint,
      );

      // False signal
      final falsePaint = Paint()
        ..color = Colors.purple.withValues(alpha: 0.6 * amplitude)
        ..strokeWidth = 2;

      final path = Path();
      path.moveTo(falseX - 10, size.height - 20);
      path.quadraticBezierTo(
        falseX,
        size.height - 20 - jammingHeight * amplitude,
        falseX + 10,
        size.height - 20,
      );

      canvas.drawPath(path, falsePaint);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.life * 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size / 2);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * (size.height - 20)),
        particle.size * particle.life,
        paint,
      );
    }
  }

  void _drawEccmEffect(Canvas canvas, Size size) {
    // Shield effect around main target
    final mainTarget = targets.firstWhere((t) => t.isMainTarget);
    final targetX = ((mainTarget.frequency - 100) / 100) * size.width;
    final targetY = size.height - 20 - (size.height - 20) * 0.5;

    // Pulsating shield
    final shieldRadius = 30 + glowIntensity * 10;
    final shieldPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.2 + glowIntensity * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(targetX, targetY), shieldRadius, shieldPaint);
    canvas.drawCircle(
      Offset(targetX, targetY),
      shieldRadius + 5,
      shieldPaint..color = Colors.cyan.withValues(alpha: 0.1),
    );
  }

  void _drawFrequencyScale(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int freq = 100; freq <= 200; freq += 20) {
      final x = ((freq - 100) / 100) * size.width;
      textPainter.text = TextSpan(
        text: '$freq',
        style: TextStyle(
          color: Colors.green.withValues(alpha: 0.8),
          fontSize: 9,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedJammingPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}

// ============== Data Models ==============

class TargetSignal {
  final int id;
  final double frequency;
  final double power;
  final String name;
  final Color color;
  final bool isMainTarget;
  bool isJammed = false;
  double jammingLevel = 0;

  TargetSignal({
    required this.id,
    required this.frequency,
    required this.power,
    required this.name,
    required this.color,
    this.isMainTarget = false,
  });
}

class JammingParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double decay;
  double size;
  Color color;

  JammingParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.decay,
    required this.size,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
    life -= decay;
  }
}

enum JammingType {
  spot,
  barrage,
  sweep,
  deception,
}

enum EccmType {
  frequencyHopping,
  spreadSpectrum,
  powerManagement,
  nullSteering,
}

extension JammingTypeExtension on JammingType {
  String get titleEn {
    switch (this) {
      case JammingType.spot:
        return 'SPOT';
      case JammingType.barrage:
        return 'BARRAGE';
      case JammingType.sweep:
        return 'SWEEP';
      case JammingType.deception:
        return 'DECEPTION';
    }
  }

  String get titleTh {
    switch (this) {
      case JammingType.spot:
        return 'Spot Jamming';
      case JammingType.barrage:
        return 'Barrage Jamming';
      case JammingType.sweep:
        return 'Sweep Jamming';
      case JammingType.deception:
        return 'Deception Jamming';
    }
  }

  String get descriptionTh {
    switch (this) {
      case JammingType.spot:
        return 'การรบกวนจุด - รบกวนความถี่เดียวด้วยกำลังส่งสูง เหมาะกับเป้าหมายที่ใช้ความถี่คงที่';
      case JammingType.barrage:
        return 'การรบกวนกว้าง - รบกวนช่วงความถี่กว้างพร้อมกัน กำลังกระจายตัว เหมาะกับหลายเป้าหมาย';
      case JammingType.sweep:
        return 'การรบกวนกวาด - เลื่อนความถี่รบกวนไปมา เหมาะกับเป้าหมายที่กระโดดความถี่';
      case JammingType.deception:
        return 'การรบกวนลวง - สร้างสัญญาณปลอมเพื่อหลอกระบบเป้าหมาย ใช้พลังงานน้อยกว่า';
    }
  }

  IconData get icon {
    switch (this) {
      case JammingType.spot:
        return Icons.gps_fixed;
      case JammingType.barrage:
        return Icons.view_week;
      case JammingType.sweep:
        return Icons.swap_horiz;
      case JammingType.deception:
        return Icons.psychology;
    }
  }

  Color get color {
    switch (this) {
      case JammingType.spot:
        return Colors.red;
      case JammingType.barrage:
        return Colors.orange;
      case JammingType.sweep:
        return Colors.yellow;
      case JammingType.deception:
        return Colors.purple;
    }
  }
}

extension EccmTypeExtension on EccmType {
  String get titleTh {
    switch (this) {
      case EccmType.frequencyHopping:
        return 'กระโดดความถี่';
      case EccmType.spreadSpectrum:
        return 'Spread Spectrum';
      case EccmType.powerManagement:
        return 'จัดการกำลังส่ง';
      case EccmType.nullSteering:
        return 'Null Steering';
    }
  }
}
