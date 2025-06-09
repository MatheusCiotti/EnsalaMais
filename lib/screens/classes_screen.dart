import 'package:flutter/material.dart';
import '../models/class.dart';
import '../services/classes_service.dart';
import '../services/rooms_service.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<Class> classes = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableProfessors = [];
  List<Map<String, dynamic>> _availableRooms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    if (!_isLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final a = await Future.wait([
        ClassesService.getClasses(),
        ClassesService.getAvailableProfessors(),
        RoomsService.getRooms(),
      ]);

      if (mounted) {
        setState(() {
          classes = a[0] as List<Class>;
          _availableProfessors = a[1] as List<Map<String, dynamic>>;
          _availableRooms = a[2] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddClassDialog() async {
    setState(() { _isLoading = true; });
    await _loadData();

    final nameController = TextEditingController();
    final observationController = TextEditingController();
    final scheduleController = TextEditingController();
    String? selectedProfessorId;
    String? selectedRoomId;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Adicionar Nova Aula', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nome da Aula', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: selectedProfessorId, dropdownColor: Colors.grey[850], style: const TextStyle(color: Colors.white), hint: const Text('Selecione um professor', style: TextStyle(color: Colors.grey)), decoration: InputDecoration(labelText: 'Professor', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange))),
                items: _availableProfessors.map((p) => DropdownMenuItem<String>(value: p['id'] as String?, child: Text(p['name'] as String? ?? 'Professor s/ nome'))).toList(),
                onChanged: (v) => setDialogState(() => selectedProfessorId = v),
              ),
              const SizedBox(height: 16),
              TextField(controller: scheduleController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Horário', hintText: 'Ex: Segunda, 10h-12h', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: selectedRoomId, dropdownColor: Colors.grey[850], style: const TextStyle(color: Colors.white), hint: const Text('Selecione uma sala', style: TextStyle(color: Colors.grey)), decoration: InputDecoration(labelText: 'Sala', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange))),
                items: _availableRooms.map((r) => DropdownMenuItem<String>(value: r['id']?.toString(), child: Text(r['nome'] as String? ?? 'Sala s/ nome'))).toList(),
                onChanged: (v) => setDialogState(() => selectedRoomId = v),
              ),
              const SizedBox(height: 16),
              TextField(controller: observationController, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: InputDecoration(labelText: 'Observação (opcional)', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedProfessorId != null && scheduleController.text.isNotEmpty && selectedRoomId != null) {
                  try {
                    await ClassesService.createClass(name: nameController.text, professorId: selectedProfessorId!, schedule: scheduleController.text, roomId: int.parse(selectedRoomId!), observation: observationController.text.isNotEmpty ? observationController.text : null);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula criada com sucesso!'), backgroundColor: Colors.green));
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERRO DETALHADO: ${e.toString()}'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  // ===== FUNÇÃO DE EDITAR RESTAURADA E CORRIGIDA =====
  void _showEditClassDialog(Class classItem) async {
    setState(() { _isLoading = true; });
    await _loadData();

    final nameController = TextEditingController(text: classItem.name);
    final observationController = TextEditingController(text: classItem.observation ?? '');
    final scheduleController = TextEditingController(text: classItem.schedule ?? '');
    String? selectedProfessorId = classItem.professorId;
    String? selectedRoomId = classItem.roomId?.toString();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Editar Aula', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nome da Aula', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: selectedProfessorId, dropdownColor: Colors.grey[850], style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Professor', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange))),
                items: _availableProfessors.map((p) => DropdownMenuItem<String>(value: p['id'] as String?, child: Text(p['name'] as String? ?? 'Professor s/ nome'))).toList(),
                onChanged: (v) => setDialogState(() => selectedProfessorId = v),
              ),
              const SizedBox(height: 16),
              TextField(controller: scheduleController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Horário', hintText: 'Ex: Segunda, 10h-12h', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: selectedRoomId, dropdownColor: Colors.grey[850], style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Sala', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange))),
                items: _availableRooms.map((r) => DropdownMenuItem<String>(value: r['id']?.toString(), child: Text(r['nome'] as String? ?? 'Sala s/ nome'))).toList(),
                onChanged: (v) => setDialogState(() => selectedRoomId = v),
              ),
              const SizedBox(height: 16),
              TextField(controller: observationController, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: InputDecoration(labelText: 'Observação (opcional)', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedProfessorId != null && scheduleController.text.isNotEmpty && selectedRoomId != null) {
                  try {
                    await ClassesService.updateClass(id: classItem.id, name: nameController.text, professorId: selectedProfessorId!, schedule: scheduleController.text, roomId: int.parse(selectedRoomId!), observation: observationController.text.isNotEmpty ? observationController.text : null);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula atualizada com sucesso!'), backgroundColor: Colors.green));
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar aula: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover))),
        SafeArea(
          child: Column(children: [
            Container(padding: const EdgeInsets.all(16.0), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)), const Text('Gestão de Aulas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))])),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final classItem = classes[index];
                          return Card(
                            color: Colors.grey[850],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              title: Text(classItem.name ?? 'Aula sem nome', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Professor: ${classItem.professorName ?? "Não definido"}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                Text('Horário: ${classItem.schedule ?? "Não definido"}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                Text('Sala: ${classItem.roomName ?? "Não definida"}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                if (classItem.observation != null && classItem.observation!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Obs: ${classItem.observation}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic)),
                                  ),
                              ]),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditClassDialog(classItem)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Colors.grey[900],
                                        title: const Text('Confirmar exclusão', style: TextStyle(color: Colors.white)),
                                        content: Text('Deseja realmente excluir a aula ${classItem.name}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      try {
                                        await ClassesService.deleteClass(classItem.id);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula excluída com sucesso!'), backgroundColor: Colors.green));
                                          _loadData();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir aula: $e'), backgroundColor: Colors.red));
                                        }
                                      }
                                    }
                                  },
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ]),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}