import '../models/model_visit.dart';
import '../models/model_food.dart';
import '../models/model_lot.dart';
import '../models/model_meal.dart';

abstract class VisitListEvent {}

abstract class VisitEvent {
  Visit visit;
  VisitEvent(this.visit);
}

abstract class DofEvent {}

abstract class MealEvent {}

abstract class FoodEvent {}

abstract class FoodListEvent {}

class RemoveVisitEvent extends VisitListEvent {
  int idVisit;
  RemoveVisitEvent({this.idVisit});
}

class UpdateVisitListEvent extends VisitListEvent {}

class AddVisitListEvent extends VisitListEvent {
  AddVisitListEvent(Visit visit);
}

class AddVisitEvent extends VisitEvent {
  AddVisitEvent(Visit visit) : super(visit);
}

class UpdateVisitEvent extends VisitEvent {
  UpdateVisitEvent(Visit visit) : super(visit);
}

class DisplayVisitEvent extends VisitEvent {
  DisplayVisitEvent(Visit visit) : super(visit);
}

class UpdateDofList extends DofEvent {
  int idVisit;
  UpdateDofList({this.idVisit});
}

class RemoveMealEvent extends MealEvent {
  int idMeal;
  RemoveMealEvent({this.idMeal});
}

class AddEmptyMealEvent extends MealEvent {}

class AddFoodEvent extends FoodEvent {
  Food food;
  AddFoodEvent({this.food});
}

class AddLotToFoodEvent extends FoodEvent {
  Food food;
  Lot lot;
  AddLotToFoodEvent({this.food, this.lot});
}

class RemoveLotFromFoodEvent extends FoodEvent {
  Food food;
  Lot lot;
  RemoveLotFromFoodEvent({this.food, this.lot});
}

class UpdateMealListEvent extends MealEvent {}

class UpdateMealEvent extends MealEvent {
  Meal meal;
  UpdateMealEvent({this.meal});
}
class UpdateFoodEvent extends FoodEvent {
  Food food;
  UpdateFoodEvent({this.food});
}

class UpdateFoodLotEvent extends FoodEvent {
  int idFood;
  List<Lot> newList;
  List<Lot> oldList;
  UpdateFoodLotEvent({this.idFood, this.newList, this.oldList});
}

class RemoveFoodEvent extends FoodListEvent {
  int idFood;
  RemoveFoodEvent({this.idFood});
}

class UpdateFoodListEvent extends FoodListEvent {}

class SearchFoodInAPI extends FoodEvent {
  String barcode;
  SearchFoodInAPI({this.barcode});
}
