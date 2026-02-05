import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/constants.dart';

/// Map tile providers
enum MapStyle {
  satellite,
  dark,
  terrain,
}

/// EW World Map Widget - Real map with historical EW events
class EWWorldMapWidget extends StatefulWidget {
  const EWWorldMapWidget({super.key});

  @override
  State<EWWorldMapWidget> createState() => _EWWorldMapWidgetState();
}

class _EWWorldMapWidgetState extends State<EWWorldMapWidget>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _pulseController;
  late AnimationController _markerAnimController;

  int _selectedEventIndex = -1;
  bool _isAutoTour = false;
  int _currentTourIndex = 0;
  MapStyle _currentMapStyle = MapStyle.satellite;

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
      lat: 51.5074,
      lon: -0.1278,
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
      lat: 21.3645,
      lon: -157.9761,
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
      lat: 16.0544,
      lon: 108.2022,
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
      lat: 29.3759,
      lon: 47.9774,
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
      lat: 48.3794,
      lon: 31.1656,
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
    _mapController = MapController();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _markerAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _markerAnimController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String get _tileUrl {
    switch (_currentMapStyle) {
      case MapStyle.satellite:
        // ESRI World Imagery - Free satellite tiles
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.dark:
        // CartoDB Dark Matter - Free dark theme
        return 'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';
      case MapStyle.terrain:
        // OpenTopoMap - Free terrain map
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  void _flyToEvent(int index) {
    if (index < 0 || index >= _events.length) return;

    final event = _events[index];
    _mapController.move(
      LatLng(event.lat, event.lon),
      5.0,
    );

    setState(() {
      _selectedEventIndex = index;
    });

    _markerAnimController.forward(from: 0);
  }

  void _startAutoTour() async {
    setState(() {
      _isAutoTour = true;
      _currentTourIndex = 0;
    });

    for (int i = 0; i < _events.length && _isAutoTour; i++) {
      setState(() => _currentTourIndex = i);
      _flyToEvent(i);
      await Future.delayed(const Duration(seconds: 4));
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
          // Header with controls
          _buildHeader(),

          // Real Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusL),
              ),
              child: Stack(
                children: [
                  // Flutter Map
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(30.0, 20.0),
                      initialZoom: 2.0,
                      minZoom: 1.5,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onTap: (_, point) {
                        setState(() => _selectedEventIndex = -1);
                      },
                    ),
                    children: [
                      // Tile Layer
                      TileLayer(
                        urlTemplate: _tileUrl,
                        userAgentPackageName: 'com.signalschool.signal_nco_ew',
                        maxZoom: 19,
                      ),

                      // Connection lines between events
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _events.map((e) => LatLng(e.lat, e.lon)).toList(),
                            color: AppColors.primary.withAlpha(150),
                            strokeWidth: 2,
                            isDotted: true,
                          ),
                        ],
                      ),

                      // Event Markers
                      MarkerLayer(
                        markers: _events.asMap().entries.map((entry) {
                          final index = entry.key;
                          final event = entry.value;
                          final isSelected = _selectedEventIndex == index;

                          return Marker(
                            point: LatLng(event.lat, event.lon),
                            width: isSelected ? 60 : 40,
                            height: isSelected ? 60 : 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEventIndex = isSelected ? -1 : index;
                                  _isAutoTour = false;
                                });
                                if (!isSelected) {
                                  _mapController.move(
                                    LatLng(event.lat, event.lon),
                                    5.0,
                                  );
                                }
                              },
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final scale = isSelected
                                      ? 1.0 + _pulseController.value * 0.2
                                      : 1.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: _buildMarker(event, isSelected),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Map style selector (top right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildMapStyleSelector(),
                  ),

                  // Zoom controls (bottom right)
                  Positioned(
                    bottom: 80,
                    right: 10,
                    child: _buildZoomControls(),
                  ),

                  // Timeline (bottom)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildTimeline(),
                  ),

                  // Event detail popup
                  if (_selectedEventIndex >= 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 70,
                      child: _EventDetailPopup(
                        event: _events[_selectedEventIndex],
                        onClose: () => setState(() => _selectedEventIndex = -1),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(50)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.esColor, AppColors.eaColor],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'แผนที่ประวัติศาสตร์ EW',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_events.length} เหตุการณ์สำคัญ • ${_events.first.year}-${_events.last.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Tour button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isAutoTour
                    ? [AppColors.error, AppColors.error.withAlpha(200)]
                    : [AppColors.primary, AppColors.primary.withAlpha(200)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isAutoTour ? AppColors.error : AppColors.primary)
                      .withAlpha(100),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _isAutoTour ? _stopAutoTour : _startAutoTour,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isAutoTour ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isAutoTour ? 'หยุด' : 'นำชม',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(EWHistoricalEvent event, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: event.color,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: event.color.withAlpha(isSelected ? 180 : 100),
            blurRadius: isSelected ? 20 : 10,
            spreadRadius: isSelected ? 5 : 2,
          ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          event.icon,
          color: Colors.white,
          size: isSelected ? 24 : 16,
        ),
      ),
    );
  }

  Widget _buildMapStyleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapStyleButton(
            icon: Icons.satellite_alt,
            label: 'ดาวเทียม',
            isSelected: _currentMapStyle == MapStyle.satellite,
            onTap: () => setState(() => _currentMapStyle = MapStyle.satellite),
          ),
          _MapStyleButton(
            icon: Icons.dark_mode,
            label: 'มืด',
            isSelected: _currentMapStyle == MapStyle.dark,
            onTap: () => setState(() => _currentMapStyle = MapStyle.dark),
          ),
          _MapStyleButton(
            icon: Icons.terrain,
            label: 'ภูมิประเทศ',
            isSelected: _currentMapStyle == MapStyle.terrain,
            onTap: () => setState(() => _currentMapStyle = MapStyle.terrain),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.textPrimary,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
          ),
          Container(
            height: 1,
            width: 30,
            color: AppColors.border,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: AppColors.textPrimary,
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withAlpha(200),
            AppColors.background,
          ],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final isSelected = _selectedEventIndex == index;
          final isCurrent = _isAutoTour && _currentTourIndex == index;

          return GestureDetector(
            onTap: () {
              _stopAutoTour();
              _flyToEvent(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 100 : 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected || isCurrent
                    ? LinearGradient(
                        colors: [
                          event.color.withAlpha(200),
                          event.color.withAlpha(150),
                        ],
                      )
                    : null,
                color: isSelected || isCurrent ? null : AppColors.surface.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected || isCurrent ? event.color : AppColors.border,
                  width: isSelected || isCurrent ? 2 : 1,
                ),
                boxShadow: isSelected || isCurrent
                    ? [
                        BoxShadow(
                          color: event.color.withAlpha(100),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.year}',
                    style: TextStyle(
                      color: isSelected || isCurrent
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 16 : 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    event.icon,
                    color: isSelected || isCurrent
                        ? Colors.white
                        : event.color,
                    size: isSelected ? 20 : 16,
                  ),
                ],
              ),
            ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2),
          );
        },
      ),
    );
  }
}

class _MapStyleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapStyleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailPopup extends StatelessWidget {
  final EWHistoricalEvent event;
  final VoidCallback onClose;

  const _EventDetailPopup({
    required this.event,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(245),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: event.color.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: event.color.withAlpha(50),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  event.color.withAlpha(50),
                  event.color.withAlpha(20),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: event.color.withAlpha(150),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(event.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${event.year} • ${event.location}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: event.color,
                          fontWeight: FontWeight.w500,
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
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        event.color.withAlpha(40),
                        event.color.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: event.color.withAlpha(100)),
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
          ),
        ],
      ),
    );
  }
}

/// EW Historical Event model
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
