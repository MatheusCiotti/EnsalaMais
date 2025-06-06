import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/room.dart';
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
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
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
                  controller: nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nome da Sala',
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
                  controller: descricaoController,
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
                if (nomeController.text.isNotEmpty) {
                  try {
                    final response = await BlocksService.createRoom(
                      blockId: widget.block.id,
                      nome: nomeController.text,
                      descricao: descricaoController.text.isEmpty
                          ? null
                          : descricaoController.text,
                      hasAirConditioning: hasAirConditioning,
                      hasProjector: hasProjector,
                      hasTV: hasTV,
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
    final nomeController = TextEditingController(text: room.nome);
    final descricaoController = TextEditingController(text: room.descricao ?? '');
    bool hasAirConditioning = room.hasAirConditioning;
    bool hasProjector = room.hasProjector;
    bool hasTV = room.hasTV;

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
                  controller: nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nome da Sala',
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
                  controller: descricaoController,
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
                if (nomeController.text.isNotEmpty) {
                  try {
                    final response = await BlocksService.updateRoom(
                      roomId: room.id,
                      nome: nomeController.text,
                      descricao: descricaoController.text.isEmpty
                          ? null
                          : descricaoController.text,
                      hasAirConditioning: hasAirConditioning,
                      hasProjector: hasProjector,
                      hasTV: hasTV,
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
                        SnackBar(content: Text('Erro ao atualizar sala: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3E8B68), Color(0xFF1E453E)],
          ),
        ),
        child: SafeArea(
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
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : ListView.builder(
                        itemCount: rooms.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return Card(
                            color: Colors.grey[850],
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    room.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (room.descricao != null)
                                        Text(
                                          room.descricao!,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                          ),
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
                                        onPressed: () => _showDeleteConfirmationDialog(room, index),
                                      ),
                                    ],
                                  ),
                                ),
                                if (room.hasAirConditioning || room.hasProjector || room.hasTV)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Wrap(
                                      spacing: 8,
                                      children: [
                                        if (room.hasAirConditioning)
                                          Chip(
                                            backgroundColor: Colors.blue.withOpacity(0.2),
                                            label: const Text(
                                              'Ar Condicionado',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        if (room.hasProjector)
                                          Chip(
                                            backgroundColor: Colors.green.withOpacity(0.2),
                                            label: const Text(
                                              'Projetor',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        if (room.hasTV)
                                          Chip(
                                            backgroundColor: Colors.purple.withOpacity(0.2),
                                            label: const Text(
                                              'TV',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Room room, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir a sala ${room.nome}?\nEsta ação não pode ser desfeita.',
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
                    const SnackBar(content: Text('Sala excluída com sucesso')),
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
} 