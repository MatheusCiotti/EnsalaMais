import 'package:flutter/material.dart';
import '../services/rooms_service.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await RoomsService.getRooms();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar salas: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Salas'),
        backgroundColor: Colors.grey[850],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      room['nome'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((room['descricao'] ?? '').isNotEmpty)
                          Text(
                            room['descricao'],
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            if (room['chair_count'] != null && room['chair_count'] > 0)
                              InfoTag(icon: Icons.chair_alt, label: '${room['chair_count']} Cadeiras'),
                            if (room['pcd_chair_count'] != null && room['pcd_chair_count'] > 0)
                              InfoTag(icon: Icons.accessible, label: '${room['pcd_chair_count']} PCD'),
                            if (room['left_handed_chair_count'] != null && room['left_handed_chair_count'] > 0)
                              InfoTag(icon: Icons.edit_note, label: '${room['left_handed_chair_count']} Canhotos'),
                            if (room['has_air_conditioning'] == true)
                              InfoTag(icon: Icons.ac_unit, label: 'Ar Cond.'),
                            if (room['has_projector'] == true)
                              InfoTag(icon: Icons.videocam, label: 'Projetor'),
                            if (room['has_tv'] == true)
                              InfoTag(icon: Icons.tv, label: 'TV'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Widget auxiliar para exibir uma tag de informação
Widget InfoTag({required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
  );
} 