import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/models/model_food.dart';
import 'package:BonaBona/database/database.dart';
import 'events.dart';

class FoodListBloc implements BlocBase {
  List<Food> _foodList = [];
  int _idMeal;
  int _idFoodToDelete;
  Timer _timer;

  final _foodListController = BehaviorSubject<List<Food>>();
  StreamSink<List<Food>> get _inList => _foodListController.sink;
  Stream<List<Food>> get outList => _foodListController.stream;

  int get idMeal => _idMeal;

  final _actionFoodListController = StreamController<FoodListEvent>();

  StreamSink get manageMealList => _actionFoodListController.sink;

  FoodListBloc(int idMeal) {
    _idMeal = idMeal;
    _actionFoodListController.stream.listen(_handleLogic);
    _getList();
  }

  void _getList() async {
    _foodList = await DBProvider.db.getAllFoodOfMeal(_idMeal);
    _foodList.removeWhere((f) => f.idFood == _idFoodToDelete);
    _notify();
  }

  void _handleLogic(FoodListEvent event) async {
    if (event is RemoveFoodEvent) {
      if (_idFoodToDelete != null) {
        _timer?.cancel();
        await DBProvider.db.deleteFood(_idFoodToDelete);
      }
      _idFoodToDelete = event.idFood;
      _timer = new Timer(const Duration(seconds: 5), () async {
        await DBProvider.db.deleteMeal(event.idFood);
        _idFoodToDelete = null;
      });
    } else if (event is CancelRemoveFoodEvent) {
      _timer?.cancel();
      _idFoodToDelete = null;
    } else if (event is UpdateFoodListEvent) {}
    _getList();
  }

  void _notify() {
    _inList.add(_foodList);
  }

  void dispose() {
    _foodListController.close();
    _actionFoodListController.close();
  }
}
