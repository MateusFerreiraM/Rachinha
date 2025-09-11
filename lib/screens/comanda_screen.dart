// lib/screens/comanda_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../widgets/empty_state_widget.dart';
import 'split_bill_screen.dart';
import '../theme/app_colors.dart';

class ComandaScreen extends StatefulWidget {
  final int barId;
  final String barNome;

  const ComandaScreen({
    super.key,
    required this.barId,
    required this.barNome,
  });

  @override
  State<ComandaScreen> createState() => _ComandaScreenState();
}

class _ComandaScreenState extends State<ComandaScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _comandas = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadComandas();
  }

  Future<void> _loadComandas() async {
    final data = await _dbHelper.getComandasDoBar(widget.barId);
    if (mounted) {
      setState(() {
        _comandas = List.from(data);
      });
    }
  }

  void _showComandaDialog({Map<String, dynamic>? comanda}) {
    final isEditing = comanda != null;
    final controller =
        TextEditingController(text: isEditing ? comanda['nome_evento'] : '');
    
    // **** CORREÇÃO DE FUSO HORÁRIO APLICADA AQUI ****
    // Garante que a data inicial para edição também seja local
    DateTime selectedDateTime = isEditing 
        ? DateTime.parse(comanda['data']).toLocal() 
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title:
                  Text(isEditing ? 'Editar Comanda' : 'Adicionar Nova Comanda'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                        hintText: 'Nome do evento (ex: Niver do Fulano)'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today,
                        color: AppColors.primary),
                    title: const Text('Data e Hora'),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime)),
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime(2020),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate == null) return;

                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        initialEntryMode: TimePickerEntryMode.input,
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime == null) return;

                      setDialogState(() {
                        selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Salvar'),
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      if (isEditing) {
                        final updatedComanda =
                            Map<String, dynamic>.from(comanda);
                        updatedComanda['nome_evento'] = controller.text;
                        updatedComanda['data'] =
                            selectedDateTime.toIso8601String();
                        updatedComanda.remove('participant_count');
                        await _dbHelper.updateComanda(updatedComanda);
                        _loadComandas();
                      } else {
                        final newComandaData = {
                          'id_bar': widget.barId,
                          'nome_evento': controller.text,
                          'data': selectedDateTime.toIso8601String()
                        };
                        final newId = await _dbHelper.insertComanda(newComandaData);
                        
                        final newComanda = {
                           'id': newId,
                           'id_bar': newComandaData['id_bar'],
                           'nome_evento': newComandaData['nome_evento'],
                           'data': newComandaData['data'],
                           'participant_count': 0,
                        };

                        final wasEmpty = _comandas.isEmpty;
                        _comandas.insert(0, newComanda);

                        if (wasEmpty) {
                          setState(() {});
                        } else {
                          _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
                        }
                      }
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> comanda, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Tem certeza de que deseja excluir esta comanda e todos os seus itens?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
            onPressed: () async {
              final removedComanda = _comandas[index];
              final comandaId = comanda['id'];

              _listKey.currentState?.removeItem(
                index,
                (context, animation) => _buildItem(removedComanda, animation),
                duration: const Duration(milliseconds: 300),
              );

              setState(() {
                _comandas.removeAt(index);
              });
              
              await _dbHelper.deleteComanda(comandaId);
              
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> comanda, Animation<double> animation) {
    // **** CORREÇÃO DE FUSO HORÁRIO APLICADA AQUI ****
    final localDateTime = DateTime.parse(comanda['data']).toLocal();
    final participantCount = comanda['participant_count'] ?? 0;

    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.receipt_long, color: AppColors.primary),
          title: Text(comanda['nome_evento'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text( // Usando a data local
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(localDateTime)}'),
          trailing: Chip(
            avatar: Icon(Icons.people, size: 16, color: AppColors.textSecondary),
            label: Text('$participantCount',
                style: const TextStyle(color: AppColors.textSecondary)),
            backgroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barNome),
      ),
      body: _comandas.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Nenhuma Comanda Encontrada',
              message:
                  'Clique no botão + para registrar a primeira comanda para este bar.',
            )
          : AnimatedList(
              key: _listKey,
              initialItemCount: _comandas.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index, animation) {
                final comanda = _comandas[index];
                // **** CORREÇÃO DE FUSO HORÁRIO APLICADA AQUI ****
                final localDateTime = DateTime.parse(comanda['data']).toLocal();
                return SizeTransition(
                  sizeFactor: animation,
                  child: Card(
                     child: ListTile(
                      leading: const Icon(Icons.receipt_long, color: AppColors.primary),
                      title: Text(comanda['nome_evento'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text( // Usando a data local
                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(localDateTime)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            avatar: Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                            label: Text('${comanda['participant_count'] ?? 0}', style: const TextStyle(color: AppColors.textSecondary)),
                            backgroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showComandaDialog(comanda: comanda);
                              } else if (value == 'delete') {
                                _showDeleteConfirmationDialog(comanda, index);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Editar')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: AppColors.error), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: AppColors.error))])),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SplitBillScreen(comandaId: comanda['id'], comandaNome: comanda['nome_evento'], comandaData: comanda['data'],),),
                        ).then((_) => _loadComandas());
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComandaDialog(),
        tooltip: 'Adicionar Comanda',
        child: const Icon(Icons.add),
      ),
    );
  }
}