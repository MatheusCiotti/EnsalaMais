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
    if(!mounted) return;
    setState(() => _isLoading = true);
    try {
      final roomsData = await BlocksService.getRooms(widget.block.id);
      if (mounted) {
        setState(() {
          rooms = roomsData.map((json) => Room.fromJson(json)).toList();
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

  void _showAddEditRoomDialog({Room? room}) {
    final isEditing = room != null;
    final nomeController = TextEditingController(text: room?.nome ?? '');
    final descricaoController = TextEditingController(text: room?.descricao ?? '');
    final chairCountController = TextEditingController(text: room?.chairCount.toString() ?? '0');
    final pcdChairCountController = TextEditingController(text: room?.pcdChairCount.toString() ?? '0');
    final leftHandedChairCountController = TextEditingController(text: room?.leftHandedChairCount.toString() ?? '0');
    
    bool hasAirConditioning = room?.hasAirConditioning ?? false;
    bool hasProjector = room?.hasProjector ?? false;
    bool hasTV = room?.hasTV ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? 'Editar Sala' : 'Adicionar Nova Sala', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nomeController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Nome da Sala')),
                const SizedBox(height: 16),
                TextField(controller: descricaoController, style: const TextStyle(color: Colors.white), maxLines: 2, decoration: _inputDecoration('Descrição (opcional)')),
                const SizedBox(height: 16),
                TextField(controller: chairCountController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: _inputDecoration('Nº de Cadeiras')),
                const SizedBox(height: 16),
                TextField(controller: pcdChairCountController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: _inputDecoration('Nº de Cadeiras PCD')),
                const SizedBox(height: 16),
                TextField(controller: leftHandedChairCountController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: _inputDecoration('Nº de Cadeiras para Canhoto')),
                const SizedBox(height: 24),
                const Text('Equipamentos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                CheckboxListTile(title: const Text('Ar Condicionado', style: TextStyle(color: Colors.white)), value: hasAirConditioning, onChanged: (v) => setDialogState(() => hasAirConditioning = v!), checkColor: Colors.black, activeColor: Colors.orange, contentPadding: EdgeInsets.zero),
                CheckboxListTile(title: const Text('Projetor', style: TextStyle(color: Colors.white)), value: hasProjector, onChanged: (v) => setDialogState(() => hasProjector = v!), checkColor: Colors.black, activeColor: Colors.orange, contentPadding: EdgeInsets.zero),
                CheckboxListTile(title: const Text('TV', style: TextStyle(color: Colors.white)), value: hasTV, onChanged: (v) => setDialogState(() => hasTV = v!), checkColor: Colors.black, activeColor: Colors.orange, contentPadding: EdgeInsets.zero),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                if (nomeController.text.isNotEmpty) {
                  try {
                    final chairCount = int.tryParse(chairCountController.text) ?? 0;
                    final pcdChairCount = int.tryParse(pcdChairCountController.text) ?? 0;
                    final leftHandedChairCount = int.tryParse(leftHandedChairCountController.text) ?? 0;
                    
                    if (isEditing) {
                      final updatedRoom = await BlocksService.updateRoom(roomId: room.id, nome: nomeController.text, descricao: descricaoController.text, hasAirConditioning: hasAirConditioning, hasProjector: hasProjector, hasTV: hasTV, chairCount: chairCount, pcdChairCount: pcdChairCount, leftHandedChairCount: leftHandedChairCount);
                      final index = rooms.indexWhere((r) => r.id == room.id);
                      if(mounted) setState(() => rooms[index] = Room.fromJson(updatedRoom));
                    } else {
                      final newRoom = await BlocksService.createRoom(blockId: widget.block.id, nome: nomeController.text, descricao: descricaoController.text, hasAirConditioning: hasAirConditioning, hasProjector: hasProjector, hasTV: hasTV, chairCount: chairCount, pcdChairCount: pcdChairCount, leftHandedChairCount: leftHandedChairCount);
                      if(mounted) setState(() => rooms.add(Room.fromJson(newRoom)));
                    }
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar sala: $e')));
                  }
                }
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.orange)),
    );
  }

  void _showDeleteConfirmationDialog(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Confirmar Exclusão', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir a sala ${room.nome}?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await BlocksService.deleteRoom(room.id);
                if (mounted) {
                  setState(() => rooms.removeWhere((r) => r.id == room.id));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir sala: $e')));
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    Text('Salas - ${widget.block.name}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  textColor: Colors.white,
                                  title: Text(room.nome ?? 'Sala sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: room.descricao != null && room.descricao!.isNotEmpty ? Text(room.descricao!, style: TextStyle(color: Colors.white.withOpacity(0.7))) : null,
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddEditRoomDialog(room: room)),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmationDialog(room)),
                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Chip(label: Text('${room.chairCount} Cadeiras'), avatar: const Icon(Icons.chair_outlined)),
                                      if(room.pcdChairCount > 0) Chip(label: Text('${room.pcdChairCount} PCD'), avatar: const Icon(Icons.accessible)),
                                      if(room.leftHandedChairCount > 0) Chip(label: Text('${room.leftHandedChairCount} Canhotos'), avatar: const Icon(Icons.front_hand_outlined)),
                                      if (room.hasAirConditioning) const Chip(label: Text('Ar Cond.')),
                                      if (room.hasProjector) const Chip(label: Text('Projetor')),
                                      if (room.hasTV) const Chip(label: Text('TV')),
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
        onPressed: _showAddEditRoomDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}