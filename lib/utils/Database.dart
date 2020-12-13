import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/Image.dart';
import '../models/levelModel.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      print('DB NOT CREATED YET');
      return _database;
    }
    _database = await initDB();
    print('DB CREATED');

    return _database;
  }

  initDB() async {
    Directory dataDir = await getApplicationDocumentsDirectory();
    print('created');
    String dbPath = join(dataDir.path, 'be_healthy.db');
    print('db location : '+dbPath);
    return await openDatabase(
      join(await getDatabasesPath(), 'be_healthy.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE Image ("
            "id integer primary key, level_id integer,"
            "path TEXT,"
            "FOREIGN KEY (level_id) REFERENCES Level (id) ON DELETE NO ACTION ON UPDATE NO ACTION"
            ")");

        await db.execute("CREATE TABLE Level ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "image TEXT"
            ")");
      },
    );
  }
  createLevel(levelModel level) async {
    print('Levl: ${level.name}');
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO Level (
       name, image
      ) VALUES (?, ?)
    ''', [level.name, level.image]);
    print('DATA level UPLOAD');
    return res;
  }
  createImage(ImageModel image) async {
    print('img: ${image.path}');
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO Image (
       level_id, path
      ) VALUES (?, ?)
    ''', [image.level_id, image.path]);
    print('DATA Image UPLOAD');
    return res;
  }


  Future<List<levelModel>> getLevel() async {
    // Get a reference to the database.
    final Database db = await database;
    print('GET Levels METHOD');

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('Level');

    var list = List.generate(maps.length, (i) {
      return levelModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        image: maps[i]['image'],
      );
    });
    list.forEach((element) {
      print(element.name);
    });
    print('LENGTH: ${list.length}');
    return list;
  }
  Future<List<ImageModel>> getImage() async {
    // Get a reference to the database.
    final Database db = await database;
    print('GET getImage METHOD');

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('Image');

    var list = List.generate(maps.length, (i) {
      return ImageModel(
        id: maps[i]['id'],
        path: maps[i]['path'],
        level_id: maps[i]['level_id'],
      );
    });
    list.forEach((element) {
      print('+++++++++++++++++++++++++++++++++++++');
      print(element.path);
      print(element.level_id);
    });
    print(list);
    print('LENGTH: ${list.length}');
    return list;
  }
}