// lib/helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bar_split.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE comandas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_bar INTEGER NOT NULL,
        nome_evento TEXT NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (id_bar) REFERENCES bares (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE participantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_comanda INTEGER NOT NULL,
        nome TEXT NOT NULL,
        FOREIGN KEY (id_comanda) REFERENCES comandas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_comanda INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        valor_total REAL NOT NULL, 
        FOREIGN KEY (id_comanda) REFERENCES comandas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE item_participante_link (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_item INTEGER NOT NULL,
        id_participante INTEGER NOT NULL,
        quantidade INTEGER NOT NULL,
        FOREIGN KEY (id_item) REFERENCES itens (id) ON DELETE CASCADE,
        FOREIGN KEY (id_participante) REFERENCES participantes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertBar(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('bares', row);
  }

  Future<List<Map<String, dynamic>>> getAllBares() async {
    Database db = await database;
    return await db.query('bares', orderBy: 'id DESC');
  }

  Future<int> updateBar(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('bares', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBar(int id) async {
    Database db = await database;
    return await db.delete('bares', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertComanda(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('comandas', row);
  }

  Future<List<Map<String, dynamic>>> getComandasDoBar(int idBar) async {
    Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.*, COUNT(p.id) as participant_count
      FROM comandas c
      LEFT JOIN participantes p ON c.id = p.id_comanda
      WHERE c.id_bar = ?
      GROUP BY c.id
      ORDER BY c.data DESC
    ''', [idBar]);
    return result;
  }

  Future<int> updateComanda(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('comandas', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteComanda(int id) async {
    Database db = await database;
    return await db.delete('comandas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertParticipant(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('participantes', row);
  }

  Future<List<Map<String, dynamic>>> getParticipantsForComanda(
      int idComanda) async {
    Database db = await database;
    return await db.query('participantes',
        where: 'id_comanda = ?', whereArgs: [idComanda], orderBy: 'nome');
  }

  Future<int> insertItem(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('itens', row);
  }

  Future<List<Map<String, dynamic>>> getItemsForComanda(int idComanda) async {
    Database db = await database;
    return await db.query('itens',
        where: 'id_comanda = ?', whereArgs: [idComanda]);
  }

  Future<void> linkItemToParticipant(
      int idItem, int idParticipant, int quantidade) async {
    Database db = await database;
    await db.insert('item_participante_link', {
      'id_item': idItem,
      'id_participante': idParticipant,
      'quantidade': quantidade,
    });
  }

  Future<void> clearLinksForItem(int idItem) async {
    Database db = await database;
    await db.delete('item_participante_link',
        where: 'id_item = ?', whereArgs: [idItem]);
  }

  Future<List<Map<String, dynamic>>> getLinksForItem(int idItem) async {
    Database db = await database;
    return await db
        .query('item_participante_link', where: 'id_item = ?', whereArgs: [idItem]);
  }

  // **** NOVOS MÉTODOS ADICIONADOS ****

  /// Deleta um participante da base de dados.
  /// A remoção em cascata (ON DELETE CASCADE) irá remover as ligações com os itens.
  Future<int> deleteParticipant(int id) async {
    Database db = await database;
    return await db.delete('participantes', where: 'id = ?', whereArgs: [id]);
  }

  /// Deleta um item da base de dados.
  /// A remoção em cascata (ON DELETE CASCADE) irá remover as ligações com os participantes.
  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete('itens', where: 'id = ?', whereArgs: [id]);
  }
}