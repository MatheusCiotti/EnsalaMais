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
  List<Room> filteredRooms = [];
  bool _isLoading = true;
  bool _showFilters = false;

  // Controladores de filtro
  final TextEditingController _searchController = TextEditingController();
  bool _filterAirConditioning = false;
  bool _filterProjector = false;
  bool _filterTV = false;
  bool _filterPCD = false;
  bool _filterLeftHanded = false;
  RangeValues _capacityRange = const RangeValues(0, 100);
  double _maxCapacity = 100;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    if(!mounted) return;
    setState(() => _isLoading = true);
    try {
      final roomsData = await BlocksService.getRooms(widget.block.id);
      if (mounted) {
        setState(() {
          rooms = roomsData.map((json) => Room.fromJson(json)).toList();
          filteredRooms = List.from(rooms);
          _isLoading = false;
          
          // Calcular capacidade máxima para o slider
          if (rooms.isNotEmpty) {
            _maxCapacity = rooms.map((r) => r.chairCount.toDouble()).reduce((a, b) => a > b ? a : b);
            _capacityRange = RangeValues(0, _maxCapacity);
          }
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

  void _applyFilters() {
    setState(() {
      filteredRooms = rooms.where((room) {
        // Filtro por nome
        final matchesName = room.nome?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false;
        
        // Filtros de equipamentos
        final matchesAirConditioning = !_filterAirConditioning || room.hasAirConditioning;
        final matchesProjector = !_filterProjector || room.hasProjector;
        final matchesTV = !_filterTV || room.hasTV;
        
        // Filtros de acessibilidade
        final matchesPCD = !_filterPCD || room.pcdChairCount > 0;
        final matchesLeftHanded = !_filterLeftHanded || room.leftHandedChairCount > 0;
        
        // Filtro de capacidade
        final matchesCapacity = room.chairCount >= _capacityRange.start && room.chairCount <= _capacityRange.end;
        
        return matchesName && 
               matchesAirConditioning && 
               matchesProjector && 
               matchesTV && 
               matchesPCD && 
               matchesLeftHanded && 
               matchesCapacity;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterAirConditioning = false;
      _filterProjector = false;
      _filterTV = false;
      _filterPCD = false;
      _filterLeftHanded = false;
      _capacityRange = RangeValues(0, _maxCapacity);
      filteredRooms = List.from(rooms);
    });
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'Limpar',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          
          if (_showFilters) ...[
            const SizedBox(height: 16),
            
            // Busca por nome
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nome da sala...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 20),
            
            // Filtros de equipamentos
            const Text(
              'Equipamentos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Ar Condicionado'),
                  selected: _filterAirConditioning,
                  onSelected: (selected) {
                    setState(() {
                      _filterAirConditioning = selected;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: _filterAirConditioning ? Colors.orange : Colors.white,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(
                    color: _filterAirConditioning ? Colors.orange : Colors.white.withOpacity(0.3),
                  ),
                ),
                FilterChip(
                  label: const Text('Projetor'),
                  selected: _filterProjector,
                  onSelected: (selected) {
                    setState(() {
                      _filterProjector = selected;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: _filterProjector ? Colors.orange : Colors.white,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(
                    color: _filterProjector ? Colors.orange : Colors.white.withOpacity(0.3),
                  ),
                ),
                FilterChip(
                  label: const Text('TV'),
                  selected: _filterTV,
                  onSelected: (selected) {
                    setState(() {
                      _filterTV = selected;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: _filterTV ? Colors.orange : Colors.white,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(
                    color: _filterTV ? Colors.orange : Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Filtros de acessibilidade
            const Text(
              'Acessibilidade',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Cadeiras PCD'),
                  selected: _filterPCD,
                  onSelected: (selected) {
                    setState(() {
                      _filterPCD = selected;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: _filterPCD ? Colors.orange : Colors.white,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(
                    color: _filterPCD ? Colors.orange : Colors.white.withOpacity(0.3),
                  ),
                ),
                FilterChip(
                  label: const Text('Cadeiras Canhotos'),
                  selected: _filterLeftHanded,
                  onSelected: (selected) {
                    setState(() {
                      _filterLeftHanded = selected;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: _filterLeftHanded ? Colors.orange : Colors.white,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(
                    color: _filterLeftHanded ? Colors.orange : Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Filtro de capacidade
            const Text(
              'Capacidade (Nº de Cadeiras)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _capacityRange,
              min: 0,
              max: _maxCapacity,
              divisions: _maxCapacity.toInt(),
              activeColor: Colors.orange,
              inactiveColor: Colors.white.withOpacity(0.3),
              labels: RangeLabels(
                _capacityRange.start.round().toString(),
                _capacityRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _capacityRange = values;
                  _applyFilters();
                });
              },
            ),
            Text(
              'De ${_capacityRange.start.round()} até ${_capacityRange.end.round()} cadeiras',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
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
                      if(mounted) {
                        setState(() {
                          rooms[index] = Room.fromJson(updatedRoom);
                          _applyFilters(); // Reaplicar filtros após atualização
                        });
                      }
                    } else {
                      final newRoom = await BlocksService.createRoom(blockId: widget.block.id, nome: nomeController.text, descricao: descricaoController.text, hasAirConditioning: hasAirConditioning, hasProjector: hasProjector, hasTV: hasTV, chairCount: chairCount, pcdChairCount: pcdChairCount, leftHandedChairCount: leftHandedChairCount);
                      if(mounted) {
                        setState(() {
                          rooms.add(Room.fromJson(newRoom));
                          // Recalcular capacidade máxima se necessário
                          final newCapacity = Room.fromJson(newRoom).chairCount.toDouble();
                          if (newCapacity > _maxCapacity) {
                            _maxCapacity = newCapacity;
                            _capacityRange = RangeValues(_capacityRange.start, _maxCapacity);
                          }
                          _applyFilters(); // Reaplicar filtros após adição
                        });
                      }
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
                  setState(() {
                    rooms.removeWhere((r) => r.id == room.id);
                    _applyFilters(); // Reaplicar filtros após exclusão
                  });
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
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: Text('Salas - ${widget.block.name}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    // Indicador de filtros ativos
                    if (_searchController.text.isNotEmpty || 
                        _filterAirConditioning || 
                        _filterProjector || 
                        _filterTV || 
                        _filterPCD || 
                        _filterLeftHanded ||
                        (_capacityRange.start > 0 || _capacityRange.end < _maxCapacity))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Filtrado',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Seção de filtros
              _buildFilterSection(),
              
              // Indicador de resultados
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredRooms.length} de ${rooms.length} salas',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (filteredRooms.length != rooms.length)
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear, size: 16, color: Colors.orange),
                          label: const Text(
                            'Limpar filtros',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Lista de salas
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : filteredRooms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma sala encontrada',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tente ajustar os filtros ou adicionar uma nova sala',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _clearFilters,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Limpar Filtros'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredRooms.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final room = filteredRooms[index];
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