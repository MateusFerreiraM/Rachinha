// lib/screens/split_bill_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/database_helper.dart';
import '../theme/app_colors.dart';

class SplitBillScreen extends StatefulWidget {
  final int comandaId;
  final String comandaNome;
  final String comandaData;

  const SplitBillScreen({
    super.key,
    required this.comandaId,
    required this.comandaNome,
    required this.comandaData,
  });

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _participantes = [];
  List<Map<String, dynamic>> _itens = [];
  final Map<int, List<Map<String, dynamic>>> _itemLinks = {};

  bool _incluirServico = true;
  double _percentualServico = 10.0;
  final TextEditingController _servicoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _servicoController.text = _percentualServico.toStringAsFixed(0);
    _loadAllData();
  }

  @override
  void dispose() {
    _servicoController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final participantesData =
        await _dbHelper.getParticipantsForComanda(widget.comandaId);
    final itensData = await _dbHelper.getItemsForComanda(widget.comandaId);

    _itemLinks.clear();
    for (var item in itensData) {
      final linksData = await _dbHelper.getLinksForItem(item['id']);
      _itemLinks[item['id']] = linksData;
    }

    if (mounted) {
      setState(() {
        _participantes = participantesData;
        _itens = itensData;
      });
    }
  }

  void _showAddParticipantDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Participante'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nome')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await _dbHelper.insertParticipant({
                    'id_comanda': widget.comandaId,
                    'nome': controller.text
                  });
                  Navigator.pop(context);
                  _loadAllData();
                }
              },
              child: const Text('Salvar')),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nomeController = TextEditingController();
    final valorController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                    hintText: 'Nome do item (ex: Porção de Fritas)')),
            TextField(
                controller: valorController,
                decoration:
                    const InputDecoration(hintText: 'Valor total do item'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () async {
                final nome = nomeController.text;
                final valor =
                    double.tryParse(valorController.text.replaceAll(',', '.'));
                if (nome.isNotEmpty && valor != null) {
                  await _dbHelper.insertItem({
                    'id_comanda': widget.comandaId,
                    'descricao': nome,
                    'valor_total': valor
                  });
                  Navigator.pop(context);
                  _loadAllData();
                }
              },
              child: const Text('Salvar')),
        ],
      ),
    );
  }

  void _showDeleteParticipantConfirmationDialog(Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja remover "${participant['nome']}"? Ele será removido de todos os itens com os quais foi associado.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
            onPressed: () async {
              await _dbHelper.deleteParticipant(participant['id']);
              Navigator.of(context).pop();
              _loadAllData();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteItemConfirmationDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja excluir o item "${item['descricao']}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
            onPressed: () async {
              await _dbHelper.deleteItem(item['id']);
              Navigator.of(context).pop();
              _loadAllData();
            },
          ),
        ],
      ),
    );
  }


  void _showAssignItemDialog(Map<String, dynamic> item) {
    List<int> selectedParticipantesIds = _itemLinks[item['id']]
            ?.map<int>((p) => p['id_participante'] as int)
            .toList() ??
        [];
    Map<int, int> quantidades = {};
    _itemLinks[item['id']]?.forEach((p) {
      quantidades[p['id_participante']] = p['quantidade'];
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Dividir "${item['descricao']}"'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _participantes.length,
                  itemBuilder: (context, index) {
                    final participante = _participantes[index];
                    final bool isSelected =
                        selectedParticipantesIds.contains(participante['id']);

                    return CheckboxListTile(
                      title: Text(participante['nome']),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            selectedParticipantesIds.add(participante['id']);
                            quantidades[participante['id']] = 1;
                          } else {
                            selectedParticipantesIds.remove(participante['id']);
                            quantidades.remove(participante['id']);
                          }
                        });
                      },
                      secondary: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if ((quantidades[participante['id']] ??
                                              1) >
                                          1) {
                                        setDialogState(() =>
                                            quantidades[participante['id']] =
                                                (quantidades[
                                                        participante['id']] ??
                                                    1) -
                                                1);
                                      }
                                    }),
                                Text(
                                    '${quantidades[participante['id']] ?? 1}'),
                                IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setDialogState(() =>
                                          quantidades[participante['id']] =
                                              (quantidades[
                                                      participante['id']] ??
                                                  1) +
                                              1);
                                    }),
                              ],
                            )
                          : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  child: const Text('Salvar'),
                  onPressed: () async {
                    await _dbHelper.clearLinksForItem(item['id']);
                    for (var idParticipante in selectedParticipantesIds) {
                      await _dbHelper.linkItemToParticipant(item['id'],
                          idParticipante, quantidades[idParticipante] ?? 1);
                    }
                    Navigator.pop(context);
                    _loadAllData();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<int, double> _calculateTotals() {
    Map<int, double> totals = {
      for (var p in _participantes) p['id']: 0.0
    };

    for (var item in _itens) {
      final List<Map<String, dynamic>> links = _itemLinks[item['id']] ?? [];
      if (links.isEmpty) continue;

      final double valorTotalItem = item['valor_total'];
      int quantidadeTotalConsumida =
          links.fold(0, (sum, link) => sum + (link['quantidade'] as int));

      if (quantidadeTotalConsumida == 0) continue;

      for (var link in links) {
        final idParticipante = link['id_participante'];
        final quantidadeParticipante = link['quantidade'];

        double valorParticipante =
            (valorTotalItem / quantidadeTotalConsumida) *
                quantidadeParticipante;
        totals[idParticipante] =
            (totals[idParticipante] ?? 0) + valorParticipante;
      }
    }
    return totals;
  }

  void _shareSummary() {
    final totals = _calculateTotals();

    // **** CORREÇÃO DE FUSO HORÁRIO APLICADA AQUI ****
    final dataDoEvento = DateTime.parse(widget.comandaData).toLocal();
    final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dataDoEvento);

    String summary = 'Resumo da Conta: ${widget.comandaNome}\n';
    summary += 'Data: $dataFormatada\n\n';

    for (var participante in _participantes) {
      final subtotal = totals[participante['id']] ?? 0.0;
      final servico =
          _incluirServico ? subtotal * (_percentualServico / 100.0) : 0.0;
      final total = subtotal + servico;

      summary += '👤 ${participante['nome']}:\n';
      summary += '  - Consumo: R\$ ${subtotal.toStringAsFixed(2)}\n';
      if (_incluirServico && servico > 0) {
        summary +=
            '  - Serviço (${_percentualServico.toStringAsFixed(0)}%): R\$ ${servico.toStringAsFixed(2)}\n';
      }
      summary += '  - ✅ TOTAL: R\$ ${total.toStringAsFixed(2)}\n\n';
    }

    double totalConsumo =
        totals.values.isNotEmpty ? totals.values.reduce((a, b) => a + b) : 0.0;
    double totalServico =
        _incluirServico ? totalConsumo * (_percentualServico / 100.0) : 0.0;
    double totalGeral = totalConsumo + totalServico;

    summary += '--------------------\n';
    summary += '💰 VALOR TOTAL DA CONTA: R\$ ${totalGeral.toStringAsFixed(2)}';

    Share.share(summary);
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    double totalConsumo =
        totals.values.isNotEmpty ? totals.values.reduce((a, b) => a + b) : 0.0;
    double totalServico =
        _incluirServico ? totalConsumo * (_percentualServico / 100.0) : 0.0;
    double totalGeral = totalConsumo + totalServico;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comandaNome),
        actions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareSummary,
              tooltip: 'Compartilhar Resumo')
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Participantes', _showAddParticipantDialog),
          _participantes.isEmpty
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum participante adicionado.')))
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _participantes.map((p) => Chip(
                        label: Text(p['nome']),
                        onDeleted: () {
                          _showDeleteParticipantConfirmationDialog(p);
                        },
                      )).toList(),
                ),
          const Divider(height: 30, thickness: 1),
          _buildSectionHeader('Itens Consumidos', _showAddItemDialog),
          if (_itens.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Nenhum item adicionado.'))),
          ..._itens.map((item) {
            final links = _itemLinks[item['id']] ?? [];
            final nomes = links.map((link) {
              final participante = _participantes.firstWhere(
                  (p) => p['id'] == link['id_participante'],
                  orElse: () => {});
              if (participante.isEmpty) return '';
              final quantidade = link['quantidade'];
              return '${participante['nome']}${quantidade > 1 ? ' ($quantidade)' : ''}';
            }).join(', ');

            return Card(
              child: ListTile(
                title: Text(item['descricao']),
                subtitle: Text(
                  nomes.isEmpty ? 'Toque para dividir' : 'Com: $nomes',
                  style:
                      TextStyle(color: nomes.isEmpty ? AppColors.error : null),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('R\$ ${item['valor_total'].toStringAsFixed(2)}'),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: 'Remover item',
                      onPressed: () {
                        _showDeleteItemConfirmationDialog(item);
                      },
                    )
                  ],
                ),
                onTap: () => _showAssignItemDialog(item),
              ),
            );
          }),
          const Divider(height: 30, thickness: 1),
          Card(
            color: AppColors.surface,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Incluir Taxa de Serviço?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: _incluirServico,
                    onChanged: (bool value) {
                      setState(() {
                        _incluirServico = value;
                      });
                    },
                  ),
                  if (_incluirServico)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
                      child: TextField(
                        controller: _servicoController,
                        decoration: const InputDecoration(
                          labelText: 'Percentual do Serviço',
                          suffixIcon: Icon(Icons.percent, size: 20),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {
                          setState(() {
                            _percentualServico = double.tryParse(
                                    value.replaceAll(',', '.')) ??
                                0.0;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Resumo Final',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'R\$ ${totalGeral.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_participantes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text('Adicione participantes e itens para ver o resumo.'),
            )
          else
            ..._participantes.map((participante) {
              final subtotal = totals[participante['id']] ?? 0.0;
              final servico = _incluirServico
                  ? subtotal * (_percentualServico / 100.0)
                  : 0.0;
              final total = subtotal + servico;
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participante['nome'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary),
                      ),
                      const Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Consumo:'),
                            Text('R\$ ${subtotal.toStringAsFixed(2)}')
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_incluirServico
                                ? 'Serviço (${_percentualServico.toStringAsFixed(0)}%):'
                                : 'Serviço:'),
                            Text('R\$ ${servico.toStringAsFixed(2)}')
                          ]),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total a pagar:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text(
                              'R\$ ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.success),
                            ),
                          ]),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.accent),
          onPressed: onAdd,
          iconSize: 30,
        ),
      ],
    );
  }
}