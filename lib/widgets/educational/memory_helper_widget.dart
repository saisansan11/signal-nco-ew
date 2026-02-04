import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../../app/constants.dart';

/// Widget ช่วยจดจำ 3 เสาหลัก EW ด้วย Mnemonic
/// ESM -> EA -> EP = "สังเกต → โจมตี → ป้องกัน"
class EWMnemonicWidget extends StatefulWidget {
  const EWMnemonicWidget({super.key});

  @override
  State<EWMnemonicWidget> createState() => _EWMnemonicWidgetState();
}

class _EWMnemonicWidgetState extends State<EWMnemonicWidget>
    with TickerProviderStateMixin {
  late AnimationController _cycleController;
  int _highlightedPillar = -1;
  bool _showMnemonic = false;

  @override
  void initState() {
    super.initState();
    _cycleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    // Auto-animate through pillars
    _startCycle();
  }

  void _startCycle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() => _highlightedPillar = i);
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    if (!mounted) return;
    setState(() {
      _highlightedPillar = -1;
      _showMnemonic = true;
    });
  }

  @override
  void dispose() {
    _cycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'จำง่าย: 3 เสาหลัก EW',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Three pillars with animation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PillarCard(
                letter: 'S',
                title: 'ESM',
                subtitle: 'สังเกต',
                thaiMnemonic: 'ส',
                color: AppColors.esColor,
                icon: Icons.visibility,
                isHighlighted: _highlightedPillar == 0,
                delay: 0,
              ),
              // Arrow
              Icon(
                Icons.arrow_forward,
                color: _highlightedPillar >= 1
                    ? AppColors.primary
                    : AppColors.textMuted,
              ).animate(
                target: _highlightedPillar >= 1 ? 1 : 0,
              ).scale(end: const Offset(1.2, 1.2)),

              _PillarCard(
                letter: 'A',
                title: 'ECM',
                subtitle: 'โจมตี',
                thaiMnemonic: 'จ',
                color: AppColors.eaColor,
                icon: Icons.flash_on,
                isHighlighted: _highlightedPillar == 1,
                delay: 100,
              ),
              // Arrow
              Icon(
                Icons.arrow_forward,
                color: _highlightedPillar >= 2
                    ? AppColors.primary
                    : AppColors.textMuted,
              ).animate(
                target: _highlightedPillar >= 2 ? 1 : 0,
              ).scale(end: const Offset(1.2, 1.2)),

              _PillarCard(
                letter: 'P',
                title: 'ECCM',
                subtitle: 'ป้องกัน',
                thaiMnemonic: 'ป',
                color: AppColors.epColor,
                icon: Icons.shield,
                isHighlighted: _highlightedPillar == 2,
                delay: 200,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Mnemonic reveal
          if (_showMnemonic)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(30),
                    AppColors.primary.withAlpha(10),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'วิธีจำ: "ส-จ-ป"',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'สังเกต → จู่โจม → ป้องกัน',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(ESM → ECM → ECCM)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

          // Tap to replay
          if (_showMnemonic)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _highlightedPillar = -1;
                  _showMnemonic = false;
                });
                _startCycle();
              },
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('ดูอีกครั้ง'),
            ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String letter;
  final String title;
  final String subtitle;
  final String thaiMnemonic;
  final Color color;
  final IconData icon;
  final bool isHighlighted;
  final int delay;

  const _PillarCard({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.thaiMnemonic,
    required this.color,
    required this.icon,
    required this.isHighlighted,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withAlpha(40) : color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? color : color.withAlpha(50),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withAlpha(60),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Icon with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isHighlighted ? 48 : 40,
            height: isHighlighted ? 48 : 40,
            decoration: BoxDecoration(
              color: color.withAlpha(isHighlighted ? 60 : 30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isHighlighted ? 28 : 22,
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Thai mnemonic letter
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isHighlighted ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? color : AppColors.textSecondary,
            ),
            child: Text('"$thaiMnemonic"'),
          ),
          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: 0.1);
  }
}

/// Widget แสดงความถี่แบบ Interactive พร้อม Animation
class FrequencyBandsMemoryWidget extends StatefulWidget {
  const FrequencyBandsMemoryWidget({super.key});

  @override
  State<FrequencyBandsMemoryWidget> createState() =>
      _FrequencyBandsMemoryWidgetState();
}

