import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';

class FindPharmacyScreen extends StatefulWidget {
  const FindPharmacyScreen({super.key});

  @override
  State<FindPharmacyScreen> createState() => _FindPharmacyScreenState();
}

class _FindPharmacyScreenState extends State<FindPharmacyScreen> {
  String _filter = 'All';
  int? _selectedIndex;

  final List<_Pharmacy> _pharmacies = const [
    _Pharmacy(
      name: 'MedPlus Pharmacy',
      address: '123 Main Street, Downtown',
      distance: 0.5,
      rating: 4.5,
      isOpen: true,
      closesAt: '10:00 PM',
      phone: '+1 234-567-8901',
      hasDelivery: true,
      lat: 40.7128,
      lng: -74.0060,
    ),
    _Pharmacy(
      name: 'HealthCare Pharmacy',
      address: '45 Park Avenue, Central',
      distance: 1.2,
      rating: 4.8,
      isOpen: true,
      closesAt: '9:00 PM',
      phone: '+1 234-567-8902',
      hasDelivery: true,
      lat: 40.7549,
      lng: -73.9840,
    ),
    _Pharmacy(
      name: 'City Drug Store',
      address: '78 Oak Lane, Westside',
      distance: 2.0,
      rating: 4.2,
      isOpen: false,
      closesAt: 'Opens 8:00 AM',
      phone: '+1 234-567-8903',
      hasDelivery: false,
      lat: 40.7282,
      lng: -74.0776,
    ),
    _Pharmacy(
      name: 'Wellness Chemist',
      address: '200 River Road, Eastside',
      distance: 2.5,
      rating: 4.6,
      isOpen: true,
      closesAt: '11:00 PM',
      phone: '+1 234-567-8904',
      hasDelivery: true,
      lat: 40.7282,
      lng: -73.9442,
    ),
    _Pharmacy(
      name: 'QuickMeds',
      address: '55 Station Square, Midtown',
      distance: 3.1,
      rating: 4.0,
      isOpen: true,
      closesAt: '8:00 PM',
      phone: '+1 234-567-8905',
      hasDelivery: false,
      lat: 40.7500,
      lng: -73.9967,
    ),
    _Pharmacy(
      name: 'NightOwl Pharmacy',
      address: '10 Broadway, Uptown',
      distance: 3.7,
      rating: 4.3,
      isOpen: true,
      closesAt: 'Open 24 hrs',
      phone: '+1 234-567-8906',
      hasDelivery: true,
      lat: 40.7831,
      lng: -73.9712,
    ),
    _Pharmacy(
      name: 'Apollo Pharmacy',
      address: '88 Lake View Drive, Suburb',
      distance: 5.0,
      rating: 4.7,
      isOpen: false,
      closesAt: 'Opens 9:00 AM',
      phone: '+1 234-567-8907',
      hasDelivery: true,
      lat: 40.6892,
      lng: -74.0445,
    ),
  ];

  List<_Pharmacy> get _filteredPharmacies {
    if (_filter == 'Open') return _pharmacies.where((p) => p.isOpen).toList();
    if (_filter == 'Delivery') {
      return _pharmacies.where((p) => p.hasDelivery).toList();
    }
    return _pharmacies;
  }

  void _showPharmacyDetails(BuildContext context, _Pharmacy p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(p.address,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.isOpen
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: p.isOpen
                            ? AppTheme.successGreen
                            : AppTheme.errorRed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.access_time, label: p.closesAt),
            const SizedBox(height: 8),
            _DetailRow(
                icon: Icons.location_on_outlined,
                label: '${p.distance} km away'),
            const SizedBox(height: 8),
            _DetailRow(
                icon: Icons.star_rounded,
                label: '${p.rating} rating',
                iconColor: Colors.amber),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: p.phone,
            ),
            if (p.hasDelivery) ...[
              const SizedBox(height: 8),
              _DetailRow(
                  icon: Icons.delivery_dining,
                  label: 'Home delivery available',
                  iconColor: AppTheme.primaryBlue),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Calling ${p.phone}...'),
                            backgroundColor: AppTheme.successGreen),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.successGreen,
                      side: const BorderSide(color: AppTheme.successGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Opening directions to ${p.name}...')),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Pharmacy')),
      body: Column(
        children: [
          // Real OpenStreetMap via flutter_map
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(40.7400, -73.9967),
                initialZoom: 11.5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.healthcare.app',
                ),
                MarkerLayer(
                  markers: [
                    // Current location
                    Marker(
                      point: const LatLng(40.7400, -73.9967),
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.primaryBlue, width: 2),
                        ),
                        child: const Icon(Icons.my_location,
                            color: AppTheme.primaryBlue, size: 18),
                      ),
                    ),
                    // Pharmacy markers
                    ..._pharmacies.asMap().entries.map((e) {
                      final idx = e.key;
                      final p = e.value;
                      return Marker(
                        point: LatLng(p.lat, p.lng),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showPharmacyDetails(context, p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedIndex == idx
                                  ? AppTheme.primaryBlue
                                  : p.isOpen
                                      ? AppTheme.successGreen
                                      : AppTheme.errorRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                                Icons.local_pharmacy,
                                color: Colors.white,
                                size: 18),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text('Nearby Pharmacies',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                ...['All', 'Open', 'Delivery'].map((f) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(f,
                            style: const TextStyle(fontSize: 12)),
                        selected: _filter == f,
                        selectedColor: AppTheme.primaryBlue
                            .withValues(alpha: 0.15),
                        onSelected: (_) =>
                            setState(() => _filter = f),
                      ),
                    )),
              ],
            ),
          ),
          // Pharmacy List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPharmacies.length,
              itemBuilder: (context, idx) {
                final p = _filteredPharmacies[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showPharmacyDetails(context, p),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1E88E5),
                                      Color(0xFF42A5F5)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x551E88E5),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.local_pharmacy_rounded,
                                    color: Colors.white,
                                    size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(p.address,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: p.isOpen
                                      ? AppTheme.successGreen
                                          .withValues(alpha: 0.1)
                                      : AppTheme.errorRed
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.isOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: p.isOpen
                                        ? AppTheme.successGreen
                                        : AppTheme.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14,
                                  color: AppTheme.textSecondary),
                              Text(' ${p.distance} km',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                              const SizedBox(width: 16),
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              Text(' ${p.rating}',
                                  style:
                                      const TextStyle(fontSize: 12)),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time,
                                  size: 14,
                                  color: AppTheme.textSecondary),
                              Text(' ${p.closesAt}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                              const Spacer(),
                              if (p.hasDelivery)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delivery_dining,
                                          size: 12,
                                          color: AppTheme.primaryBlue),
                                      SizedBox(width: 2),
                                      Text('Delivery',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  AppTheme.primaryBlue)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  const _DetailRow(
      {required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(label,
            style:
                TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _Pharmacy {
  final String name;
  final String address;
  final double distance;
  final double rating;
  final bool isOpen;
  final String closesAt;
  final String phone;
  final bool hasDelivery;
  final double lat;
  final double lng;

  const _Pharmacy({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.closesAt,
    required this.phone,
    required this.hasDelivery,
    required this.lat,
    required this.lng,
  });
}
