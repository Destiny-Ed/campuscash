import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final LatLng _campusCenter = const LatLng(6.5244, 3.3792); // example

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadPins('demo-uni');
    });
  }

  void _showPinSheet(dynamic pin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PinBottomSheet(pin: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final map = context.watch<MapProvider>();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _campusCenter, zoom: 16),
            onMapCreated: (c) => _controller = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: map.pins.map((p) {
              final isFree = p['isFree'] == true;
              return Marker(
                markerId: MarkerId(p['id']),
                position: LatLng(p['lat'], p['lng']),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  isFree ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
                ),
                onTap: () => _showPinSheet(p),
              );
            }).toSet(),
          ),

          // Top search bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Iconsax.search_normal_1, color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search campus locations...',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Iconsax.filter, color: AppTheme.primary, size: 18),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
            ),
          ),

          // Legend
          Positioned(
            left: 16,
            bottom: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
                ],
              ),
              child: Row(
                children: [
                  _LegendDot(color: Colors.green, label: 'Free'),
                  const SizedBox(width: 14),
                  _LegendDot(color: Colors.orange, label: 'Paid'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),

          // FAB Add Pin
          Positioned(
            right: 20,
            bottom: 110,
            child: FloatingActionButton.extended(
              onPressed: () {
                // open add pin sheet
              },
              backgroundColor: AppTheme.primary,
              elevation: 6,
              icon: const Icon(Iconsax.add, color: Colors.white),
              label: const Text('Add Pin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PinBottomSheet extends StatelessWidget {
  final dynamic pin;
  const _PinBottomSheet({required this.pin});

  @override
  Widget build(BuildContext context) {
    final isFree = pin['isFree'] == true;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  pin['title'] ?? 'Location',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isFree ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFree ? 'FREE' : '\$${pin['price'] ?? 0}',
                  style: TextStyle(
                    color: isFree ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pin['description'] ?? '',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.routing, size: 18),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.heart, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}
