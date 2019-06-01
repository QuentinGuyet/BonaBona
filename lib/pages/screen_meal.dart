import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:BonaBona/blocs/bloc_food_list.dart';
import 'package:BonaBona/blocs/bloc_meal.dart';
import 'package:BonaBona/models/model_meal.dart';
import 'package:BonaBona/pages/screen_food_list.dart';
import 'package:BonaBona/blocs/events.dart';
import 'custom_widgets.dart';

class MealScreen extends StatefulWidget {
  MealScreen({Key key}) : super(key: key);
  static _MealScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_MealScreenState>());

  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  MealBloc bloc;
  var editIndex;
  var _ctrlEditName = new TextEditingController();
  List<Meal> _mealList;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<MealBloc>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Liste des menus"),
      ),
      body: StreamBuilder<List<Meal>>(
          stream: bloc.outList,
          builder: (BuildContext context, AsyncSnapshot<List<Meal>> snapshot) {
            if (snapshot.hasData && snapshot.data.isNotEmpty) {
              _mealList = snapshot.data;
              return ListView.builder(
                itemCount: _mealList.length,
                itemBuilder: (BuildContext context, int index) {
                  Meal meal = _mealList[index];
                  if (editIndex != index) {
                    return buildSlidable(meal, context, index);
                  } else {
                    return buildListTileEditNameMeal(meal, context);
                  }
                },
              );
            } else {
              return Center(
                child: Text("Aucun repas pour ce jour"),
              );
            }
          }),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          bloc.manageMealList.add(AddEmptyMealEvent());
        },
      ),
    );
  }

  Slidable buildSlidable(Meal m, BuildContext context, int index) {
    return Slidable(
      key: UniqueKey(),
      delegate: SlidableDrawerDelegate(),
      child: Container(
        child: buildListTileNameMeal(m, context),
      ),
      actions: <Widget>[
        new IconSlideAction(
          caption: 'Edit name',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            editIndex = index;
            setState(() {});
          },
        )
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Remove',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              showDeleteDialog(bloc, m, context);
            })
      ],
    );
  }

  ListTile buildListTileNameMeal(Meal m, BuildContext context) {
    return ListTile(
      leading: Icon(Icons.restaurant_menu),
      title: Text("${m.nameMeal}"),
      subtitle: Text("Prix total: ${m.totalPrice.toStringAsFixed(2)} €"),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BlocProvider<FoodListBloc>(
              bloc: FoodListBloc(m.idMeal), child: FoodListScreen());
        })).then((_) {
          bloc.manageMealList.add(UpdateMealListEvent());
        });
      },
    );
  }

  ListTile buildListTileEditNameMeal(Meal m, BuildContext context) {
    if (_ctrlEditName.text.isEmpty) _ctrlEditName.text = m.nameMeal;
    return ListTile(
      leading: Icon(Icons.restaurant_menu),
      title: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextField(
          enabled: true,
          controller: _ctrlEditName,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.check),
        onPressed: () {
          m.nameMeal = _ctrlEditName.text;
          bloc.manageMealList.add(UpdateMealEvent(meal: m));
          editIndex = null;
          _ctrlEditName.clear();
          setState(() {});
        },
      ),
    );
  }
}
