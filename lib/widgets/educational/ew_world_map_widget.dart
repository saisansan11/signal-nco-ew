import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants.dart';

/// EW World Map Widget - Museum-style presentation of historical EW events
class EWWorldMapWidget extends StatefulWidget {
  const EWWorldMapWidget({super.key});

  @override
  State<EWWorldMapWidget> createState() => _EWWorldMapWidgetState();
}

class _EWWorldMapWidgetState extends State<EWWorldMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tourController;
  int _selectedEventIndex = -1;
  bool _isAutoTour = false;
  int _currentTourIndex = 0;

  final List<EWHistoricalEvent> _events = [
    EWHistoricalEvent(
      id: 'tannenberg',
      title: 'ยุทธการแทนเนนเบิร์ก',
      year: 1914,
      location: 'โปแลนด์',
      lat: 53.5,
      lon: 20.0,
      description: 'การใช้ข่าวกรองสัญญาณครั้งแรกในประวัติศาสตร์\n'
          'เยอรมันดักรับวิทยุรัสเซียที่ไม่เข้ารหัส\n'
          'ทำให้สามารถโจมตีล่วงหน้าได้',
      significance: 'จุดเริ่มต้นของ SIGINT',
      icon: Icons.radio,
      color: AppColors.esColor,
    ),
    EWHistoricalEvent(
      id: 'britain',
      title: 'ยุทธการบริเตน',
      year: 1940,
      location: 'สหราชอาณาจักร',
      lat: 51.5,
      lon: -0.1,
      description: 'ระบบ Chain Home Radar ป้องกันเกาะอังกฤษ\n'
          'ตรวจจับเครื่องบินเยอรมันล่วงหน้า\n'
          'ชัยชนะครั้งแรกที่เรดาร์มีบทบาทสำคัญ',
      significance: 'Radar เปลี่ยนแปลงสงคราม',
      icon: Icons.radar,
      color: AppColors.radarColor,
    ),
    EWHistoricalEvent(
      id: 'pearl',
      title: 'เพิร์ลฮาร์เบอร์',
      year: 1941,
      location: 'ฮาวาย, สหรัฐฯ',
      lat: 21.3,
      lon: -157.8,
      description: 'เรดาร์ตรวจพบเครื่องบินญี่ปุ่นล่วงหน้า 1 ชม.\n'
          'แต่สัญญาณถูกมองข้าม คิดว่าเป็นฝ่ายเรา\n'
          'บทเรียนสำคัญ: ข้อมูลต้องวิเคราะห์ถูกต้อง',
      significance: 'บทเรียนการวิเคราะห์ข้อมูล',
      icon: Icons.warning_amber,
      color: AppColors.warning,
    ),
    EWHistoricalEvent(
      id: 'vietnam',
      title: 'สงครามเวียดนาม',
      year: 1965,
      location: 'เวียดนาม',
      lat: 16.0,
      lon: 108.0,
      description: 'การรบกวนเรดาร์ SAM อย่างเป็นระบบครั้งแรก\n'
          'พัฒนา Wild Weasel สำหรับ SEAD\n'
          'ใช้ Chaff และ ECM pods อย่างแพร่หลาย',
      significance: 'ยุค EW สมัยใหม่เริ่มต้น',
      icon: Icons.flight,
      color: AppColors.eaColor,
    ),
    EWHistoricalEvent(
      id: 'gulf',
      title: 'สงครามอ่าวเปอร์เซีย',
      year: 1991,
      location: 'อิรัก/คูเวต',
      lat: 29.0,
      lon: 47.5,
      description: 'การรบกวนและทำลายระบบป้องกันภัยทางอากาศ\n'
          'ในคืนแรกทำลายเรดาร์อิรักเกือบหมด\n'
          'ใช้ EW ร่วมกับ Stealth อย่างประสานงาน',
      significance: 'EW ยุคดิจิทัล',
      icon: Icons.military_tech,
      color: AppColors.epColor,
    ),
    EWHistoricalEvent(
      id: 'ukraine',
      title: 'สงครามยูเครน',
      year: 2022,
      location: 'ยูเครน',
      lat: 48.4,
      lon: 35.0,
      description: 'การใช้โดรนและ EW ต่อต้านโดรนอย่างกว้างขวาง\n'
          'GPS Jamming และ Spoofing เป็นเรื่องปกติ\n'
          'ทั้งสองฝ่ายพัฒนาเทคนิค EW ใหม่ๆ ต่อเนื่อง',
      significance: 'EW ในสงครามโดรน',
      icon: Icons.airplanemode_active,
      color: AppColors.droneColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _tourController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tourController.dispose();
    super.dispose();
  }

  void _startAutoTour() {
    setState(() {
      _isAutoTour = true;
      _currentTourIndex = 0;
      _selectedEventIndex = 0;
    });
    _runTour();
  }

  void _runTour() async {
    for (int i = 0; i < _events.length && _isAutoTour; i++) {
      setState(() {
        _currentTourIndex = i;
        _selectedEventIndex = i;
      });
      await Future.delayed(const Duration(seconds: 5));
    }
    if (_isAutoTour) {
      setState(() => _isAutoTour = false);
    }
  }

  void _stopAutoTour() {
    setState(() => _isAutoTour = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.public, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'แผนที่ประวัติศาสตร์ EW',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Tour button
                TextButton.icon(
                  onPressed: _isAutoTour ? _stopAutoTour : _startAutoTour,
                  icon: Icon(
                    _isAutoTour ? Icons.stop : Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(_isAutoTour ? 'หยุด' : 'นำชม'),
                  style: TextButton.styleFrom(
                    foregroundColor: _isAutoTour ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Map
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                // World map background
                CustomPaint(
                  size: const Size(double.infinity, 250),
                  painter: _WorldMapPainter(),
                ),

                // Event markers
                ..._events.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final isSelected = _selectedEventIndex == index;

                  return Positioned(
                    left: _longitudeToX(event.lon, context) - (isSelected ? 15 : 10),
                    top: _latitudeToY(event.lat) - (isSelected ? 15 : 10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedEventIndex = isSelected ? -1 : index;
                        _isAutoTour = false;
                      }),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final pulse = isSelected
                              ? 1.0 + _pulseController.value * 0.3
                              : 1.0;
                          return Transform.scale(
                            scale: pulse,
                            child: _EventMarker(
                              event: event,
                              isSelected: isSelected,
                            ),
                          );
                        },
                      ),
                    ).animate(delay: (index * 100).ms).fadeIn().scale(),
                  );
                }),

                // Connection lines when touring
                if (_isAutoTour && _currentTourIndex > 0)
                  CustomPaint(
                    size: const Size(double.infinity, 250),
                    painter: _ConnectionLinePainter(
                      events: _events.sublist(0, _currentTourIndex + 1),
                      getX: (lon) => _longitudeToX(lon, context),
                      getY: _latitudeToY,
                    ),
                  ),
              ],
            ),
          ),

          // Timeline
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                final isSelected = _selectedEventIndex == index;

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedEventIndex = isSelected ? -1 : index;
                    _isAutoTour = false;
                  }),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? event.color.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? event.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${event.year}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? event.color : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(event.icon, color: event.color, size: 16),
                      ],
                    ),
                  ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2),
                );
              },
            ),
          ),

          // Event details
          if (_selectedEventIndex >= 0) ...[
            const Divider(height: 1),
            _EventDetailCard(
              event: _events[_selectedEventIndex],
              onClose: () => setState(() => _selectedEventIndex = -1),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
          ],
        ],
      ),
    );
  }

  double _longitudeToX(double lon, BuildContext context) {
    // Normalize longitude (-180 to 180) to screen width
    final width = MediaQuery.of(context).size.width - 32; // padding
    return ((lon + 180) / 360) * width;
  }

  double _latitudeToY(double lat) {
    // Normalize latitude (90 to -90) to height (0 to 250)
    // Using Mercator-like projection for better visuals
    return ((90 - lat) / 180) * 250;
  }
}

