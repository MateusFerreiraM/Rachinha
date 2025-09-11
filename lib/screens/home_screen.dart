// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../widgets/empty_state_widget.dart';
import 'comanda_screen.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _bares = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadBares();
  }

  Future<void> _loadBares() async {
    final data = await _dbHelper.getAllBares();
    if (mounted) {
      setState(() {
        _bares = List.from(data);
      });
    }
  }

  void _showBarDialog({Map<String, dynamic>? bar}) {
    final bool isEditing = bar != null;
    final TextEditingController barNameController =
        TextEditingController(text: isEditing ? bar['nome'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Bar' : 'Adicionar Novo Bar'),
          content: TextField(
            controller: barNameController,
            decoration: const InputDecoration(hintText: 'Nome do bar'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () async {
                final nome = barNameController.text;
                if (nome.isNotEmpty) {
                  if (isEditing) {
                    final updatedBar = Map<String, dynamic>.from(bar);
                    updatedBar['nome'] = nome;
                    await _dbHelper.updateBar(updatedBar);
                    _loadBares();
                  } else {
                    final newBarData = {
                      'nome': nome,
                      'createdAt': DateTime.now().toIso8601String(),
                    };
                    final newId = await _dbHelper.insertBar(newBarData);
                    final newBar = {
                      'id': newId,
                      'nome': newBarData['nome'],
                      'createdAt': newBarData['createdAt'],
                    };
                    
                    final wasEmpty = _bares.isEmpty;
                    _bares.insert(0, newBar);

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
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> bar, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Tem certeza de que deseja excluir este bar? Todas as comandas associadas a ele também serão removidas.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
            onPressed: () async {
              final removedBar = _bares[index];
              final barId = bar['id'];

              _listKey.currentState?.removeItem(
                index,
                (context, animation) => _buildItem(removedBar, animation),
                duration: const Duration(milliseconds: 300),
              );

              setState(() {
                _bares.removeAt(index);
              });

              await _dbHelper.deleteBar(barId);

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> bar, Animation<double> animation) {
    // **** CORREÇÃO DE FUSO HORÁRIO APLICADA AQUI ****
    final localDateTime = DateTime.parse(bar['createdAt']).toLocal();

    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.sports_bar, color: AppColors.primary),
          title: Text(bar['nome'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              'Adicionado em: ${DateFormat('dd/MM/yyyy').format(localDateTime)}'), // Usando a data local
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Bares'),
      ),
      body: _bares.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.sports_bar_outlined,
              title: 'Nenhum Bar Cadastrado',
              message:
                  'Clique no botão + para adicionar seu primeiro bar e começar a rachar as contas!',
            )
          : AnimatedList(
              key: _listKey,
              initialItemCount: _bares.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index, animation) {
                final bar = _bares[index];
                // **** CORREÇÃO DE FUSO HORÁRIO APLICADA AQUI ****
                final localDateTime = DateTime.parse(bar['createdAt']).toLocal();
                return SizeTransition(
                  sizeFactor: animation,
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.sports_bar, color: AppColors.primary),
                      title: Text(bar['nome'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text( // Usando a data local
                          'Adicionado em: ${DateFormat('dd/MM/yyyy').format(localDateTime)}'),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showBarDialog(bar: bar);
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(bar, index);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8),Text('Editar'),],),),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: AppColors.error), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: AppColors.error)),],),),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ComandaScreen(barId: bar['id'], barNome: bar['nome'],),),
                        ).then((_) => _loadBares());
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBarDialog(),
        tooltip: 'Adicionar Bar',
        child: const Icon(Icons.add),
      ),
    );
  }
}