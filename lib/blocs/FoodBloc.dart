import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../models/model_food.dart';
import '../models/model_lot.dart';
import '../database.dart';
import '../Events.dart';

import '../ext/OpenFoodLogic.dart';

class FoodBloc implements BlocBase {
  Food _food;
  List<Lot> _listLot;
  int idFood;
  int idMeal;
  int _idFood;
  int _idMeal;

  String _barCode = "";

  final _foodController = StreamController<Food>();
  StreamSink<Food> get _inFood => _foodController.sink;
  Stream<Food> get outFood => _foodController.stream;

  final _actionFoodController = BehaviorSubject<FoodEvent>();

  StreamSink get manageFood => _actionFoodController.sink;

  String get barCode => _barCode;


  FoodBloc({this.idFood, this.idMeal}) {
    _actionFoodController.stream.listen(_handleLogic);

    if (idFood != null) {
      _idFood = idFood;
      _getFood();
      _getLots();
    } else if (idMeal != null){
      _idMeal = idMeal;
    }

    _notify();
  }

  void _getFood() async {
    _food = await DBProvider.db.getFood(_idFood);
    _notify();
  }

  void _getLots() async {
    _listLot = await DBProvider.db.getLots(_idFood);
    print(_listLot);
    _food.listLots = _listLot;
    _notify();
  }

  void _handleLogic(FoodEvent event) async {
    if (event is AddFoodEvent) {
      print("insert food");
      await DBProvider.db.insertFood(event.food);
      
      for (Lot lot in event.food.listLots) {
        print("insert lot ${lot.numLot}");
        lot.idFood = event.food.idFood;
        await DBProvider.db.insertLot(lot);
      }
      
    } else if (event is UpdateFoodEvent) {
      print("edit food");
      await DBProvider.db.updateFood(event.food);
    } else if (event is UpdateFoodLotEvent) {
      for (Lot lot in event.toDelete) {
        await DBProvider.db.deleteLot(lot);
      }
      for (Lot lot in event.toInsert) {
        await DBProvider.db.insertLot(lot);
      }
    } else if (event is SearchFoodInAPI) {
      _barCode = event.barcode;
      Product p = await OpenFoodLogic.ofl.getProduct(event.barcode);
      if (p != null) {
        createFoodFromAPI(p);
      }
    }
     _notify();
  }

  void createFoodFromAPI(Product p) {
    String name = p.productName;
    String brand = p.brands;
    String imgUrl = p.imgSmallUrl;
    Food f = new Food(nameFood: name, brandsName: brand, imgUrl: imgUrl);
    print("${f.nameFood} - ${f.brandsName} - ${f.imgUrl}");
    _food = f;
  }

  void _notify() {
    _inFood.add(_food);
  }

  void dispose(){
    _foodController.close();
    _actionFoodController.close();
  }
}