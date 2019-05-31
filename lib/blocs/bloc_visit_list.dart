import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/models/model_visit.dart';
import 'package:BonaBona/database/database.dart';
import 'events.dart';

class VisitListBloc implements BlocBase {
  List<Visit> _visitList;

  final _visitListController = BehaviorSubject<List<Visit>>();
  final _actionVisitListController = StreamController<VisitListEvent>();

  StreamSink<List<Visit>> get _inList => _visitListController.sink;
  Stream<List<Visit>> get outList => _visitListController.stream;

  StreamSink get manageVisitList => _actionVisitListController.sink;

  VisitListBloc() {
    // print("Construct VisitListBloc...");
    _actionVisitListController.stream.listen(_handleVisitListLogic);
    _getVisitList();
  }

  void _handleVisitListLogic(VisitListEvent event) async {
    // print("HandleVisitListLogic : $event");
    if (event is RemoveVisitEvent) {
      await DBProvider.db.deleteVisit(event.idVisit);
    }
    if (event is UpdateVisitListEvent) {}

    _getVisitList();
  }

  void _getVisitList() async {
    // print("Getting list...");
    _visitList = await DBProvider.db.getAllVisits();
    _notifyVisitList();
  }

  void _notifyVisitList() async {
    _inList.add(_visitList);
  }

  void dispose() {
    // print("Disposing VisitListBloc");
    _visitListController.close();
    _actionVisitListController.close();
  }
}
