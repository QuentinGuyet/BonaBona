import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import '../models/model_meal.dart';
import '../database/database.dart';
import 'events.dart';

class MealBloc implements BlocBase {
  List<Meal> _mealList = [];
  int _idDay;

  final _mealListController = StreamController<List<Meal>>();
  StreamSink<List<Meal>> get _inList => _mealListController.sink;
  Stream<List<Meal>> get outList => _mealListController.stream;

  final _actionMealListController = BehaviorSubject<MealEvent>();

  StreamSink get manageMealList => _actionMealListController.sink;

  MealBloc(int idDay) {
    _idDay = idDay;
    _actionMealListController.stream.listen(_handleLogic);
    _getList();
  }

  void _getList() async {
    _mealList = await DBProvider.db.getAllMealsOfDay(_idDay);
    _notify();
  }

  void _handleLogic(MealEvent event) async {
    if (event is AddEmptyMealEvent) {
      await DBProvider.db.insertMeal(_idDay);
    } else if (event is RemoveMealEvent) {
      await DBProvider.db.deleteMeal(event.idMeal);
    } else if (event is UpdateMealListEvent) {}
    _getList();
  }

  void _notify() {
    _inList.add(_mealList);
  }

  void dispose(){
    _mealListController.close();
    _actionMealListController.close();
  }
}