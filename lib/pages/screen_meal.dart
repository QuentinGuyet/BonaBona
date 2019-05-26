import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import '../blocs/bloc_food_list.dart';
import '../blocs/bloc_meal.dart';
import '../models/model_meal.dart';
import '../pages/screen_food_list.dart';
import '../blocs/events.dart';

class MealScreen extends StatefulWidget {
  MealScreen({Key key}) : super(key: key);

  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  @override
  Widget build(BuildContext context) {
    final MealBloc bloc = BlocProvider.of<MealBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des menus"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Meal>>(
          stream: bloc.outList,
          builder: (BuildContext context, AsyncSnapshot<List<Meal>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Meal m = snapshot.data[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        bloc.manageMealList
                            .add(RemoveMealEvent(idMeal: m.idMeal));
                      }
                    },
                    child: ListTile(
                      leading: Icon(Icons.restaurant_menu),
                      title: Text("${m.nameMeal}"),
                      subtitle: Text(
                          "Prix total: ${m.totalPrice.toStringAsFixed(2)} €"),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BlocProvider<FoodListBloc>(
                              bloc: FoodListBloc(m.idMeal),
                              child: FoodListScreen());
                        })).then((_) {
                          bloc.manageMealList.add(UpdateMealListEvent());
                        });
                      },
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text("Aucun repas configuré pour ce jour"),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          bloc.manageMealList.add(AddEmptyMealEvent());
        },
      ),
    );
  }
}
