import 'models/model.dart';
import 'models/model_food.dart';



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

class DisplayDofEvent extends DofEvent {
  int idVisit;
  DisplayDofEvent({this.idVisit});
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

class UpdateMealListEvent extends MealEvent {}

class UpdateFoodEvent extends FoodEvent {
  int idFood;
  UpdateFoodEvent(idFood);
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