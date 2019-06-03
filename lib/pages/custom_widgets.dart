import 'dart:async';

import 'package:BonaBona/blocs/bloc_food_list.dart';
import 'package:BonaBona/blocs/bloc_meal.dart';
import 'package:BonaBona/blocs/bloc_visit_list.dart';
import 'package:BonaBona/blocs/events.dart';
import 'package:BonaBona/models/model_food.dart';
import 'package:BonaBona/models/model_meal.dart';
import 'package:BonaBona/models/model_visit.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({Key key, Widget title})
      : super(key: key, title: title, backgroundColor: Colors.green);
}

class CustomFloatingActionButton extends FloatingActionButton {
  CustomFloatingActionButton({dynamic onPressed})
      : super(
            child: Icon(Icons.add),
            backgroundColor: Colors.green,
            onPressed: onPressed);
}

class CustomSnackBarAction extends SnackBarAction {
  CustomSnackBarAction({Key key, dynamic onPressed})
      : super(key: key, label: "Annuler", onPressed: onPressed);
}

class CustomFlatYesButton extends FlatButton {
  static CustomSnackBarAction csba;

  CustomFlatYesButton(
      {Key key,
      BuildContext currentContext,
      BuildContext parentContext,
      dynamic bloc,
      dynamic object})
      : super(
            key: key,
            child: Text("Oui"),
            onPressed: () {
              Navigator.of(currentContext).pop(true);
              if (bloc is FoodListBloc) {
                bloc.manageMealList.add(RemoveFoodEvent(idFood: object.idFood));
                csba = CustomSnackBarAction(
                  onPressed: () {
                    bloc.manageMealList.add(CancelRemoveFoodEvent());
                  },
                );
              } else if (bloc is VisitListBloc) {
                bloc.manageVisitList
                    .add(RemoveVisitEvent(idVisit: object.idVisit));
                csba = CustomSnackBarAction(
                  onPressed: () {
                    bloc.manageVisitList.add(CancelRemoveVisitEvent());
                  },
                );
              } else if (bloc is MealBloc) {
                bloc.manageMealList.add(RemoveMealEvent(idMeal: object.idMeal));
                csba = CustomSnackBarAction(
                  onPressed: () {
                    bloc.manageMealList.add(CancelRemoveMealEvent());
                  },
                );
              }
              if (Scaffold.of(parentContext).hasAppBar) {
                Scaffold.of(parentContext).removeCurrentSnackBar();
              }
              showCustomSnackBar(parentContext, object,
                  action: SnackBarOperation.delete, customSnackBarAction: csba);
            });
}

enum SnackBarOperation {
  none,
  create,
  update,
  delete,
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showCustomSnackBar(
    BuildContext context, dynamic object,
    {SnackBarOperation action = SnackBarOperation.none,
    CustomSnackBarAction customSnackBarAction}) {
  String prefix;
  String suffix;
  String name;

  if (action == SnackBarOperation.none) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Aucune donnée n'a été mise à jour"),
    ));
  }

  switch (action) {
    case SnackBarOperation.create:
      suffix = " a été créé";
      break;
    case SnackBarOperation.update:
      suffix = " a été mis à jour";
      break;
    case SnackBarOperation.delete:
      suffix = " a été supprimé";
      break;
    default:
      break;
  }

  if (object is Visit) {
    prefix = "Le séjour ";
    name = object.nameVisit;
  } else if (object is Food) {
    prefix = "L'aliment ";
    name = object.nameFood;
  } else if (object is Meal) {
    prefix = "Le menu ";
    name = object.nameMeal;
  }

  return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(prefix + name + suffix),
      duration: Duration(seconds: 5),
      action: customSnackBarAction));
}

Future<bool> showDeleteDialog(
    dynamic bloc, dynamic object, BuildContext parentContext) async {
  String name;
  String type;

  if (object is Meal) {
    name = object.nameMeal;
    type = "le menu";
  } else if (object is Visit) {
    name = object.nameVisit;
    type = "le séjour";
  } else if (object is Food) {
    name = object.nameFood;
    type = "l'aliment";
  }
  return await showDialog(
      context: parentContext,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: new Text('Suppression'),
          content: new Text('Voulez-vous supprimer $type $name ?'),
          actions: <Widget>[
            new CustomFlatYesButton(
              bloc: bloc,
              currentContext: _context,
              parentContext: parentContext,
              object: object,
            ),
            new FlatButton(
              child: new Text("Non"),
              onPressed: () {
                Navigator.of(_context).pop(false);
              },
            )
          ],
        );
      });
}
