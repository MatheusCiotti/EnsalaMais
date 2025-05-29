import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/room.dart';
import '../models/room_equipment.dart';
import '../services/blocks_service.dart';

class RoomsManagementScreen extends StatefulWidget {
  final Block block;

  const RoomsManagementScreen({
    super.key,
    required this.block,
  });

  @override
  State<RoomsManagementScreen> createState() => _RoomsManagementScreenState();
}

class _RoomsManagementScreenState extends State<RoomsManagementScreen> {
  List<Room> rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final roomsData = await BlocksService.getRooms(widget.block.id);
      setState(() {
        rooms = roomsData.map((json) => Room.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar salas: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddRoomDialog() {
    final numberController = TextEditingController();
    final capacityController = TextEditingController();
    final descriptionController = TextEditingController();
    bool hasAirConditioning = false;
    bool hasProjector = false;
    bool hasTV = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Adicionar Nova Sala',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numberController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Número da Sala',
                    hintText: 'Ex: 16C',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Capacidade (cadeiras)',
                    hintText: 'Ex: 20',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descrição (opcional)',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Equipamentos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Ar Condicionado',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: hasAirConditioning,
                  onChanged: (value) {
                    setDialogState(() {
                      hasAirConditioning = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: Colors.orange,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Projetor',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: hasProjector,
                  onChanged: (value) {
                    setDialogState(() {
                      hasProjector = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: Colors.orange,
                ),
                CheckboxListTile(
                  title: const Text(
                    'TV',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: hasTV,
                  onChanged: (value) {
                    setDialogState(() {
                      hasTV = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (numberController.text.isNotEmpty &&
                    capacityController.text.isNotEmpty) {
                  try {
                    final equipment = RoomEquipment(
                      hasAirConditioning: hasAirConditioning,
                      hasProjector: hasProjector,
                      hasTV: hasTV,
                    );

                    final response = await BlocksService.createRoom(
                      blockId: widget.block.id,
                      number: numberController.text,
                      capacity: int.parse(capacityController.text),
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      equipment: equipment,
                    );
                    
                    if (mounted) {
                      setState(() {
                        rooms.add(Room.fromJson(response));
                      });
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao criar sala: $e')),
                      );
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

  void _showEditRoomDialog(Room room, int index) {
    final numberController = TextEditingController(text: room.number);
    final capacityController = TextEditingController(text: room.capacity.toString());
    final descriptionController = TextEditingController(text: room.description ?? '');
    bool hasAirConditioning = room.equipment.hasAirConditioning;
    bool hasProjector = room.equipment.hasProjector;
    bool hasTV = room.equipment.hasTV;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Editar Sala',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numberController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Número da Sala',
                    hintText: 'Ex: 16C',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Capacidade (cadeiras)',
                    hintText: 'Ex: 20',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descrição (opcional)',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Equipamentos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Ar Condicionado',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: hasAirConditioning,
                  onChanged: (value) {
                    setDialogState(() {
                      hasAirConditioning = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: Colors.orange,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Projetor',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: hasProjector,
                  onChanged: (value) {
                    setDialogState(() {
                      hasProjector = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: Colors.orange,
                ),
                CheckboxListTile(
                  title: const Text(
                    'TV',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: hasTV,
                  onChanged: (value) {
                    setDialogState(() {
                      hasTV = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (numberController.text.isNotEmpty &&
                    capacityController.text.isNotEmpty) {
                  try {
                    final equipment = RoomEquipment(
                      hasAirConditioning: hasAirConditioning,
                      hasProjector: hasProjector,
                      hasTV: hasTV,
                    );

                    final response = await BlocksService.updateRoom(
                      id: room.id,
                      number: numberController.text,
                      capacity: int.parse(capacityController.text),
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      equipment: equipment,
                    );
                    
                    if (mounted) {
                      setState(() {
                        rooms[index] = Room.fromJson(response);
                      });
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao editar sala: $e')),
                      );
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

  void _showDeleteRoomDialog(Room room, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Excluir Sala',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir a sala ${room.number}?\nEsta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              try {
                await BlocksService.deleteRoom(room.id);
                if (mounted) {
                  setState(() {
                    rooms.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sala excluída com sucesso!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir sala: $e')),
                  );
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
          // Fundo com imagem
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tela.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Conteúdo
          SafeArea(
            child: Column(
              children: [
                // AppBar customizada
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Salas - ${widget.block.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de salas
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return Card(
                                color: Colors.grey[850],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'Sala ${room.number}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Capacidade: ${room.capacity} alunos',
                                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                      ),
                                      if (room.description != null && room.description!.isNotEmpty)
                                        Text(
                                          room.description!,
                                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                        ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          if (room.equipment.hasAirConditioning)
                                            Chip(
                                              backgroundColor: Colors.blue.withOpacity(0.2),
                                              label: const Text(
                                                'Ar Condicionado',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          if (room.equipment.hasProjector)
                                            Chip(
                                              backgroundColor: Colors.green.withOpacity(0.2),
                                              label: const Text(
                                                'Projetor',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          if (room.equipment.hasTV)
                                            Chip(
                                              backgroundColor: Colors.purple.withOpacity(0.2),
                                              label: const Text(
                                                'TV',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _showEditRoomDialog(room, index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _showDeleteRoomDialog(room, index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
} 