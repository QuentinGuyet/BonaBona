import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:testdb/blocs/events.dart';

import '../models/model_dayofvisit.dart';
import '../pages/screen_meal.dart';
import '../blocs/bloc_meal.dart';
import '../blocs/bloc_dof.dart';


class DayOfVisitScreen extends StatefulWidget {
  DayOfVisitScreen({Key key}) : super(key: key);

  _DayOfVisitScreenState createState() => _DayOfVisitScreenState();
}

class _DayOfVisitScreenState extends State<DayOfVisitScreen> {
  @override
  Widget build(BuildContext context) {
    final DofVisitBloc bloc = BlocProvider.of<DofVisitBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des jours'),
        backgroundColor: Colors.green,
      ),
      body: Center(
          child: StreamBuilder<List<DayOfVisit>>(
              stream: bloc.outList,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DayOfVisit>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      DayOfVisit dof = snapshot.data[index];
                      return ListTile(
                        title: Text("Jour ${dof.numDay}"),
                        subtitle: Text("${dof.dateDay}"),
                        trailing: Text("${dof.totalPrice.toStringAsFixed(2)}€"),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return BlocProvider<MealBloc>(
                                bloc: MealBloc(dof.idDay), child: MealScreen());
                          })).then((_) {
                            bloc.manageDovList.add(UpdateDofList(idVisit: dof.idVisit));
                            setState(() {});
                          });
                        },
                      );
                    },
                  );
                } else {
                  return Center(
                      child: Text("C'est très bizarre cette histoire"));
                }
              })),
    );
  }
}
