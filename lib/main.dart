import 'dart:async';

import 'package:BonaBona/pages/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:BonaBona/models/model_visit.dart';

import 'package:BonaBona/blocs/bloc_dof.dart';
import 'package:BonaBona/blocs/bloc_visit.dart';
import 'package:BonaBona/blocs/bloc_visit_list.dart';

import 'package:BonaBona/blocs/events.dart';

import 'package:BonaBona/pages/screen_dof.dart';
import 'package:BonaBona/pages/screen_manage_visit.dart';

void main() => runApp(MaterialApp(
        home: BlocProvider<VisitListBloc>(
      bloc: VisitListBloc(),
      child: MyHomePage(),
    )));

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VisitListBloc bloc;
  List<Visit> _visitList;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<VisitListBloc>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("BonaBona"),
      ),
      body: Center(
        child: StreamBuilder<List<Visit>>(
            stream: bloc.outList,
            builder:
                (BuildContext context, AsyncSnapshot<List<Visit>> snapshot) {
              if (snapshot.hasData && snapshot.data.isNotEmpty) {
                _visitList = snapshot.data;
                return ListView.builder(
                  itemCount: _visitList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Visit v = _visitList[index];
                    return Slidable(
                      delegate: new SlidableDrawerDelegate(),
                      key: UniqueKey(),
                      actionExtentRatio: 0.25,
                      // slideToDismissDelegate: new SlideToDismissDrawerDelegate(
                      //     onWillDismiss: (actionType) {
                      //       return _showDeleteDialog(v);
                      //     },
                      //     dismissThresholds: <SlideActionType, double>{
                      //       SlideActionType.primary: 1.0
                      //     }),
                      child: Container(
                        child: ListTile(
                          leading: Icon(Icons.terrain),
                          title: Text("${v.nameVisit}"),
                          subtitle: Text("${v.startDate} - ${v.endDate}"),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BlocProvider<DofVisitBloc>(
                                  bloc: DofVisitBloc(v.idVisit),
                                  child: DayOfVisitScreen());
                            }));
                          },
                        ),
                      ),
                      actions: <Widget>[
                        new IconSlideAction(
                          caption: 'Edit',
                          color: Colors.blue,
                          icon: Icons.edit,
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BlocProvider<VisitBloc>(
                                  bloc: VisitBloc(visit: v),
                                  child: ManageVisitScreen());
                            })).then((_) {
                              setState(() {
                                bloc.manageVisitList
                                    .add(UpdateVisitListEvent());
                              });
                            });
                          },
                        ),
                      ],
                      secondaryActions: <Widget>[
                        new IconSlideAction(
                          caption: 'Remove',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            showDeleteDialog(bloc, v, context);
                          },
                        )
                      ],
                    );
                  },
                );
              } else {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Aucun séjour pour le moment."),
                    SizedBox(height: 20),
                    Text(
                        "Pour en ajouter un, cliquer sur le bouton en bas à droite."),
                  ],
                ));
              }
            }),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BlocProvider<VisitBloc>(
                bloc: VisitBloc(), child: ManageVisitScreen());
          })).then((_) {
            setState(() {
              bloc.manageVisitList.add(UpdateVisitListEvent());
            });
          });
        },
      ),
    );
  }
}
