import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pretestflutter/model/stock.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'StockData.db';
  static const _databaseVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDiractory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDiractory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Stock.tblStock}(
      ${Stock.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Stock.colNamaBarang} TEXT NOT NULL,
      ${Stock.colQuantity} TEXT NOT NULL,
      ${Stock.colHarga} TEXT NOT NULL,
      ${Stock.colTotalHarga} TEXT NOT NULL
    )
    ''');
  }

  Future<int> insertStock(Stock stock) async {
    Database db = await database;
    return await db.insert(Stock.tblStock, stock.toMap());
  }

  Future<int> updateStock(Stock stock) async {
    Database db = await database;
    return await db.update(Stock.tblStock, stock.toMap(),
        where: '${Stock.colId}=?', whereArgs: [stock.id]);
  }

  Future<int> deleteStock(int id) async {
    Database db = await database;
    return await db
        .delete(Stock.tblStock, where: '${Stock.colId}=?', whereArgs: [id]);
  }

  Future<List<Stock>> fetchStocks() async {
    Database db = await database;
    List<Map> listStock = await db.query(Stock.tblStock);
    return listStock.length == 0
        ? []
        : listStock.map((e) => Stock.fromMap(e)).toList();
  }
}
