import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:BonaBona/blocs/bloc_food_list.dart';
import 'package:BonaBona/blocs/bloc_meal.dart';
import 'package:BonaBona/models/model_meal.dart';
import 'package:BonaBona/pages/screen_food_list.dart';
import 'package:BonaBona/blocs/events.dart';
import 'appbar.dart';

class MealScreen extends StatefulWidget {
  MealScreen({Key key}) : super(key: key);

  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  MealBloc bloc;
  var editIndex;
  var _ctrlEditName = new TextEditingController();

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
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Meal m = snapshot.data[index];
                  if (editIndex != index) {
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
                          onTap: () => _showDeleteDialog(m),
                        )
                      ],
                    );
                  } else {
                    return buildListTileEditNameMeal(m, context);
                  }
                },
              );
            } else {
              return Center(
                child: Text("Aucun repas pour ce jour"),
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

  Future<bool> _showDeleteDialog(Meal m) async {
    return await showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: new Text('Suppression'),
            content: new Text('Voulez-vous supprimer le menu ${m.nameMeal} ?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Oui"),
                onPressed: () {
                  Navigator.of(_context).pop(true);
                  bloc.manageMealList.add(RemoveMealEvent(idMeal: m.idMeal));
                },
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
}
