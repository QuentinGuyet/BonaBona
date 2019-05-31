import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/models/model_visit.dart';
import 'package:BonaBona/database/database.dart';
import 'events.dart';

class VisitBloc implements BlocBase {
  Visit visit;

  final _visitController = BehaviorSubject<Visit>();
  final _actionVisitController = StreamController<VisitEvent>();

  StreamSink<Visit> get _inVisit => _visitController.sink;
  Stream<Visit> get outVisit => _visitController.stream;

  StreamSink get manageVisit => _actionVisitController.sink;

  VisitBloc({this.visit}) {
    _actionVisitController.stream.listen(_handleVisitLogic);
    _notifyVisit();
  }

  void _handleVisitLogic(VisitEvent event) async {
    visit = event.visit;
    if (event is UpdateVisitEvent) {
      await DBProvider.db.updateVisit(visit);
    } else if (event is AddVisitEvent) {
      await DBProvider.db.insertVisit(visit);
    }
    _notifyVisit();
  }

  void _notifyVisit() {
    _inVisit.add(visit);
  }

  void dispose() {
    _visitController.close();
    _actionVisitController.close();
  }
}
