import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/room.dart';
import '../services/classes_service.dart';
import '../services/rooms_service.dart';

class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  List<Class> _unallocatedClasses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _unallocatedClasses = await ClassesService.getUnallocatedClasses('Segunda');
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAllocationDialog(Class classToAllocate) async {
    final scheduleController = TextEditingController();
    int? selectedRoomId;
    List<Room> availableRooms = [];

    try {
      availableRooms = await RoomsService.getRooms();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar salas: $e')));
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Alocar Aula: ${classToAllocate.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedRoomId,
                hint: const Text('Selecione uma sala'),
                items: availableRooms.map((room) {
                  return DropdownMenuItem<int>(
                    value: room.id,
                    child: Text(room.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedRoomId = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Horário',
                  hintText: 'Ex: 1º Horário (19:00 - 20:40)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (selectedRoomId != null && scheduleController.text.isNotEmpty) {
                  try {
                    await ClassesService.allocateClass(
                      classId: classToAllocate.id,
                      roomId: selectedRoomId!,
                      schedule: scheduleController.text,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula alocada com sucesso!'), backgroundColor: Colors.green));
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Salvar Alocação'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ensalamento - Aulas Disponíveis')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.orange[50],
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Central de Ensalamento',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Bem-vindo à área de alocação de aulas. É aqui que o planejamento do semestre toma forma.\n\nAções: A lista abaixo exibe todas as aulas que aguardam a definição de uma sala e um horário.\nObjetivo: Utilize o botão "Alocar" em cada item para atribuir os espaços físicos e horários, garantindo que cada turma tenha seu local de estudo.\nAo final do processo, a grade horária estará completa e organizada para todos os alunos e professores.',
                              style: TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _unallocatedClasses.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Ensalamento Concluído!\n\nTodas as aulas foram alocadas com sucesso em suas respectivas salas e horários.\n\nVocê pode visualizar a grade completa na tela de "Grade Horária" ou gerenciar as aulas existentes na tela de "Gestão de Aulas".',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _unallocatedClasses.length,
                            itemBuilder: (context, index) {
                              final classItem = _unallocatedClasses[index];
                              return ListTile(
                                title: Text(classItem.name),
                                subtitle: Text('Professor: ${classItem.professorName ?? "Não definido"}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _showAllocationDialog(classItem),
                                  child: const Text('Alocar'),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
} 