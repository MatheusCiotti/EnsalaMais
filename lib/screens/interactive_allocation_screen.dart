import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/room.dart';
import '../services/classes_service.dart';
import '../services/rooms_service.dart';

class InteractiveAllocationScreen extends StatefulWidget {
  const InteractiveAllocationScreen({super.key});

  @override
  State<InteractiveAllocationScreen> createState() => _InteractiveAllocationScreenState();
}

class _InteractiveAllocationScreenState extends State<InteractiveAllocationScreen> {
  bool _isLoading = true;
  String _selectedDay = 'Segunda';
  final List<String> _weekDays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
  List<Class> _unallocatedClasses = [];
  List<Class> _allocatedClasses = [];
  List<Room> _allRooms = [];
  Class? _selectedClassToAllocate;

  @override
  void initState() {
    super.initState();
    _loadDataForDay(_selectedDay);
  }

  Future<void> _loadDataForDay(String day) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _selectedClassToAllocate = null;
    });
    try {
      final results = await Future.wait([
        ClassesService.getUnallocatedClasses(day),
        ClassesService.getAllocatedClasses(day),
        RoomsService.getRooms(),
      ]);
      if (mounted) {
        setState(() {
          _unallocatedClasses = results[0] as List<Class>;
          _allocatedClasses = results[1] as List<Class>;
          _allRooms = results[2] as List<Room>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  void _onAllocate(int roomId, String timeSlot) async {
    if (_selectedClassToAllocate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione uma aula da lista de disponíveis primeiro.'), backgroundColor: Colors.amber));
      return;
    }
    final scheduleText = '$_selectedDay - $timeSlot';
    try {
      await ClassesService.allocateClass(
        classId: _selectedClassToAllocate!.id,
        roomId: roomId,
        schedule: scheduleText,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedClassToAllocate!.name} alocada com sucesso!'), backgroundColor: Colors.green));
      _loadDataForDay(_selectedDay);
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao alocar: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ensalamento Interativo')),
      body: Column(
        children: [
          _buildDaySelector(),
          const Divider(),
          _buildUnallocatedClassesPalette(),
          const Divider(),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _buildAllocationGrid(),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: _selectedDay,
        isExpanded: true,
        items: _weekDays.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedDay = value;
            });
            _loadDataForDay(value);
          }
        },
      ),
    );
  }

  Widget _buildUnallocatedClassesPalette() {
    if (_isLoading) return const SizedBox(height: 80);
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8.0),
      child: _unallocatedClasses.isEmpty
          ? const Center(child: Text('Nenhuma aula disponível para alocar neste dia.'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _unallocatedClasses.length,
              itemBuilder: (context, index) {
                final classItem = _unallocatedClasses[index];
                final isSelected = _selectedClassToAllocate?.id == classItem.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedClassToAllocate = classItem;
                    });
                  },
                  child: Card(
                    color: isSelected ? Colors.orange : Colors.blueGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text(classItem.name, style: const TextStyle(color: Colors.white))),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAllocationGrid() {
    final timeSlots = ['1º Horário', '2º Horário'];
    return Expanded(
      child: ListView.builder(
        itemCount: _allRooms.length,
        itemBuilder: (context, index) {
          final room = _allRooms[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.nome, style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: timeSlots.map((slot) {
                        final allocated = _allocatedClasses.where((c) =>
                            c.roomId == room.id && (c.schedule?.contains(slot) ?? false));
                        if (allocated.isNotEmpty) {
                          return Expanded(
                            child: Card(
                              color: Colors.green.shade800,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(allocated.first.name, style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Tooltip(
                              message: 'Alocar aula na ${room.nome} - $slot',
                              child: IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                                onPressed: () => _onAllocate(room.id, slot),
                              ),
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 