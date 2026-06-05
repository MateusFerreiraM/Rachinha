// lib/helpers/database_helper.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final _supabase = Supabase.instance.client;

  // ==== Bares ====

  Future<int> insertBar(Map<String, dynamic> row) async {
    final response = await _supabase.from('bares').insert(row).select('id').single();
    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAllBares() async {
    final response = await _supabase.from('bares').select().order('id', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> updateBar(Map<String, dynamic> row) async {
    int id = row['id'];
    // Remove o ID do map de atualização para não tentar alterar a chave primária
    final updateData = Map<String, dynamic>.from(row)..remove('id');
    await _supabase.from('bares').update(updateData).eq('id', id);
    return id;
  }

  Future<int> deleteBar(int id) async {
    await _supabase.from('bares').delete().eq('id', id);
    return id;
  }

  // ==== Comandas ====

  Future<int> insertComanda(Map<String, dynamic> row) async {
    final response = await _supabase.from('comandas').insert(row).select('id').single();
    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getComandasDoBar(int idBar) async {
    // Usando uma query para pegar as comandas do bar específico
    final response = await _supabase
        .from('comandas')
        .select('*, participantes(count)')
        .eq('id_bar', idBar)
        .order('data', ascending: false);
    
    // A query acima retorna a contagem de participantes de forma aninhada. 
    // Vamos mapear para manter compatibilidade com a UI atual (participant_count).
    return response.map((comanda) {
      final map = Map<String, dynamic>.from(comanda);
      final list = map['participantes'] as List<dynamic>? ?? [];
      // No select('participantes(count)'), a resposta costuma vir como list de dicionários ou count.
      // O PostgREST 12+ retorna [{'count': X}].
      int count = 0;
      if (list.isNotEmpty && list.first is Map && list.first.containsKey('count')) {
        count = list.first['count'] as int;
      }
      map['participant_count'] = count;
      return map;
    }).toList();
  }

  Future<int> updateComanda(Map<String, dynamic> row) async {
    int id = row['id'];
    final updateData = Map<String, dynamic>.from(row)..remove('id');
    await _supabase.from('comandas').update(updateData).eq('id', id);
    return id;
  }

  Future<int> deleteComanda(int id) async {
    await _supabase.from('comandas').delete().eq('id', id);
    return id;
  }

  // ==== Participantes ====

  Future<int> insertParticipant(Map<String, dynamic> row) async {
    final response = await _supabase.from('participantes').insert(row).select('id').single();
    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getParticipantsForComanda(int idComanda) async {
    final response = await _supabase
        .from('participantes')
        .select()
        .eq('id_comanda', idComanda)
        .order('nome', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> deleteParticipant(int id) async {
    await _supabase.from('participantes').delete().eq('id', id);
    return id;
  }

  // ==== Itens ====

  Future<int> insertItem(Map<String, dynamic> row) async {
    final response = await _supabase.from('itens').insert(row).select('id').single();
    return response['id'] as int;
  }

  Future<int> updateItem(Map<String, dynamic> row) async {
    int id = row['id'];
    final updateData = Map<String, dynamic>.from(row)..remove('id');
    await _supabase.from('itens').update(updateData).eq('id', id);
    return id;
  }

  Future<List<Map<String, dynamic>>> getItemsForComanda(int idComanda) async {
    final response = await _supabase.from('itens').select().eq('id_comanda', idComanda);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> deleteItem(int id) async {
    await _supabase.from('itens').delete().eq('id', id);
    return id;
  }

  // ==== Ligações (Links) ====

  Future<void> linkItemToParticipant(int idItem, int idParticipant, int quantidade) async {
    await _supabase.from('item_participante_link').insert({
      'id_item': idItem,
      'id_participante': idParticipant,
      'quantidade': quantidade,
    });
  }

  Future<void> clearLinksForItem(int idItem) async {
    await _supabase.from('item_participante_link').delete().eq('id_item', idItem);
  }

  Future<List<Map<String, dynamic>>> getLinksForItem(int idItem) async {
    final response = await _supabase.from('item_participante_link').select().eq('id_item', idItem);
    return List<Map<String, dynamic>>.from(response);
  }
}