import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import '../models/model_dayofvisit.dart';
import '../database.dart';

class DofVisitBloc implements BlocBase {
  List<DayOfVisit> _dofList = [];
  int _idVisit;

  final _dofListController = BehaviorSubject<List<DayOfVisit>>();
  StreamSink<List<DayOfVisit>> get _inList => _dofListController.sink;
  Stream<List<DayOfVisit>> get outList => _dofListController.stream;

  DofVisitBloc(int idVisit) {
    _idVisit = idVisit;
    _getList();
  }

  void _getList() async {
    _dofList = await DBProvider.db.getAllDaysOfVisit(_idVisit);
    _notify();
  }

  void _notify() {
    _inList.add(_dofList);
  }

  @override
  void dispose() {
    _dofListController.close();
  }
}
