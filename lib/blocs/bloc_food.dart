import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'package:BonaBona/models/model_food.dart';
import 'package:BonaBona/models/model_lot.dart';
import 'package:BonaBona/database/database.dart';
import 'events.dart';

import 'package:BonaBona/ext/OpenFoodLogic.dart';

class FoodBloc implements BlocBase {
  Food _food;
  List<Lot> _listLot;
  int idFood;
  int idMeal;
  int _idFood;

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
    }

    _notify();
  }

  void _getFood() async {
    _food = await DBProvider.db.getFood(_idFood);
    _notify();
  }

  void _getLots() async {
    _listLot = await DBProvider.db.getLots(_idFood);
    _food.listLots = _listLot;
    _notify();
  }

  void _handleLogic(FoodEvent event) async {
    if (event is AddFoodEvent) {
      await DBProvider.db.insertFood(event.food);
      for (Lot lot in event.food.listLots) {
        lot.idFood = event.food.idFood;
        await DBProvider.db.insertLot(lot);
      }
    } else if (event is UpdateFoodEvent) {
      await DBProvider.db.updateFood(event.food);
    } else if (event is UpdateFoodLotEvent) {
      updateLotFood(event.idFood, event.oldList, event.newList);
    } else if (event is SearchFoodInAPI) {
      _barCode = event.barcode;
      Product p = await OpenFoodLogic.ofl.getProduct(event.barcode);
      if (p != null) {
        createFoodFromAPI(p);
      }
    }
    _notify();
  }

  /*  On sait quels Lots insérer car ils n'ont pas d'idFood et ceux à supprimer 
      en comparant un à un les éléments présents dans l'ancienne list avec ceux
      présent dans la nouvelle. 
      Si le lot n'apparait pas dans la nouvelle, c'est
      qu'il a été supprimé : on le retire donc de la BDD 
  */
  void updateLotFood(int idFood, List<Lot> oldList, List<Lot> newList) async {
    for (Lot lot in newList) {
      if (lot.idFood == null) {
        lot.idFood = idFood;
        await DBProvider.db.insertLot(lot);
      }
    }

    for (Lot oldLot in oldList) {
      bool found = false;
      for (Lot newLot in newList) {
        if (oldLot.numLot == newLot.numLot) {
          found = true;
        }
      }
      if (!found) {
        await DBProvider.db.deleteLot(oldLot);
      }
    }
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

  void dispose() {
    _foodController.close();
    _actionFoodController.close();
  }
}
