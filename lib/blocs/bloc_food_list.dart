import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import '../models/model_food.dart';
import '../database/database.dart';
import 'events.dart';

class FoodListBloc implements BlocBase {
  List<Food> _foodList = [];
  int _idMeal;

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
    _notify();
  }

  void _handleLogic(FoodListEvent event) async {
    if (event is RemoveFoodEvent) {
      await DBProvider.db.deleteFood(event.idFood);
    }
    if (event is UpdateFoodListEvent) {}
    _getList();
  }

  void _notify() {
    _inList.add(_foodList);
  }

  void dispose(){
    _foodListController.close();
    _actionFoodListController.close();
  }
}