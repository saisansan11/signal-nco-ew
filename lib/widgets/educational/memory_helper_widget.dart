import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants.dart';

/// EW Mnemonic Widget - "ส-จ-ป" memory aid for the 3 EW pillars
/// ส (สังเกต) = ESM, จ (จู่โจม) = ECM, ป (ป้องกัน) = ECCM
class EWMnemonicWidget extends StatefulWidget {
  const EWMnemonicWidget({super.key});

  @override
  State<EWMnemonicWidget> createState() => _EWMnemonicWidgetState();
}

class _EWMnemonicWidgetState extends State<EWMnemonicWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  final List<_MnemonicItem> _items = [
    _MnemonicItem(
      letter: 'ส',
      word: 'สังเกต',
      english: 'ESM',
      fullName: 'Electronic Support Measures',
      description: 'ค้นหาและวิเคราะห์สัญญาณ',
      color: AppColors.esColor,
      icon: Icons.search,
    ),
    _MnemonicItem(
      letter: 'จ',
      word: 'จู่โจม',
      english: 'ECM',
      fullName: 'Electronic Counter Measures',
      description: 'รบกวนและทำลายสัญญาณข้าศึก',
      color: AppColors.eaColor,
      icon: Icons.flash_on,
    ),
    _MnemonicItem(
      letter: 'ป',
      word: 'ป้องกัน',
      english: 'ECCM',
      fullName: 'Electronic Counter-Counter Measures',
      description: 'ป้องกันสัญญาณจากการรบกวน',
      color: AppColors.epColor,
      icon: Icons.shield,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _items.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: item.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'จำง่ายๆ: ส-จ-ป',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Mnemonic Letters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 60 : 50,
                height: isActive ? 60 : 50,
                decoration: BoxDecoration(
                  color: isActive
                      ? _items[index].color
                      : _items[index].color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _items[index].color.withValues(alpha: 0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _items[index].letter,
                    style: TextStyle(
                      fontSize: isActive ? 28 : 22,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : _items[index].color,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Current Item Details
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_currentIndex),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: item.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: item.color, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.letter} = ${item.word}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.english,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MnemonicItem {
  final String letter;
  final String word;
  final String english;
  final String fullName;
  final String description;
  final Color color;
  final IconData icon;

  _MnemonicItem({
    required this.letter,
    required this.word,
    required this.english,
    required this.fullName,
    required this.description,
    required this.color,
    required this.icon,
  });
}

/// Frequency Bands Memory Widget - Interactive frequency bands visualization
class FrequencyBandsMemoryWidget extends StatefulWidget {
  const FrequencyBandsMemoryWidget({super.key});

  @override
  State<FrequencyBandsMemoryWidget> createState() =>
      _FrequencyBandsMemoryWidgetState();
}

class _FrequencyBandsMemoryWidgetState extends State<FrequencyBandsMemoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  int? _selectedBand;

  final List<_FrequencyBand> _bands = [
    _FrequencyBand(
      name: 'HF',
      fullName: 'High Frequency',
      range: '3-30 MHz',
      usage: 'วิทยุคลื่นสั้น, การสื่อสารระยะไกล',
      color: Colors.blue,
      wavelength: 30.0,
    ),
    _FrequencyBand(
      name: 'VHF',
      fullName: 'Very High Frequency',
      range: '30-300 MHz',
      usage: 'วิทยุ FM, วิทยุทหาร',
      color: Colors.green,
      wavelength: 20.0,
    ),
    _FrequencyBand(
      name: 'UHF',
      fullName: 'Ultra High Frequency',
      range: '300 MHz - 3 GHz',
      usage: 'โทรศัพท์มือถือ, Wi-Fi',
      color: Colors.orange,
      wavelength: 12.0,
    ),
    _FrequencyBand(
      name: 'SHF',
      fullName: 'Super High Frequency',
      range: '3-30 GHz',
      usage: 'เรดาร์, ดาวเทียม',
      color: Colors.red,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.wifi, color: AppColors.spectrumColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'ย่านความถี่',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'แตะเพื่อดูรายละเอียด',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Wave visualization
          SizedBox(
            height: 60,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 60),
                  painter: _WavePainter(
                    bands: _bands,
                    progress: _waveController.value,
                    selectedIndex: _selectedBand,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Frequency bands
          Row(
            children: List.generate(_bands.length, (index) {
              final band = _bands[index];
              final isSelected = _selectedBand == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBand = isSelected ? null : index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? band.color.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color:
                            isSelected ? band.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          band.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? band.color : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          band.range,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // Selected band details
          if (_selectedBand != null) ...[
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(_selectedBand),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bands[_selectedBand!].color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: _bands[_selectedBand!].color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bands[_selectedBand!].fullName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _bands[_selectedBand!].color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'การใช้งาน: ${_bands[_selectedBand!].usage}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _FrequencyBand {
  final String name;
  final String fullName;
  final String range;
  final String usage;
  final Color color;
  final double wavelength;

  _FrequencyBand({
    required this.name,
    required this.fullName,
    required this.range,
    required this.usage,
    required this.color,
    required this.wavelength,
  });
}

class _WavePainter extends CustomPainter {
  final List<_FrequencyBand> bands;
  final double progress;
  final int? selectedIndex;

  _WavePainter({
    required this.bands,
    required this.progress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sectionWidth = size.width / bands.length;

    for (int i = 0; i < bands.length; i++) {
      final band = bands[i];
      final isSelected = selectedIndex == i;
      final paint = Paint()
        ..color = isSelected ? band.color : band.color.withValues(alpha: 0.5)
        ..strokeWidth = isSelected ? 3 : 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      final startX = i * sectionWidth;
      final endX = startX + sectionWidth;

      for (double x = startX; x <= endX; x += 1) {
        final normalizedX = (x - startX) / sectionWidth;
        final y = size.height / 2 +
            math.sin((normalizedX * 4 + progress) * math.pi * 2) *
                (size.height / 3) *
                (band.wavelength / 30);

        if (x == startX) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
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

/// Jamming Process Widget - Visual demonstration of signal jamming
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
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: AppColors.eaColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'การรบกวนสัญญาณ (Jamming)',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Signal visualization
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _JammingSignalPainter(
                    progress: _controller.value,
                    isJamming: _isJamming,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SignalLabel(
                icon: Icons.radio,
                label: 'สัญญาณข้าศึก',
                color: AppColors.error,
              ),
              if (_isJamming)
                _SignalLabel(
                  icon: Icons.flash_on,
                  label: 'สัญญาณรบกวน',
                  color: AppColors.warning,
                ).animate().fadeIn().scale(),
              _SignalLabel(
                icon: Icons.hearing,
                label: _isJamming ? 'รับไม่ได้!' : 'รับสัญญาณ',
                color: _isJamming ? AppColors.textMuted : AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Toggle button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isJamming = !_isJamming;
              });
            },
            icon: Icon(_isJamming ? Icons.stop : Icons.play_arrow),
            label: Text(_isJamming ? 'หยุดรบกวน' : 'เริ่มรบกวน'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isJamming ? AppColors.error : AppColors.eaColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Explanation
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                _isJamming ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(
              'กดปุ่มเพื่อดูผลของการรบกวนสัญญาณ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            secondChild: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.eaColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                'ECM ส่งสัญญาณรบกวนที่ความถี่เดียวกัน\nทำให้ผู้รับไม่สามารถแยกแยะสัญญาณได้',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.eaColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _SignalLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SignalLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

class _JammingSignalPainter extends CustomPainter {
  final double progress;
  final bool isJamming;

  _JammingSignalPainter({
    required this.progress,
    required this.isJamming,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final enemyPaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final jammingPaint = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw enemy signal
    final enemyPath = Path();
    for (double x = 0; x <= size.width; x += 1) {
      final baseY = size.height / 2;
      double amplitude = 15;

      // If jamming, distort the signal more
      if (isJamming && x > size.width * 0.3) {
        final distortion = math.sin((x / 10 + progress * 20)) * 5;
        amplitude = 5 + distortion.abs();
      }

      final y = baseY +
          math.sin((x / 20 + progress * 10)) * amplitude;

      if (x == 0) {
        enemyPath.moveTo(x, y);
      } else {
        enemyPath.lineTo(x, y);
      }
    }
    canvas.drawPath(enemyPath, enemyPaint);

    // Draw jamming signal if active
    if (isJamming) {
      final jammingPath = Path();
      for (double x = size.width * 0.3; x <= size.width * 0.7; x += 1) {
        final baseY = size.height / 2;
        final noise = (math.Random().nextDouble() - 0.5) * 30;
        final y = baseY +
            math.sin((x / 8 + progress * 20)) * 20 +
            noise;

        if (x == size.width * 0.3) {
          jammingPath.moveTo(x, y);
        } else {
          jammingPath.lineTo(x, y);
        }
      }
      canvas.drawPath(jammingPath, jammingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JammingSignalPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isJamming != isJamming;
  }
}
