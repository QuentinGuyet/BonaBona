import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'models/model.dart';

import 'blocs/DofBloc.dart';
import 'blocs/VisitBloc.dart';
import 'blocs/VisitListBloc.dart';

import 'Events.dart';

import 'pages/dofScreen.dart';
import 'pages/manageVisitScreen.dart';

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
  @override
  Widget build(BuildContext context) {
    final VisitListBloc bloc = BlocProvider.of<VisitListBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("BonaBona"),
      ),
      body: Center(
        child: StreamBuilder<List<Visit>>(
            stream: bloc.outList,
            builder:
                (BuildContext context, AsyncSnapshot<List<Visit>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Visit v = snapshot.data[index];
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(color: Colors.red),
                      confirmDismiss: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _showDialog(bloc, v);
                        } else {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return BlocProvider<VisitBloc>(
                                bloc: VisitBloc(visit: v),
                                child: ManageVisitScreen());
                          })).then((_) {
                            setState(() {
                              bloc.manageVisitList.add(UpdateVisitListEvent());
                            });
                          });
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          bloc.manageVisitList
                              .add(RemoveVisitEvent(idVisit: v.idVisit));
                        }
                      },
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
                    );
                  },
                );
              } else {
                return Center(child: Text("Rien à afficher"));
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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

  Future<bool> _showDialog(VisitListBloc bloc, Visit v) async {
    return await showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: new Text('Suppression'),
            content: new Text(
                'Êtes vous sûr de vouloir supprimer le séjour ${v.nameVisit} ?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Oui"),
                onPressed: () {
                  Navigator.of(_context).pop(true);
                  bloc.manageVisitList
                      .add(RemoveVisitEvent(idVisit: v.idVisit));
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
