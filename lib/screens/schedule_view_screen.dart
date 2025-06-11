import 'package:flutter/material.dart';
import '../models/class.dart'; // Certifique-se que o modelo Class está importado
import '../services/classes_service.dart';

class ScheduleViewScreen extends StatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  // A estrutura agora guarda o Map completo que vem do Supabase
  final Map<String, List<Map<String, dynamic>>> _scheduleByDay = {};

  final List<String> _weekDays = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekDays.length, vsync: this);
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final fullScheduleData = await ClassesService.getFullSchedule();
      
      _scheduleByDay.clear();
      for (var item in fullScheduleData) {
        final day = item['day_of_week'];
        if (day != null) {
          _scheduleByDay.putIfAbsent(day, () => []);
          _scheduleByDay[day]!.add(item);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade de Ensalamento'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _weekDays.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erro: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: _weekDays.map((day) {
                    final daySchedule = _scheduleByDay[day] ?? [];
                    return ScheduleDayGrid(
                      scheduleForDay: daySchedule,
                      onScheduleChange: _loadSchedule, // Passando a função de recarregar
                    );
                  }).toList(),
                ),
    );
  }
}

// Widget auxiliar para construir a grade de um dia
class ScheduleDayGrid extends StatelessWidget {
  final List<Map<String, dynamic>> scheduleForDay;
  final Future<void> Function() onScheduleChange;

  const ScheduleDayGrid({
    super.key, 
    required this.scheduleForDay,
    required this.onScheduleChange,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduleForDay.isEmpty) {
      return const Center(child: Text('Nenhuma aula alocada para este dia.'));
    }

    // Agrupa as aulas por sala
    final Map<String, List<Map<String, dynamic>>> scheduleByRoom = {};
    for (var item in scheduleForDay) {
      final roomName = item['room']?['nome'] ?? 'Sala Desconhecida';
      scheduleByRoom.putIfAbsent(roomName, () => []);
      scheduleByRoom[roomName]!.add(item);
    }
    
    final sortedRoomNames = scheduleByRoom.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedRoomNames.length,
      itemBuilder: (context, index) {
        final roomName = sortedRoomNames[index];
        final itemsInRoom = scheduleByRoom[roomName]!;
        itemsInRoom.sort((a, b) => (a['time_slot'] as String).compareTo(b['time_slot'] as String));

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roomName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(height: 20),
                Column(
                  children: itemsInRoom.map((item) {
                    // Conversão para objeto Class feita aqui, no momento do uso
                    final classItem = Class.fromJson(item['class']); 
                    final timeSlot = item['time_slot'];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('$timeSlot: ${classItem.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${classItem.courseName ?? 'Curso não definido'}\nProfessor: ${classItem.professorName ?? "Não definido"}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.blue),
                            tooltip: 'Editar (a implementar)',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidade de editar a ser implementada.')));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'Excluir Alocação',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: Text('Deseja realmente remover a aula "${classItem.name}" deste horário?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Excluir')),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                try {
                                  // Usa o ID do registro de 'ensalamentos', que está no nível principal do 'item'
                                  await ClassesService.deleteEnsalamento(item['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alocação removida!'), backgroundColor: Colors.green));
                                  await onScheduleChange(); 
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 