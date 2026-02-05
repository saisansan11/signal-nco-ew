import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';
import '../../widgets/tutorial/tutorial_overlay.dart';
import '../../widgets/tutorial/simulation_tutorials.dart';

class SpectrumSimScreen extends StatefulWidget {
  const SpectrumSimScreen({super.key});

  @override
  State<SpectrumSimScreen> createState() => _SpectrumSimScreenState();
}

class _SpectrumSimScreenState extends State<SpectrumSimScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _glowController;
  final List<SimSignal> _signals = [];
  final math.Random _random = math.Random();
  bool _isScanning = false;
  int _detectedCount = 0;
  int _identifiedCount = 0;
  SimSignal? _selectedSignal;
  double _centerFrequency = 150.0; // MHz
  double _span = 100.0; // MHz

  // Enhanced features
  bool _showWaterfall = true;
  bool _showPeakHold = true;
  final bool _showMarkers = true;
  final double _referenceLevel = -40.0; // dBm
  final double _noiseFloor = -95.0; // dBm

  // Waterfall history (time-based frequency data)
  final List<List<double>> _waterfallHistory = [];
  static const int _waterfallHistorySize = 60;

  // Peak hold data
  final Map<int, double> _peakHoldValues = {};

  // Markers
  final List<SpectrumMarker> _markers = [];

  // Noise animation seed
  int _noiseSeed = 0;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: AppDurations.spectrumScan,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanController.addListener(() {
      if (_isScanning) {
        if (_scanController.value > 0.95) {
          _checkSignalDetection();
        }
        // Update waterfall on each scan cycle
        if (_scanController.value < 0.05) {
          _updateWaterfall();
          _noiseSeed = _random.nextInt(1000000);
        }
      }
    });

    _generateSignals();
    _initializeWaterfall();
  }

  void _initializeWaterfall() {
    _waterfallHistory.clear();
    for (int i = 0; i < _waterfallHistorySize; i++) {
      _waterfallHistory.add(_generateWaterfallLine());
    }
  }

  List<double> _generateWaterfallLine() {
    final line = <double>[];
    final minFreq = _centerFrequency - _span / 2;
    final maxFreq = _centerFrequency + _span / 2;

    for (int i = 0; i < 200; i++) {
      final freq = minFreq + (maxFreq - minFreq) * i / 200;
      double power = _noiseFloor + _random.nextDouble() * 10 - 5;

      // Add signal contributions
      for (final signal in _signals) {
        if (signal.detected) {
          final distance = (freq - signal.frequency).abs();
          if (distance < signal.bandwidth) {
            final contribution =
                (signal.power - _noiseFloor) * (1 - distance / signal.bandwidth);
            power = math.max(power, _noiseFloor + contribution);
          }
        }
      }

      line.add(power);
    }
    return line;
  }

  void _updateWaterfall() {
    if (_waterfallHistory.length >= _waterfallHistorySize) {
      _waterfallHistory.removeAt(0);
    }
    _waterfallHistory.add(_generateWaterfallLine());
  }

  void _generateSignals() {
    _signals.clear();
    final signalCount = 4 + _random.nextInt(4); // 4-7 signals

    final signalTypes = [
      SignalType.communication,
      SignalType.radar,
      SignalType.navigation,
      SignalType.broadcast,
      SignalType.dataLink,
    ];

    final modulations = [
      ModulationType.am,
      ModulationType.fm,
      ModulationType.psk,
      ModulationType.fsk,
      ModulationType.ofdm,
    ];

    for (int i = 0; i < signalCount; i++) {
      _signals.add(SimSignal(
        id: i,
        frequency: 100 + _random.nextDouble() * 200, // 100-300 MHz
        bandwidth: 2 + _random.nextDouble() * 10, // 2-12 MHz bandwidth
        power: -40 - _random.nextDouble() * 45, // -40 to -85 dBm
        type: signalTypes[_random.nextInt(signalTypes.length)],
        modulation: modulations[_random.nextInt(modulations.length)],
        isIntermittent: _random.nextDouble() < 0.3, // 30% chance intermittent
      ));
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _detectedCount = 0;
      _identifiedCount = 0;
      _selectedSignal = null;
      _peakHoldValues.clear();
      for (final signal in _signals) {
        signal.detected = false;
        signal.identified = false;
      }
    });
    _scanController.repeat();
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanController.stop();
  }

  void _checkSignalDetection() {
    for (final signal in _signals) {
      // Handle intermittent signals
      if (signal.isIntermittent && _random.nextDouble() < 0.4) {
        continue; // Skip detection sometimes
      }

      if (!signal.detected) {
        final minFreq = _centerFrequency - _span / 2;
        final maxFreq = _centerFrequency + _span / 2;
        if (signal.frequency >= minFreq && signal.frequency <= maxFreq) {
          final detectionProb = (signal.power + 95) / 55;
          if (_random.nextDouble() < detectionProb) {
            setState(() {
              signal.detected = true;
              signal.detectedAt = DateTime.now();
              _detectedCount++;
            });
          }
        }
      }
    }

    // Update peak hold
    _updatePeakHold();
  }

  void _updatePeakHold() {
    if (!_showPeakHold) return;

    final minFreq = _centerFrequency - _span / 2;
    for (final signal in _signals) {
      if (signal.detected) {
        final binIndex =
            ((signal.frequency - minFreq) / _span * 200).round().clamp(0, 199);
        final currentPeak = _peakHoldValues[binIndex] ?? _noiseFloor;
        if (signal.power > currentPeak) {
          _peakHoldValues[binIndex] = signal.power;
        }
      }
    }
  }

  void _selectSignal(SimSignal signal) {
    if (!signal.detected) return;
    setState(() {
      _selectedSignal = signal;
    });
  }

  void _identifySignal(SignalType guessedType) {
    if (_selectedSignal == null || _selectedSignal!.identified) return;

    final isCorrect = _selectedSignal!.type == guessedType;
    setState(() {
      _selectedSignal!.identified = true;
      _selectedSignal!.correctlyIdentified = isCorrect;
      if (isCorrect) {
        _identifiedCount++;
      }
    });

    _showIdentificationFeedback(isCorrect);
  }

  void _showIdentificationFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(isCorrect
                  ? 'ถูกต้อง! ระบุสัญญาณได้สำเร็จ'
                  : 'ไม่ถูกต้อง - สัญญาณนี้คือ ${_selectedSignal!.type.titleTh}'),
            ),
          ],
        ),
        backgroundColor: isCorrect ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addMarker() {
    if (_selectedSignal == null) return;

    final existingMarker = _markers.indexWhere(
        (m) => (m.frequency - _selectedSignal!.frequency).abs() < 1);

    if (existingMarker >= 0) {
      setState(() {
        _markers.removeAt(existingMarker);
      });
    } else if (_markers.length < 4) {
      setState(() {
        _markers.add(SpectrumMarker(
          id: _markers.length + 1,
          frequency: _selectedSignal!.frequency,
          power: _selectedSignal!.power,
        ));
      });
    }
  }

  void _resetSimulation() {
    setState(() {
      _isScanning = false;
      _detectedCount = 0;
      _identifiedCount = 0;
      _selectedSignal = null;
      _markers.clear();
      _peakHoldValues.clear();
      _generateSignals();
      _initializeWaterfall();
    });
    _scanController.stop();
    _scanController.reset();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'spectrum_sim',
      steps: SimulationTutorials.spectrumTutorial,
      primaryColor: AppColors.esColor,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        appBar: AppBar(
          title: const Text('วิเคราะห์สเปกตรัม'),
          backgroundColor: const Color(0xFF0a0a1a),
          actions: [
            IconButton(
              icon: Icon(
                _showWaterfall ? Icons.waves : Icons.waves_outlined,
                color: _showWaterfall ? Colors.cyan : Colors.white54,
              ),
              onPressed: () => setState(() => _showWaterfall = !_showWaterfall),
              tooltip: 'Waterfall Display',
            ),
            IconButton(
              icon: Icon(
                _showPeakHold ? Icons.trending_up : Icons.trending_flat,
                color: _showPeakHold ? Colors.yellow : Colors.white54,
              ),
              onPressed: () => setState(() => _showPeakHold = !_showPeakHold),
              tooltip: 'Peak Hold',
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_spectrum_sim', false);
                if (mounted) setState(() {});
              },
              tooltip: 'ดูคำแนะนำ',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSimulation,
              tooltip: 'รีเซ็ต',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Enhanced info bar with professional styling
              _buildInfoBar(),

              // Main spectrum display
              Expanded(
                flex: _showWaterfall ? 2 : 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: _buildSpectrumDisplay(),
                ),
              ),

              // Waterfall display (optional)
              if (_showWaterfall)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: _buildWaterfallDisplay(),
                  ),
                ),

              // Frequency controls
              _buildFrequencyControls(),

              // Signal identification panel
              if (_selectedSignal != null) _buildSignalPanel(),

              // Control buttons
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a1a),
        border: Border(
          bottom: BorderSide(
            color: Colors.cyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            icon: Icons.wifi_tethering,
            label: 'DETECTED',
            value: '$_detectedCount/${_signals.length}',
            color: Colors.cyan,
            isActive: _detectedCount > 0,
          ),
          _InfoChip(
            icon: Icons.verified,
            label: 'IDENTIFIED',
            value: '$_identifiedCount',
            color: Colors.green,
            isActive: _identifiedCount > 0,
          ),
          _InfoChip(
            icon: Icons.center_focus_strong,
            label: 'CENTER',
            value: '${_centerFrequency.toInt()} MHz',
            color: Colors.amber,
            isActive: true,
          ),
          _InfoChip(
            icon: Icons.swap_horiz,
            label: 'SPAN',
            value: '${_span.toInt()} MHz',
            color: Colors.purple,
            isActive: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSpectrumDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050510),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Main spectrum painter
            AnimatedBuilder(
              animation: Listenable.merge([_scanController, _glowController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: EnhancedSpectrumPainter(
                    signals: _signals,
                    centerFrequency: _centerFrequency,
                    span: _span,
                    scanProgress: _isScanning ? _scanController.value : 0,
                    selectedSignal: _selectedSignal,
                    referenceLevel: _referenceLevel,
                    noiseFloor: _noiseFloor,
                    showPeakHold: _showPeakHold,
                    peakHoldValues: _peakHoldValues,
                    markers: _markers,
                    showMarkers: _showMarkers,
                    glowIntensity: _glowController.value,
                    noiseSeed: _noiseSeed,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // Gesture detector for tap
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) => _handleSpectrumTap(details.localPosition),
                onLongPress: _selectedSignal != null ? _addMarker : null,
              ),
            ),
            // Corner overlays
            _buildCornerOverlays(),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildCornerOverlays() {
    return Stack(
      children: [
        // Top-left: Reference level
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.cyan.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REF: ${_referenceLevel.toInt()} dBm',
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SCALE: 10 dB/div',
                  style: TextStyle(
                    color: Colors.cyan.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top-right: Scan status
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isScanning
                    ? Colors.green.withValues(alpha: 0.8)
                    : Colors.orange.withValues(alpha: 0.5),
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
                    color: _isScanning ? Colors.green : Colors.orange,
                    boxShadow: _isScanning
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isScanning ? 'SCANNING' : 'STOPPED',
                  style: TextStyle(
                    color: _isScanning ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom-left: Frequency range
        Positioned(
          bottom: 24,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'START: ${(_centerFrequency - _span / 2).toInt()} MHz',
              style: TextStyle(
                color: Colors.green.withValues(alpha: 0.8),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        // Bottom-right: End frequency
        Positioned(
          bottom: 24,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'STOP: ${(_centerFrequency + _span / 2).toInt()} MHz',
              style: TextStyle(
                color: Colors.green.withValues(alpha: 0.8),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterfallDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050510),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            CustomPaint(
              painter: WaterfallPainter(
                history: _waterfallHistory,
                noiseFloor: _noiseFloor,
                referenceLevel: _referenceLevel,
              ),
              size: Size.infinite,
            ),
            // Time axis label
            Positioned(
              top: 4,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'WATERFALL',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 8,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 70,
                child: Text(
                  'CENTER',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.amber,
                    inactiveTrackColor: Colors.amber.withValues(alpha: 0.2),
                    thumbColor: Colors.amber,
                    overlayColor: Colors.amber.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _centerFrequency,
                    min: 50,
                    max: 350,
                    divisions: 60,
                    onChanged: (value) {
                      setState(() {
                        _centerFrequency = value;
                        _initializeWaterfall();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${_centerFrequency.toInt()} MHz',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 70,
                child: Text(
                  'SPAN',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.purple,
                    inactiveTrackColor: Colors.purple.withValues(alpha: 0.2),
                    thumbColor: Colors.purple,
                    overlayColor: Colors.purple.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _span,
                    min: 20,
                    max: 200,
                    divisions: 18,
                    onChanged: (value) {
                      setState(() {
                        _span = value;
                        _initializeWaterfall();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${_span.toInt()} MHz',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a1a),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedSignal!.identified
              ? (_selectedSignal!.correctlyIdentified
                  ? Colors.green.withValues(alpha: 0.6)
                  : Colors.red.withValues(alpha: 0.6))
              : Colors.cyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_selectedSignal!.identified
                    ? (_selectedSignal!.correctlyIdentified
                        ? Colors.green
                        : Colors.red)
                    : Colors.cyan)
                .withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt,
                color: _selectedSignal!.type.color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'SELECTED SIGNAL',
                style: TextStyle(
                  color: _selectedSignal!.type.color,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_selectedSignal!.identified)
                GestureDetector(
                  onTap: _addMarker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin, color: Colors.orange, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'MARKER',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Signal info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SignalDataBox(
                label: 'FREQ',
                value: _selectedSignal!.frequency.toStringAsFixed(2),
                unit: 'MHz',
                color: Colors.cyan,
              ),
              _SignalDataBox(
                label: 'POWER',
                value: _selectedSignal!.power.toStringAsFixed(1),
                unit: 'dBm',
                color: Colors.green,
              ),
              _SignalDataBox(
                label: 'BW',
                value: _selectedSignal!.bandwidth.toStringAsFixed(1),
                unit: 'MHz',
                color: Colors.purple,
              ),
              _SignalDataBox(
                label: 'MOD',
                value: _selectedSignal!.modulation.name.toUpperCase(),
                unit: '',
                color: Colors.amber,
              ),
            ],
          ),
          // Identification buttons or result
          if (!_selectedSignal!.identified) ...[
            const SizedBox(height: 12),
            const Text(
              'IDENTIFY SIGNAL TYPE:',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: SignalType.values.map((type) {
                return _IdentifyButton(
                  type: type,
                  onTap: () => _identifySignal(type),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedSignal!.correctlyIdentified
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _selectedSignal!.correctlyIdentified
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedSignal!.correctlyIdentified
                        ? Icons.check_circle
                        : Icons.info,
                    color: _selectedSignal!.correctlyIdentified
                        ? Colors.green
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Signal Type: ${_selectedSignal!.type.titleTh}',
                      style: TextStyle(
                        color: _selectedSignal!.correctlyIdentified
                            ? Colors.green
                            : Colors.red,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? _stopScanning : _startScanning,
                icon: Icon(
                  _isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 24,
                ),
                label: Text(
                  _isScanning ? 'STOP SCAN' : 'START SCAN',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isScanning ? Colors.red[700] : Colors.cyan[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2);
  }

  void _handleSpectrumTap(Offset position) {
    if (_signals.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    SimSignal? closest;
    double minDistance = double.infinity;

    final minFreq = _centerFrequency - _span / 2;
    final maxFreq = _centerFrequency + _span / 2;

    for (final signal in _signals) {
      if (!signal.detected) continue;
      if (signal.frequency < minFreq || signal.frequency > maxFreq) continue;

      final normalizedFreq = (signal.frequency - minFreq) / _span;
      final signalX = normalizedFreq * renderBox.size.width;
      final distance = (signalX - position.dx).abs();

      if (distance < minDistance && distance < 40) {
        minDistance = distance;
        closest = signal;
      }
    }

    if (closest != null) {
      _selectSignal(closest);
    }
  }
}

// ============== Custom Widgets ==============

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isActive;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.5) : Colors.white24,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? color : Colors.white38, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color.withValues(alpha: 0.8) : Colors.white38,
              fontSize: 8,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalDataBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SignalDataBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 8,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _IdentifyButton extends StatelessWidget {
  final SignalType type;
  final VoidCallback onTap;

  const _IdentifyButton({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: type.color.withValues(alpha: 0.4)),
          ),
          child: Text(
            type.titleTh,
            style: TextStyle(
              color: type.color,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ============== Enhanced Spectrum Painter ==============

class EnhancedSpectrumPainter extends CustomPainter {
  final List<SimSignal> signals;
  final double centerFrequency;
  final double span;
  final double scanProgress;
  final SimSignal? selectedSignal;
  final double referenceLevel;
  final double noiseFloor;
  final bool showPeakHold;
  final Map<int, double> peakHoldValues;
  final List<SpectrumMarker> markers;
  final bool showMarkers;
  final double glowIntensity;
  final int noiseSeed;

  EnhancedSpectrumPainter({
    required this.signals,
    required this.centerFrequency,
    required this.span,
    required this.scanProgress,
    this.selectedSignal,
    required this.referenceLevel,
    required this.noiseFloor,
    required this.showPeakHold,
    required this.peakHoldValues,
    required this.markers,
    required this.showMarkers,
    required this.glowIntensity,
    required this.noiseSeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minFreq = centerFrequency - span / 2;
    final maxFreq = centerFrequency + span / 2;

    // Draw gradient background
    _drawBackground(canvas, size);

    // Draw grid with enhanced styling
    _drawEnhancedGrid(canvas, size, minFreq, maxFreq);

    // Draw noise floor with animation
    _drawAnimatedNoiseFloor(canvas, size);

    // Draw peak hold trace
    if (showPeakHold && peakHoldValues.isNotEmpty) {
      _drawPeakHold(canvas, size, minFreq, maxFreq);
    }

    // Draw signals with 3D-like effects
    for (final signal in signals) {
      if (signal.detected &&
          signal.frequency >= minFreq &&
          signal.frequency <= maxFreq) {
        _drawEnhancedSignal(canvas, size, signal, minFreq, maxFreq);
      }
    }

    // Draw markers
    if (showMarkers) {
      for (final marker in markers) {
        _drawMarker(canvas, size, marker, minFreq, maxFreq);
      }
    }

    // Draw scan line with glow
    if (scanProgress > 0) {
      _drawEnhancedScanLine(canvas, size);
    }

    // Draw frequency labels
    _drawFrequencyLabels(canvas, size, minFreq, maxFreq);

    // Draw power labels
    _drawPowerLabels(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF001020),
        const Color(0xFF000510),
        const Color(0xFF000005),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  void _drawEnhancedGrid(
      Canvas canvas, Size size, double minFreq, double maxFreq) {
    // Major grid lines
    final majorGridPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    // Minor grid lines
    final minorGridPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    // Vertical lines (frequency)
    for (int i = 0; i <= 20; i++) {
      final x = size.width * i / 20;
      final paint = i % 4 == 0 ? majorGridPaint : minorGridPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height - 20), paint);
    }

    // Horizontal lines (power - 10 dB divisions)
    for (int i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      final paint = i % 2 == 0 ? majorGridPaint : minorGridPaint;
      canvas.drawLine(Offset(40, y), Offset(size.width, y), paint);
    }

    // Draw -3dB line (reference)
    final refLineY = size.height * 0.05; // Near top
    final refLinePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Make it dashed
    _drawDashedLine(
        canvas, Offset(40, refLineY), Offset(size.width, refLineY), refLinePaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (end - start).distance;
    final steps = (distance / (dashWidth + dashSpace)).ceil();

    for (int i = 0; i < steps; i++) {
      final startOffset = start + (end - start) * (i * (dashWidth + dashSpace) / distance);
      final endOffset = start +
          (end - start) *
              math.min((i * (dashWidth + dashSpace) + dashWidth) / distance, 1.0);
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawAnimatedNoiseFloor(Canvas canvas, Size size) {
    final random = math.Random(noiseSeed);
    final noiseY = _powerToY(noiseFloor, size);

    // Background noise fill
    final noiseFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.withValues(alpha: 0.05),
          Colors.green.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(40, noiseY, size.width - 40, size.height - noiseY));

    final noiseFillPath = Path();
    noiseFillPath.moveTo(40, size.height - 20);

    for (double x = 40; x <= size.width; x += 2) {
      final noise = random.nextDouble() * 15;
      final y = noiseY + noise;
      noiseFillPath.lineTo(x, y);
    }
    noiseFillPath.lineTo(size.width, size.height - 20);
    noiseFillPath.close();

    canvas.drawPath(noiseFillPath, noiseFillPaint);

    // Noise line
    final noiseLinePaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final noiseLinePath = Path();
    noiseLinePath.moveTo(40, noiseY + random.nextDouble() * 10);

    for (double x = 42; x <= size.width; x += 2) {
      final noise = random.nextDouble() * 12 - 6;
      noiseLinePath.lineTo(x, noiseY + noise);
    }

    canvas.drawPath(noiseLinePath, noiseLinePaint);
  }

  void _drawPeakHold(
      Canvas canvas, Size size, double minFreq, double maxFreq) {
    final peakPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final peakPath = Path();
    bool started = false;

    for (final entry in peakHoldValues.entries) {
      final x = 40 + (entry.key / 200) * (size.width - 40);
      final y = _powerToY(entry.value, size);

      if (!started) {
        peakPath.moveTo(x, y);
        started = true;
      } else {
        peakPath.lineTo(x, y);
      }
    }

    if (started) {
      canvas.drawPath(peakPath, peakPaint);
    }
  }

  void _drawEnhancedSignal(Canvas canvas, Size size, SimSignal signal,
      double minFreq, double maxFreq) {
    final normalizedFreq = (signal.frequency - minFreq) / (maxFreq - minFreq);
    final x = 40 + normalizedFreq * (size.width - 40);
    final peakY = _powerToY(signal.power, size);
    final bandwidthPixels = (signal.bandwidth / span) * (size.width - 40);
    final isSelected = selectedSignal == signal;

    // Glow effect (outer)
    if (isSelected || signal.power > -60) {
      final glowPaint = Paint()
        ..color = (isSelected ? Colors.yellow : signal.type.color)
            .withValues(alpha: 0.2 + glowIntensity * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      final glowPath = _createSignalPath(x, peakY, bandwidthPixels, size);
      canvas.drawPath(glowPath, glowPaint);
    }

    // Signal fill with gradient (3D effect)
    final signalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        isSelected
            ? Colors.yellow.withValues(alpha: 0.8)
            : signal.type.color.withValues(alpha: 0.7),
        isSelected
            ? Colors.yellow.withValues(alpha: 0.3)
            : signal.type.color.withValues(alpha: 0.2),
        isSelected
            ? Colors.yellow.withValues(alpha: 0.05)
            : signal.type.color.withValues(alpha: 0.02),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final signalFillPaint = Paint()
      ..shader = signalGradient.createShader(
        Rect.fromLTWH(x - bandwidthPixels / 2, peakY, bandwidthPixels, size.height - 20 - peakY),
      );

    final signalPath = _createSignalPath(x, peakY, bandwidthPixels, size);
    canvas.drawPath(signalPath, signalFillPaint);

    // Signal outline with glow
    final outlinePaint = Paint()
      ..color = isSelected ? Colors.yellow : signal.type.color
      ..strokeWidth = isSelected ? 2.5 : 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 3 : 1);

    final outlinePath = _createSignalOutlinePath(x, peakY, bandwidthPixels, size);
    canvas.drawPath(outlinePath, outlinePaint);

    // Peak indicator
    if (isSelected) {
      // Vertical marker line
      final markerPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height - 20), markerPaint);

      // Crosshair
      canvas.drawCircle(
        Offset(x, peakY),
        6,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        Offset(x, peakY),
        4,
        Paint()..color = Colors.yellow,
      );
      canvas.drawCircle(
        Offset(x, peakY),
        2,
        Paint()..color = Colors.black,
      );
    }

    // Identification marker
    if (signal.identified) {
      final markerColor =
          signal.correctlyIdentified ? Colors.green : Colors.red;
      canvas.drawCircle(
        Offset(x, peakY - 12),
        6,
        Paint()
          ..color = markerColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(
        Offset(x, peakY - 12),
        5,
        Paint()..color = markerColor,
      );

      // Checkmark or X
      final iconPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (signal.correctlyIdentified) {
        canvas.drawLine(
          Offset(x - 2, peakY - 12),
          Offset(x, peakY - 10),
          iconPaint,
        );
        canvas.drawLine(
          Offset(x, peakY - 10),
          Offset(x + 3, peakY - 15),
          iconPaint,
        );
      } else {
        canvas.drawLine(
          Offset(x - 2, peakY - 14),
          Offset(x + 2, peakY - 10),
          iconPaint,
        );
        canvas.drawLine(
          Offset(x - 2, peakY - 10),
          Offset(x + 2, peakY - 14),
          iconPaint,
        );
      }
    }
  }

  Path _createSignalPath(double x, double peakY, double bandwidth, Size size) {
    final path = Path();
    final baseY = size.height - 20;
    final halfBw = bandwidth / 2;

    path.moveTo(x - halfBw, baseY);
    path.quadraticBezierTo(
      x - halfBw * 0.7,
      peakY + (baseY - peakY) * 0.4,
      x - halfBw * 0.3,
      peakY + (baseY - peakY) * 0.1,
    );
    path.quadraticBezierTo(x, peakY, x + halfBw * 0.3, peakY + (baseY - peakY) * 0.1);
    path.quadraticBezierTo(
      x + halfBw * 0.7,
      peakY + (baseY - peakY) * 0.4,
      x + halfBw,
      baseY,
    );
    path.close();
    return path;
  }

  Path _createSignalOutlinePath(
      double x, double peakY, double bandwidth, Size size) {
    final path = Path();
    final baseY = size.height - 20;
    final halfBw = bandwidth / 2;

    path.moveTo(x - halfBw, baseY);
    path.quadraticBezierTo(
      x - halfBw * 0.7,
      peakY + (baseY - peakY) * 0.4,
      x - halfBw * 0.3,
      peakY + (baseY - peakY) * 0.1,
    );
    path.quadraticBezierTo(x, peakY, x + halfBw * 0.3, peakY + (baseY - peakY) * 0.1);
    path.quadraticBezierTo(
      x + halfBw * 0.7,
      peakY + (baseY - peakY) * 0.4,
      x + halfBw,
      baseY,
    );
    return path;
  }

  void _drawMarker(Canvas canvas, Size size, SpectrumMarker marker,
      double minFreq, double maxFreq) {
    if (marker.frequency < minFreq || marker.frequency > maxFreq) return;

    final normalizedFreq = (marker.frequency - minFreq) / (maxFreq - minFreq);
    final x = 40 + normalizedFreq * (size.width - 40);
    final y = _powerToY(marker.power, size);

    // Marker line
    final linePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height - 20), linePaint);

    // Marker diamond
    final markerPath = Path()
      ..moveTo(x, y - 8)
      ..lineTo(x + 5, y)
      ..lineTo(x, y + 8)
      ..lineTo(x - 5, y)
      ..close();

    canvas.drawPath(
      markerPath,
      Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      markerPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Marker label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M${marker.id}',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 10,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 22));
  }

  void _drawEnhancedScanLine(Canvas canvas, Size size) {
    final scanX = 40 + scanProgress * (size.width - 40);

    // Scan sweep gradient
    final sweepGradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.cyan.withValues(alpha: 0.1),
        Colors.cyan.withValues(alpha: 0.3),
        Colors.cyan.withValues(alpha: 0.6),
      ],
      stops: const [0.0, 0.5, 0.8, 1.0],
    );

    final sweepRect = Rect.fromLTWH(
      math.max(40, scanX - 50),
      0,
      50,
      size.height - 20,
    );

    canvas.drawRect(
      sweepRect,
      Paint()..shader = sweepGradient.createShader(sweepRect),
    );

    // Main scan line with glow
    canvas.drawLine(
      Offset(scanX, 0),
      Offset(scanX, size.height - 20),
      Paint()
        ..color = Colors.cyan.withValues(alpha: 0.5)
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawLine(
      Offset(scanX, 0),
      Offset(scanX, size.height - 20),
      Paint()
        ..color = Colors.cyan
        ..strokeWidth = 2,
    );
  }

  void _drawFrequencyLabels(
      Canvas canvas, Size size, double minFreq, double maxFreq) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final freq = minFreq + (maxFreq - minFreq) * i / 4;
      final x = 40 + (size.width - 40) * i / 4;

      textPainter.text = TextSpan(
        text: '${freq.toInt()}',
        style: TextStyle(
          color: Colors.cyan.withValues(alpha: 0.8),
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 16),
      );
    }

    // MHz label
    textPainter.text = const TextSpan(
      text: 'MHz',
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 9,
        fontFamily: 'monospace',
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 25, size.height - 16));
  }

  void _drawPowerLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final powers = [-40, -50, -60, -70, -80, -90, -100];
    for (int i = 0; i < powers.length; i++) {
      final y = (size.height - 20) * i / (powers.length - 1);

      textPainter.text = TextSpan(
        text: '${powers[i]}',
        style: TextStyle(
          color: Colors.green.withValues(alpha: 0.8),
          fontSize: 9,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(4, y - textPainter.height / 2),
      );
    }
  }

  double _powerToY(double power, Size size) {
    // Map power from -40 to -100 dBm to screen Y
    final normalized = (power - referenceLevel) / (noiseFloor - 10 - referenceLevel);
    return normalized.clamp(0.0, 1.0) * (size.height - 20);
  }

  @override
  bool shouldRepaint(covariant EnhancedSpectrumPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.selectedSignal != selectedSignal ||
        oldDelegate.centerFrequency != centerFrequency ||
        oldDelegate.span != span ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.noiseSeed != noiseSeed ||
        oldDelegate.showPeakHold != showPeakHold;
  }
}

// ============== Waterfall Painter ==============

class WaterfallPainter extends CustomPainter {
  final List<List<double>> history;
  final double noiseFloor;
  final double referenceLevel;

  WaterfallPainter({
    required this.history,
    required this.noiseFloor,
    required this.referenceLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final rowHeight = size.height / history.length;
    final colWidth = size.width / (history.first.length);

    for (int row = 0; row < history.length; row++) {
      final line = history[row];
      final y = row * rowHeight;

      for (int col = 0; col < line.length; col++) {
        final power = line[col];
        final x = col * colWidth;

        // Map power to color intensity
        final intensity = ((power - noiseFloor) / (referenceLevel - noiseFloor))
            .clamp(0.0, 1.0);

        // Color gradient: blue -> cyan -> green -> yellow -> red
        Color color;
        if (intensity < 0.25) {
          color = Color.lerp(
            const Color(0xFF000033),
            const Color(0xFF0033AA),
            intensity * 4,
          )!;
        } else if (intensity < 0.5) {
          color = Color.lerp(
            const Color(0xFF0033AA),
            const Color(0xFF00AAAA),
            (intensity - 0.25) * 4,
          )!;
        } else if (intensity < 0.75) {
          color = Color.lerp(
            const Color(0xFF00AAAA),
            const Color(0xFFAAFF00),
            (intensity - 0.5) * 4,
          )!;
        } else {
          color = Color.lerp(
            const Color(0xFFAAFF00),
            const Color(0xFFFF3300),
            (intensity - 0.75) * 4,
          )!;
        }

        canvas.drawRect(
          Rect.fromLTWH(x, y, colWidth + 1, rowHeight + 1),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaterfallPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}

// ============== Data Models ==============

class SimSignal {
  final int id;
  final double frequency;
  final double bandwidth;
  final double power;
  final SignalType type;
  final ModulationType modulation;
  final bool isIntermittent;
  bool detected = false;
  bool identified = false;
  bool correctlyIdentified = false;
  DateTime? detectedAt;

  SimSignal({
    required this.id,
    required this.frequency,
    required this.bandwidth,
    required this.power,
    required this.type,
    required this.modulation,
    this.isIntermittent = false,
  });
}

class SpectrumMarker {
  final int id;
  final double frequency;
  final double power;

  SpectrumMarker({
    required this.id,
    required this.frequency,
    required this.power,
  });
}

enum SignalType {
  communication,
  radar,
  navigation,
  broadcast,
  dataLink,
}

enum ModulationType {
  am,
  fm,
  psk,
  fsk,
  ofdm,
}

extension SignalTypeExtension on SignalType {
  String get titleTh {
    switch (this) {
      case SignalType.communication:
        return 'สื่อสาร';
      case SignalType.radar:
        return 'เรดาร์';
      case SignalType.navigation:
        return 'นำทาง';
      case SignalType.broadcast:
        return 'กระจายเสียง';
      case SignalType.dataLink:
        return 'Data Link';
    }
  }

  Color get color {
    switch (this) {
      case SignalType.communication:
        return Colors.cyan;
      case SignalType.radar:
        return Colors.orange;
      case SignalType.navigation:
        return Colors.green;
      case SignalType.broadcast:
        return Colors.purple;
      case SignalType.dataLink:
        return Colors.pink;
    }
  }
}
