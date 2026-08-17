import 'package:flutter/material.dart';

class TrashItem {
  final String id;
  final String title;
  final String category;
  final DateTime deletedAt;
  final String fileSize;

  TrashItem({
    required this.id,
    required this.title,
    required this.category,
    required this.deletedAt,
    required this.fileSize,
  });

  int get daysRemaining {
    final purgeDate = deletedAt.add(const Duration(days: 30));
    return purgeDate.difference(DateTime.now()).inDays.clamp(0, 30);
  }
}

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final List<TrashItem> _trashItems = [
    TrashItem(
      id: 'del_1',
      title: 'Old Vehicle Insurance',
      category: 'Financial',
      deletedAt: DateTime.now().subtract(const Duration(days: 5)),
      fileSize: '1.4 MB',
    ),
    TrashItem(
      id: 'del_2',
      title: 'Expired Boarding Pass',
      category: 'Travel',
      deletedAt: DateTime.now().subtract(const Duration(days: 12)),
      fileSize: '820 KB',
    ),
    TrashItem(
      id: 'del_3',
      title: 'Draft Utility Bill Scan',
      category: 'Others',
      deletedAt: DateTime.now().subtract(const Duration(days: 22)),
      fileSize: '2.1 MB',
    ),
  ];

  void _restoreItem(TrashItem item) {
    setState(() {
      _trashItems.removeWhere((i) => i.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} restored to active vault'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _deletePermanently(TrashItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Permanently?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to permanently erase "${item.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _trashItems.removeWhere((i) => i.id == item.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.title} permanently deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _emptyTrash() {
    if (_trashItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Empty Trash?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'All items in trash will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _trashItems.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trash emptied successfully')),
              );
            },
            child: const Text('Empty All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Recycle Bin / Trash', style: TextStyle(color: Colors.white)),
        actions: [
          if (_trashItems.isNotEmpty)
            TextButton.icon(
              onPressed: _emptyTrash,
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
              label: const Text('Empty', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: _trashItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 72, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('Trash is empty', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text(
                    'Deleted documents will stay here for 30 days before being permanently purged.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _trashItems.length,
              itemBuilder: (context, index) {
                final item = _trashItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description, color: Colors.redAccent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.category} • ${item.fileSize}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Purges in ${item.daysRemaining} days',
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.tealAccent),
                        tooltip: 'Restore',
                        onPressed: () => _restoreItem(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        tooltip: 'Delete Permanently',
                        onPressed: () => _deletePermanently(item),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
