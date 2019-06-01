import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/models/model_meal.dart';
import 'package:BonaBona/database/database.dart';
import 'events.dart';

class MealBloc implements BlocBase {
  List<Meal> _mealList = [];
  int _idDay;
  int _idMealToDelete;
  Timer _timer;

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
    _mealList.removeWhere((m) => m.idMeal == _idMealToDelete);
    _notify();
  }

  void _handleLogic(MealEvent event) async {
    if (event is AddEmptyMealEvent) {
      await DBProvider.db.insertMeal(_idDay);
    } else if (event is RemoveMealEvent) {
      if (_idMealToDelete != null) {
        _timer?.cancel();
        await DBProvider.db.deleteMeal(_idMealToDelete);
      }
      _idMealToDelete = event.idMeal;
      _timer = new Timer(const Duration(seconds: 5), () async {
        await DBProvider.db.deleteMeal(event.idMeal);
      });
    } else if (event is CancelRemoveMealEvent) {
      _timer?.cancel();
      _idMealToDelete = null;
    } else if (event is UpdateMealEvent) {
      await DBProvider.db.updateMeal(event.meal);
    } else if (event is UpdateMealListEvent) {}
    _getList();
  }

  void _notify() {
    _inList.add(_mealList);
  }

  void dispose() async {
    if (_idMealToDelete != null) {
      _timer?.cancel();
      await DBProvider.db.deleteMeal(_idMealToDelete);
      print("delete");
      _idMealToDelete = null;
    }
    _mealListController.close();
    _actionMealListController.close();
  }
}
