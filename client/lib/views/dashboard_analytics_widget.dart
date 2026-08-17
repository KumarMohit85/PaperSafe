import 'package:flutter/material.dart';

class CategoryMetric {
  final String label;
  final int count;
  final double percentage;
  final Color color;
  final IconData icon;

  CategoryMetric({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class DashboardAnalyticsWidget extends StatelessWidget {
  const DashboardAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      CategoryMetric(
        label: 'Identity Cards',
        count: 4,
        percentage: 0.40,
        color: Colors.tealAccent,
        icon: Icons.badge_outlined,
      ),
      CategoryMetric(
        label: 'Education',
        count: 3,
        percentage: 0.30,
        color: Colors.purpleAccent,
        icon: Icons.school_outlined,
      ),
      CategoryMetric(
        label: 'Financial & Tax',
        count: 2,
        percentage: 0.20,
        color: Colors.amberAccent,
        icon: Icons.account_balance_outlined,
      ),
      CategoryMetric(
        label: 'Travel & Tickets',
        count: 1,
        percentage: 0.10,
        color: Colors.blueAccent,
        icon: Icons.flight_takeoff_outlined,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vault Storage Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '10 Documents',
                  style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-color Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: metrics.map((m) {
                  return Expanded(
                    flex: (m.percentage * 100).toInt(),
                    child: Container(color: m.color),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category List Items
          Column(
            children: metrics.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: m.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(m.icon, color: m.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      m.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${m.count} items',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${(m.percentage * 100).toInt()}%)',
                      style: TextStyle(color: m.color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
