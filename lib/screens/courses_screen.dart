import 'package:flutter/material.dart';
import '../models/class.dart'; // Importe o modelo de Class
import '../models/course.dart';
import '../services/courses_service.dart';
import './course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      print('DEBUG: Carregando cursos na tela de gestão...');
      final coursesData = await CoursesService.getCourses();
      print('DEBUG: Dados recebidos: $coursesData');
      print('DEBUG: Quantidade de cursos: ${coursesData.length}');
      
      if (mounted) {
        setState(() {
          courses = coursesData.map((json) => Course.fromJson(json)).toList();
          _isLoading = false;
        });
        print('DEBUG: Cursos convertidos: ${courses.length}');
      }
    } catch (e) {
      print('DEBUG: Erro ao carregar cursos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cursos: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddEditCourseDialog([Course? course]) async {
    final isEditing = course != null;
    final nameController = TextEditingController(text: course?.name);
    final semesterController = TextEditingController(text: course?.semester.toString() ?? '');
    final coordinatorController = TextEditingController(text: course?.coordinator);
    final durationController = TextEditingController(text: course?.duration.toString() ?? '');
    final descriptionController = TextEditingController(text: course?.description);
    String selectedPeriod = course?.period ?? 'Matutino';

    List<Class> availableClasses = [];
    Set<String> selectedClassIds = {};
    bool isLoadingClasses = true;
    
    if (isEditing) {
      // Esta é uma simplificação. O ideal seria ter uma função que busca os IDs das aulas de um curso.
      // Por enquanto, a edição de aulas não estará pré-selecionada.
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (isLoadingClasses) {
            CoursesService.getAvailableClasses().then((classes) {
              setDialogState(() {
                availableClasses = classes;
                isLoadingClasses = false;
              });
            });
          }

          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(isEditing ? 'Editar Curso' : 'Adicionar Novo Curso', style: const TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nome do Curso', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
                    const SizedBox(height: 16),
                    TextField(controller: semesterController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Semestre Atual', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(value: selectedPeriod, dropdownColor: Colors.grey[850], style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Período', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange))), items: ['Matutino', 'Noturno'].map((String period) => DropdownMenuItem<String>(value: period, child: Text(period))).toList(), onChanged: (String? value) => setDialogState(() => selectedPeriod = value ?? 'Matutino')),
                    const SizedBox(height: 16),
                    TextField(controller: coordinatorController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Professor Coordenador', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
                    const SizedBox(height: 16),
                    TextField(controller: durationController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Duração (semestres)', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
                    const SizedBox(height: 16),
                    TextField(controller: descriptionController, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: InputDecoration(labelText: 'Observações (opcional)', labelStyle: const TextStyle(color: Colors.white), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)))),
                    
                    const SizedBox(height: 24),
                    const Text('Aulas do Curso', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white30),
                    
                    isLoadingClasses
                        ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                        : SizedBox(
                            height: 200, 
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: availableClasses.length,
                              itemBuilder: (context, index) {
                                final currentClass = availableClasses[index];
                                final isSelected = selectedClassIds.contains(currentClass.id);
                                return CheckboxListTile(
                                  title: Text(currentClass.name ?? 'Aula sem nome', style: const TextStyle(color: Colors.white)),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        selectedClassIds.add(currentClass.id);
                                      } else {
                                        selectedClassIds.remove(currentClass.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  
                  try {
                    if (isEditing) {
                      await CoursesService.updateCourseWithClasses(
                        id: course.id,
                        name: nameController.text,
                        semester: int.tryParse(semesterController.text) ?? course.semester,
                        period: selectedPeriod,
                        coordinator: coordinatorController.text,
                        duration: int.tryParse(durationController.text) ?? course.duration,
                        description: descriptionController.text,
                        classIds: selectedClassIds.toList(),
                      );
                    } else {
                      await CoursesService.createCourseWithClasses(
                        name: nameController.text,
                        semester: int.tryParse(semesterController.text) ?? 1,
                        period: selectedPeriod,
                        coordinator: coordinatorController.text,
                        duration: int.tryParse(durationController.text) ?? 1,
                        description: descriptionController.text,
                        classIds: selectedClassIds.toList(),
                      );
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Curso atualizado com sucesso!' : 'Curso criado com sucesso!')));
                      _loadCourses();
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar curso: $e')));
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteCourseDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Excluir Curso', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir o curso ${course.name}?\nEsta ação não pode ser desfeita.', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await CoursesService.deleteCourse(course.id);
                if (mounted) {
                  setState(() {
                    courses.removeWhere((c) => c.id == course.id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Curso excluído com sucesso!')));
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir curso: $e')));
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover)),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    const Text('Gestão de Cursos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return Card(
                              color: Colors.grey[850],
                              margin: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseDetailsScreen(courseId: course.id),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Text(course.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Text('${course.semester}º Semestre - ${course.period}\nCoordenador: ${course.coordinator}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddEditCourseDialog(course)),
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteCourseDialog(course)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCourseDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}