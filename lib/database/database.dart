import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import '../models/model_visit.dart';
import '../models/model_dayofvisit.dart';
import '../models/model_meal.dart';
import '../models/model_food.dart';
import '../models/model_lot.dart';
import 'sql.dart';
import 'package:intl/intl.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "base.db");
    // File f = new File.fromUri(Uri.file(path));
    // f.delete();
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(createVisit);
      await db.execute(createDof);
      await db.execute(createMeal);
      await db.execute(createFood);
      await db.execute(createLot);
      await db.execute(createTriggerOnDeleteFood);
      await db.execute(createTriggerOnInsertFood);
      await db.execute(createTriggerOnUpdateFood);
    }, onConfigure: _onConfigure);
  }

  _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  insertVisit(Visit newVisit) async {
    final db = await database;
    var raw = await db
        .rawQuery("SELECT IFNULL(MAX(id_visit), 0) + 1 as id FROM Visit");
    int id = raw.first["id"];
    newVisit.idVisit = id;
    var res = await db.insert("Visit", newVisit.toJson());
    onInsertVisit(newVisit.startDate, newVisit.endDate, newVisit.idVisit);
    return res;
  }

  onInsertVisit(String startDate, String endDate, int idVisit) {
    List<String> dateSplit = [];
    List<String> days = [];
    String newStartDateStr;
    String newEndDateStr;

    if (startDate.isNotEmpty) {
      dateSplit = startDate.split("/");
      newStartDateStr = dateSplit[2] + '-' + dateSplit[1] + '-' + dateSplit[0];
    }
    DateTime sDate = DateTime.parse(newStartDateStr);

    if (endDate.isNotEmpty) {
      dateSplit = endDate.split("/");
      newEndDateStr = dateSplit[2] + '-' + dateSplit[1] + '-' + dateSplit[0];
    }
    DateTime eDate = DateTime.parse(newEndDateStr);

    int diff = eDate.difference(sDate).inDays + 1;

    days = List<String>.generate(diff, (i) {
      DateTime newDt = new DateTime(sDate.year, sDate.month, sDate.day)
          .add(new Duration(days: i));
      String newDateStr = new DateFormat('dd/MM/yyyy').format(newDt).toString();
      return newDateStr;
    });

    insertDayOfVisit(days, idVisit);
  }

  insertDayOfVisit(List<String> daysList, int idVisit) async {
    final db = await database;
    var raw;
    for (int i = 0; i < daysList.length; i++) {
      raw = await db.rawQuery(
          "SELECT IFNULL(MAX(id_day), 0) + 1 as id_day FROM DayOfVisit");
      int id = raw.first["id_day"];
      final dof = new DayOfVisit(
          idDay: id, idVisit: idVisit, numDay: i + 1, dateDay: daysList[i]);
      await db.insert("DayOfVisit", dof.toJson());
      await insertBaseMeal(id);
    }
  }

  insertBaseMeal(int idDay) async {
    final db = await database;
    var raw = await db
        .rawQuery("SELECT IFNULL(MAX(id_meal), 0) + 1 as id_meal FROM Meal");
    int id = raw.first["id_meal"];
    Meal matin, midi, katreur, diner;
    matin = new Meal(
        idMeal: id++, idDay: idDay, nameMeal: "Petit-déjeuner", totalPrice: 0);
    midi = new Meal(
        idMeal: id++, idDay: idDay, nameMeal: "Déjeuner", totalPrice: 0);
    katreur =
        new Meal(idMeal: id++, idDay: idDay, nameMeal: "Goûter", totalPrice: 0);
    diner =
        new Meal(idMeal: id, idDay: idDay, nameMeal: "Diner", totalPrice: 0);

    await db.insert("Meal", matin.toJson());
    await db.insert("Meal", midi.toJson());
    await db.insert("Meal", katreur.toJson());
    await db.insert("Meal", diner.toJson());
  }

  insertMeal(int idDay) async {
    final db = await database;
    var raw = await db
        .rawQuery("SELECT IFNULL(MAX(id_meal), 0) + 1 as id_meal FROM Meal");
    int id = raw.first["id_meal"];
    raw = await db
        .rawQuery("SELECT count(*) as c FROM Meal WHERE id_day = $idDay");
    int count = raw.first["c"] + 1;
    await db.insert(
        "Meal",
        new Meal(
                idDay: idDay,
                idMeal: id,
                nameMeal: "Menu $count",
                totalPrice: 0)
            .toJson());
  }

  insertFood(Food food) async {
    final db = await database;
    var raw = await db
        .rawQuery("SELECT IFNULL(MAX(id_food), 0) + 1 as id_food FROM Food");
    int id = raw.first["id_food"];
    food.idFood = id;
    await db.insert("Food", food.toJson());
  }

  insertLot(Lot lot) async {
    final db = await database;
    var raw = await db.rawQuery(
        "SELECT 1 FROM Lot WHERE num_lot = '${lot.numLot}' AND id_food = ${lot.idFood}");
    if (raw.isNotEmpty) return;
    await db.insert("Lot", lot.toJson());
  }

  deleteLot(Lot lot) async {
    final db = await database;
    await db.delete("Lot",
        where: "id_food = ? AND num_lot = ?",
        whereArgs: [lot.idFood, lot.numLot]);
  }

  deleteVisit(int idVisit) async {
    final db = await database;
    await db.delete("Visit", where: "id_visit = ?", whereArgs: [idVisit]);
  }

  deleteMeal(int idMeal) async {
    final db = await database;
    await db.delete("Meal", where: "id_meal = ?", whereArgs: [idMeal]);
  }

  deleteFood(int idFood) async {
    final db = await database;
    await db.delete("Food", where: "id_food = ?", whereArgs: [idFood]);
  }

  updateVisit(Visit newVisit) async {
    final db = await database;
    var res = await db.update("Visit", newVisit.toJson(),
        where: "id_visit = ?", whereArgs: [newVisit.idVisit]);
    return res;
  }

  updateFood(Food food) async {
    final db = await database;
    var res = await db.update("Food", food.toJson(),
        where: "id_food = ?", whereArgs: [food.idFood]);
    return res;
  }

  getVisit(int idVisit) async {
    final db = await database;
    var res =
        await db.query("Visit", where: "id_visit = ?", whereArgs: [idVisit]);
    return res.isNotEmpty ? Visit.fromJson(res.first) : null;
  }

  getFood(int idFood) async {
    final db = await database;
    var res = await db.query("Food", where: "id_food = ?", whereArgs: [idFood]);
    return res.isNotEmpty ? Food.fromJson(res.first) : null;
  }

  getLots(int idFood) async {
    final db = await database;
    var res = await db.query("Lot", where: "id_food = ?", whereArgs: [idFood]);
    List<Lot> list =
        res.isNotEmpty ? res.map((c) => Lot.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Visit>> getAllVisits() async {
    final db = await database;
    var res = await db.query("Visit");
    List<Visit> list =
        res.isNotEmpty ? res.map((c) => Visit.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Visit>> getAllDovs() async {
    final db = await database;
    var res = await db.query("DayOfVisit");
    List<Visit> list =
        res.isNotEmpty ? res.map((c) => Visit.fromJson(c)).toList() : [];
    print(list);
    return list;
  }

  Future<List<Visit>> getAllMeals() async {
    final db = await database;
    var res = await db.query("Meal");
    List<Visit> list =
        res.isNotEmpty ? res.map((c) => Visit.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Visit>> getAllFood() async {
    final db = await database;
    var res = await db.query("Food");
    List<Visit> list =
        res.isNotEmpty ? res.map((c) => Visit.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<DayOfVisit>> getAllDaysOfVisit(int idVisit) async {
    final db = await database;
    var res = await db.rawQuery(
        """SELECT d.id_visit, d.id_day, d.date_day, d.num_day, IFNULL(SUM(m.total_price), 0.0) AS total_price
            FROM DayOfVisit AS d
            LEFT JOIN Meal AS m ON d.id_day = m.id_day
            WHERE d.id_visit = $idVisit
            GROUP BY d.id_day;""");

    List<DayOfVisit> list =
        res.isNotEmpty ? res.map((c) => DayOfVisit.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Meal>> getAllMealsOfDay(int idDay) async {
    final db = await database;
    var res = await db.query("Meal", where: "id_day = ?", whereArgs: [idDay]);
    List<Meal> list =
        res.isNotEmpty ? res.map((c) => Meal.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Food>> getAllFoodOfMeal(int idMeal) async {
    final db = await database;
    var res = await db.query("Food", where: "id_meal = ?", whereArgs: [idMeal]);
    List<Food> list =
        res.isNotEmpty ? res.map((c) => Food.fromJson(c)).toList() : [];
    return list;
  }
}