class _FrequencyBandsMemoryWidgetState extends State<FrequencyBandsMemoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  int _selectedBand = -1;

  final _bands = [
    _FrequencyBand(
      name: 'HF',
      range: '3-30 MHz',
      use: 'สื่อสารระยะไกล',
      color: AppColors.accentBlue,
      wavelength: 30.0,
    ),
    _FrequencyBand(
      name: 'VHF',
      range: '30-300 MHz',
      use: 'วิทยุยุทธวิธี',
      color: AppColors.success,
      wavelength: 20.0,
    ),
    _FrequencyBand(
      name: 'UHF',
      range: '300 MHz-3 GHz',
      use: 'สื่อสารทหาร/ดาวเทียม',
      color: AppColors.warning,
      wavelength: 12.0,
    ),
    _FrequencyBand(
      name: 'SHF',
      range: '3-30 GHz',
      use: 'เรดาร์/ไมโครเวฟ',
      color: AppColors.error,
      wavelength: 6.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waves, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ย่านความถี่ (แตะเพื่อเรียนรู้)',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // Wave visualization
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return SizedBox(
                height: 60,
                child: CustomPaint(
                  size: const Size(double.infinity, 60),
                  painter: _WavePainter(
                    progress: _waveController.value,
                    bands: _bands,
                    selectedIndex: _selectedBand,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Band buttons
          Row(
            children: _bands.asMap().entries.map((entry) {
              final index = entry.key;
              final band = entry.value;
              final isSelected = _selectedBand == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedBand = isSelected ? -1 : index;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? band.color.withAlpha(40)
                          : band.color.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? band.color : band.color.withAlpha(50),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          band.name,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: band.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Selected band details
          if (_selectedBand >= 0)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bands[_selectedBand].color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _bands[_selectedBand].color.withAlpha(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _bands[_selectedBand].color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _bands[_selectedBand].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _bands[_selectedBand].range,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: _bands[_selectedBand].color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ใช้งาน: ${_bands[_selectedBand].use}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _FrequencyBand {
  final String name;
  final String range;
  final String use;
  final Color color;
  final double wavelength;

  const _FrequencyBand({
    required this.name,
    required this.range,
    required this.use,
    required this.color,
    required this.wavelength,
  });
}

class _WavePainter extends CustomPainter {
  final double progress;
  final List<_FrequencyBand> bands;
  final int selectedIndex;

  _WavePainter({
    required this.progress,
    required this.bands,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bandWidth = size.width / bands.length;

    for (int i = 0; i < bands.length; i++) {
      final band = bands[i];
      final isSelected = selectedIndex == i;
      final startX = i * bandWidth;

      final paint = Paint()
        ..color = band.color.withAlpha(isSelected ? 200 : 100)
        ..strokeWidth = isSelected ? 3 : 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(startX, size.height / 2);

      for (double x = 0; x < bandWidth; x += 2) {
        final y = size.height / 2 +
            math.sin((x / band.wavelength + progress) * 2 * math.pi) *
                (isSelected ? 20 : 12);
        path.lineTo(startX + x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

/// Widget แสดงกระบวนการ Jamming แบบ Animation
class JammingProcessWidget extends StatefulWidget {
  const JammingProcessWidget({super.key});

  @override
  State<JammingProcessWidget> createState() => _JammingProcessWidgetState();
}

class _JammingProcessWidgetState extends State<JammingProcessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isJamming = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleJamming() {
    setState(() {
      _isJamming = !_isJamming;
      if (_isJamming) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isJamming
              ? AppColors.eaColor.withAlpha(100)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            'การรบกวนสัญญาณ (Jamming)',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Visual representation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Enemy transmitter
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.error),
                    ),
                    child: const Icon(Icons.cell_tower, color: AppColors.error),
                  ),
                  const SizedBox(height: 4),
                  Text('ข้าศึก', style: AppTextStyles.labelSmall),
                ],
              ),

              // Signal line with jamming effect
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 40),
                      painter: _JammingLinePainter(
                        isJamming: _isJamming,
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),

              // Our receiver
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Icon(
                      _isJamming ? Icons.signal_wifi_off : Icons.wifi,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('ฝ่ายเรา', style: AppTextStyles.labelSmall),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Jammer
          if (_isJamming)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.eaColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flash_on, color: AppColors.eaColor)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.3, 1.3),
                        duration: 300.ms,
                      ),
                  const SizedBox(width: 8),
                  Text(
                    'Jammer Active!',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.eaColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

          const SizedBox(height: 16),

          // Toggle button
          ElevatedButton.icon(
            onPressed: _toggleJamming,
            icon: Icon(_isJamming ? Icons.stop : Icons.flash_on),
            label: Text(_isJamming ? 'หยุดรบกวน' : 'เริ่มรบกวน'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isJamming ? AppColors.textMuted : AppColors.eaColor,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // Explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isJamming
                  ? '🔴 สัญญาณข้าศึกถูกรบกวน ไม่สามารถสื่อสารได้'
                  : '🟢 สัญญาณข้าศึกสื่อสารได้ปกติ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _JammingLinePainter extends CustomPainter {
  final bool isJamming;
  final double progress;

  _JammingLinePainter({required this.isJamming, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (isJamming) {
      // Jammed signal - broken/distorted
      paint.color = AppColors.error.withAlpha(100);
      final random = math.Random(42);

      final path = Path();
      path.moveTo(0, size.height / 2);

      for (double x = 0; x < size.width; x += 8) {
        final offset = (random.nextDouble() - 0.5) * 30 * progress;
        path.lineTo(x, size.height / 2 + offset);
      }

      canvas.drawPath(path, paint);

      // Jamming waves
      paint.color = AppColors.eaColor.withAlpha((150 * progress).toInt());
      for (int i = 0; i < 3; i++) {
        final y = size.height / 2 + (i - 1) * 10;
        canvas.drawLine(
          Offset(size.width * 0.3, y),
          Offset(size.width * 0.7, y),
          paint,
        );
      }
    } else {
      // Normal signal
      paint.color = AppColors.success;

      final path = Path();
      path.moveTo(0, size.height / 2);

      for (double x = 0; x < size.width; x += 4) {
        final y = size.height / 2 + math.sin(x / 10) * 5;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _JammingLinePainter oldDelegate) {
    return oldDelegate.isJamming != isJamming ||
        oldDelegate.progress != progress;
  }
}
