import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/models/model_visit.dart';
import 'package:BonaBona/database/database.dart';
import 'events.dart';

class VisitListBloc implements BlocBase {
  List<Visit> _visitList;
  int _idVisitToDelete;
  Timer _timer;

  final _visitListController = BehaviorSubject<List<Visit>>();
  final _actionVisitListController = StreamController<VisitListEvent>();

  StreamSink<List<Visit>> get _inList => _visitListController.sink;
  Stream<List<Visit>> get outList => _visitListController.stream;

  StreamSink get manageVisitList => _actionVisitListController.sink;

  VisitListBloc() {
    _actionVisitListController.stream.listen(_handleVisitListLogic);
    _getVisitList();
  }

  void _handleVisitListLogic(VisitListEvent event) async {
    if (event is RemoveVisitEvent) {
      if (_idVisitToDelete != null) {
        _timer?.cancel();
        await DBProvider.db.deleteVisit(_idVisitToDelete);
      }
      _idVisitToDelete = event.idVisit;
      _timer = new Timer(const Duration(seconds: 5), () async {
        await DBProvider.db.deleteVisit(event.idVisit);
        _idVisitToDelete = null;
      });
    } else if (event is CancelRemoveVisitEvent) {
      _timer?.cancel();
      _idVisitToDelete = null;
    }
    if (event is UpdateVisitListEvent) {}

    _getVisitList();
  }

  void _getVisitList() async {
    _visitList = await DBProvider.db.getAllVisits();
    print(_idVisitToDelete);
    _visitList.removeWhere((v) => v.idVisit == _idVisitToDelete);
    _notifyVisitList();
  }

  void _notifyVisitList() async {
    _inList.add(_visitList);
  }

  void dispose() async {
    if (_visitListController != null) {
      _timer?.cancel();
      await DBProvider.db.deleteVisit(_idVisitToDelete);
      _idVisitToDelete = null;
    }
    _visitListController.close();
    _actionVisitListController.close();
  }
}
