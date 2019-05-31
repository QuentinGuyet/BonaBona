import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/pages/screen_manage_food.dart';
import 'package:BonaBona/blocs/bloc_food_list.dart';
import 'package:BonaBona/blocs/bloc_food.dart';
import 'package:BonaBona/models/model_food.dart';
import 'package:BonaBona/blocs/events.dart';
import 'appbar.dart';

class FoodListScreen extends StatefulWidget {
  FoodListScreen({Key key}) : super(key: key);

  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  @override
  Widget build(BuildContext context) {
    final FoodListBloc bloc = BlocProvider.of<FoodListBloc>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Liste des aliments"),
      ),
      body: StreamBuilder<List<Food>>(
          stream: bloc.outList,
          builder: (BuildContext context, AsyncSnapshot<List<Food>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Food f = snapshot.data[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        bloc.manageMealList
                            .add(RemoveFoodEvent(idFood: f.idFood));
                      }
                    },
                    child: ListTile(
                        leading: Icon(Icons.restaurant_menu),
                        title: Text("${f.nameFood}"),
                        subtitle: Text(
                            "Prix : ${f.price.toStringAsFixed(2)} € - Quantité : ${f.quantity}"),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return BlocProvider<FoodBloc>(
                                bloc: FoodBloc(idFood: f.idFood),
                                child: ManageFoodScreen());
                          })).then((_) {
                            setState(() {
                              bloc.manageMealList.add(UpdateFoodListEvent());
                            });
                          });
                        }),
                  );
                },
              );
            } else {
              return Center(
                child: Text("Aucune denrée enregistrée pour ce jour"),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BlocProvider<FoodBloc>(
                bloc: FoodBloc(idMeal: bloc.idMeal), child: ManageFoodScreen());
          })).then((_) {
            setState(() {
              bloc.manageMealList.add(UpdateFoodListEvent());
            });
          });
        },
      ),
    );
  }
}
