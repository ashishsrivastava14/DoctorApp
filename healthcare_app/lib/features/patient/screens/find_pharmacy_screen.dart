import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FindPharmacyScreen extends StatefulWidget {
  const FindPharmacyScreen({super.key});

  @override
  State<FindPharmacyScreen> createState() => _FindPharmacyScreenState();
}

class _FindPharmacyScreenState extends State<FindPharmacyScreen> {
  String _filter = 'All';

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
    ),
  ];

  List<_Pharmacy> get _filteredPharmacies {
    if (_filter == 'Open') return _pharmacies.where((p) => p.isOpen).toList();
    if (_filter == 'Delivery') {
      return _pharmacies.where((p) => p.hasDelivery).toList();
    }
    return _pharmacies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Pharmacy')),
      body: Column(
        children: [
          // Mock Map Placeholder
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Map View',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      Text('Interactive map would appear here',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                ),
                // Fake map pins
                const Positioned(
                  top: 60,
                  left: 80,
                  child: Icon(Icons.location_on,
                      color: AppTheme.primaryBlue, size: 28),
                ),
                const Positioned(
                  top: 90,
                  left: 180,
                  child: Icon(Icons.location_on,
                      color: AppTheme.primaryBlue, size: 28),
                ),
                const Positioned(
                  top: 50,
                  right: 100,
                  child: Icon(Icons.location_on,
                      color: AppTheme.primaryBlue, size: 28),
                ),
                const Positioned(
                  bottom: 40,
                  left: 130,
                  child: Icon(Icons.location_on,
                      color: AppTheme.primaryBlue, size: 28),
                ),
                // Current location marker
                Positioned(
                  top: 80,
                  left: MediaQuery.of(context).size.width / 2 - 14,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('Nearby Pharmacies',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                ...['All', 'Open', 'Delivery'].map((f) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(f, style: const TextStyle(fontSize: 12)),
                        selected: _filter == f,
                        selectedColor:
                            AppTheme.primaryBlue.withValues(alpha: 0.15),
                        onSelected: (_) => setState(() => _filter = f),
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
                                  colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x551E88E5),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.local_pharmacy_rounded,
                                  color: Colors.white, size: 24),
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
                                          color: AppTheme.textSecondary)),
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
                                size: 14, color: AppTheme.textSecondary),
                            Text(' ${p.distance} km',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(width: 16),
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            Text(' ${p.rating}',
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 16),
                            Icon(Icons.access_time,
                                size: 14, color: AppTheme.textSecondary),
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
                                            color: AppTheme.primaryBlue)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
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

class _Pharmacy {
  final String name;
  final String address;
  final double distance;
  final double rating;
  final bool isOpen;
  final String closesAt;
  final String phone;
  final bool hasDelivery;

  const _Pharmacy({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.closesAt,
    required this.phone,
    required this.hasDelivery,
  });
}
