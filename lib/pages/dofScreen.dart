import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import '../models/model_dayofvisit.dart';
import '../pages/mealScreen.dart';
import '../blocs/MealBloc.dart';
import '../blocs/DofBloc.dart';
import '../Events.dart';

class DayOfVisitScreen extends StatelessWidget {
  DayOfVisitScreen({Key key}) : super(key: key);

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
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return BlocProvider<MealBloc>(
                                bloc: MealBloc(dof.idDay), child: MealScreen());
                          }));
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