class EWHistoricalEvent {
  final String id;
  final String title;
  final int year;
  final String location;
  final double lat;
  final double lon;
  final String description;
  final String significance;
  final IconData icon;
  final Color color;

  const EWHistoricalEvent({
    required this.id,
    required this.title,
    required this.year,
    required this.location,
    required this.lat,
    required this.lon,
    required this.description,
    required this.significance,
    required this.icon,
    required this.color,
  });
}

class _WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = AppColors.surface;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Longitude lines
    for (int i = 0; i <= 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Latitude lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Simplified continent outlines
    final landPaint = Paint()
      ..color = AppColors.militaryOlive.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Europe/Africa blob
    final europe = Path()
      ..moveTo(size.width * 0.45, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.55, size.height * 0.2,
        size.width * 0.52, size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.48, size.height * 0.5,
        size.width * 0.5, size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.45, size.height * 0.6,
        size.width * 0.42, size.height * 0.35,
      )
      ..close();
    canvas.drawPath(europe, landPaint);

    // Asia blob
    final asia = Path()
      ..moveTo(size.width * 0.55, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.2,
        size.width * 0.8, size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.5,
        size.width * 0.6, size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.55, size.height * 0.3,
        size.width * 0.55, size.height * 0.15,
      )
      ..close();
    canvas.drawPath(asia, landPaint);

    // Americas blob
    final americas = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.25,
        size.width * 0.2, size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.22, size.height * 0.6,
        size.width * 0.18, size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.12, size.height * 0.6,
        size.width * 0.1, size.height * 0.35,
      )
      ..close();
    canvas.drawPath(americas, landPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EventMarker extends StatelessWidget {
  final EWHistoricalEvent event;
  final bool isSelected;

  const _EventMarker({
    required this.event,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSelected ? 30 : 20,
      height: isSelected ? 30 : 20,
      decoration: BoxDecoration(
        color: event.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: event.color.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        event.icon,
        color: Colors.white,
        size: isSelected ? 16 : 10,
      ),
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  final List<EWHistoricalEvent> events;
  final double Function(double) getX;
  final double Function(double) getY;

  _ConnectionLinePainter({
    required this.events,
    required this.getX,
    required this.getY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (events.length < 2) return;

    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < events.length; i++) {
      final x = getX(events[i].lon);
      final y = getY(events[i].lat);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw dashed line
    final dashPath = Path();
    const dashLength = 5.0;
    const gapLength = 3.0;
    var distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }

    canvas.drawPath(dashPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinePainter oldDelegate) {
    return oldDelegate.events.length != events.length;
  }
}

class _EventDetailCard extends StatelessWidget {
  final EWHistoricalEvent event;
  final VoidCallback onClose;

  const _EventDetailCard({
    required this.event,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusL),
          bottomRight: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(event.icon, color: event.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: event.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${event.year} • ${event.location}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                color: AppColors.textMuted,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            event.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Significance tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: event.color, size: 16),
                const SizedBox(width: 6),
                Text(
                  event.significance,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: event.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
