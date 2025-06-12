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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carregando dados do formulário...')));
    
    final List<Map<String, dynamic>> availableProfessors;
    try {
      availableProfessors = await ClassesService.getAvailableProfessors();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar professores: $e'), backgroundColor: Colors.red));
      return;
    }

    if (!mounted) return;
    
    final nameController = TextEditingController();
    final observationController = TextEditingController();
    String? selectedProfessorId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Adicionar Nova Aula', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nome da Aula', labelStyle: const TextStyle(color: Colors.white))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedProfessorId,
                  hint: const Text('Selecione um professor'),
                  dropdownColor: Colors.grey[850],
                  items: availableProfessors.map((professor) {
                    return DropdownMenuItem<String>(
                      value: professor['id'],
                      child: Text(professor['name'] ?? 'Professor sem nome', style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedProfessorId = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(controller: observationController, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: InputDecoration(labelText: 'Observação (opcional)', labelStyle: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedProfessorId != null) {
                  try {
                    await ClassesService.createClass(
                      name: nameController.text,
                      professorId: selectedProfessorId!,
                      observation: observationController.text.isNotEmpty ? observationController.text : null,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula criada com sucesso!'), backgroundColor: Colors.green));
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar aula: $e'), backgroundColor: Colors.red));
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

  void _showEditClassDialog(Class classItem) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carregando dados do formulário...')));

    final List<Map<String, dynamic>> availableProfessors;
    try {
      availableProfessors = await ClassesService.getAvailableProfessors();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar professores: $e'), backgroundColor: Colors.red));
      return;
    }

    if (!mounted) return;

    final nameController = TextEditingController(text: classItem.name);
    final observationController = TextEditingController(text: classItem.observation ?? '');
    String? selectedProfessorId = classItem.professorId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Editar Aula', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nome da Aula', labelStyle: const TextStyle(color: Colors.white))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedProfessorId,
                  hint: const Text('Selecione um professor'),
                  dropdownColor: Colors.grey[850],
                  items: availableProfessors.map((professor) {
                    return DropdownMenuItem<String>(
                      value: professor['id'],
                      child: Text(professor['name'] ?? 'Professor sem nome', style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedProfessorId = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(controller: observationController, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: InputDecoration(labelText: 'Observação (opcional)', labelStyle: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedProfessorId != null) {
                  try {
                    await ClassesService.updateClass(
                      id: classItem.id,
                      name: nameController.text,
                      professorId: selectedProfessorId!,
                      observation: observationController.text.isNotEmpty ? observationController.text : null,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula atualizada com sucesso!'), backgroundColor: Colors.green));
                      _loadData();
                    }
                  } catch (e) {
                     if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar aula: $e'), backgroundColor: Colors.red));
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

  // Função para remover códigos de cor ANSI de uma string
  String cleanAnsiCodes(String text) {
    final ansiRegex = RegExp(r'[\u001B\u009B][[()#;?]*.{0,2}(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]');
    return text.replaceAll(ansiRegex, '');
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
                                Text('Professor: ${cleanAnsiCodes(classItem.professorName ?? "Não definido")}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                if (classItem.observation != null && classItem.observation!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Obs: ${cleanAnsiCodes(classItem.observation!)}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic)),
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