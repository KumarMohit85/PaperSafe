import 'package:flutter/material.dart';

class ActivityLog {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  ActivityLog({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

class ActivityTimelinePage extends StatelessWidget {
  const ActivityTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      ActivityLog(
        title: 'OCR Scan Completed',
        description: 'Extracted 12-digit Aadhaar Card number via ML Kit',
        timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
        icon: Icons.document_scanner,
        color: Colors.tealAccent,
      ),
      ActivityLog(
        title: 'Biometric Unlock',
        description: 'Vault accessed with Fingerprint authentication',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.fingerprint,
        color: Colors.purpleAccent,
      ),
      ActivityLog(
        title: 'Nearby Share Transfer',
        description: 'Sent Class 10th Marksheet PDF to Galaxy S23',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.near_me,
        color: Colors.blueAccent,
      ),
      ActivityLog(
        title: 'QR Code Generated',
        description: 'Created encrypted share QR link for PAN Card',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.qr_code,
        color: Colors.amberAccent,
      ),
      ActivityLog(
        title: 'Document Moved to Trash',
        description: 'Soft deleted "Old Vehicle Insurance.pdf"',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        icon: Icons.delete_outline,
        color: Colors.redAccent,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Activity Timeline & Audit Log', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final isLast = index == logs.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Column
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: log.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: log.color, width: 2),
                      ),
                      child: Icon(log.icon, color: log.color, size: 20),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.white12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Content Column
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                log.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                _formatTimeAgo(log.timestamp),
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            log.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
