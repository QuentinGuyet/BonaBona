import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'VisitBloc.dart';
import 'VisitListBloc.dart';


class AppVisitBloc extends BlocBase {
  VisitBloc _visitBloc;
  VisitListBloc _visitListBloc;

  AppVisitBloc() {
    _visitBloc = VisitBloc();
    _visitListBloc = VisitListBloc();

    // _visitListBloc.outList.listen(_visitListBloc.inList.add);
  }

  VisitBloc get visitBloc => _visitBloc;
  VisitListBloc get visitListBloc => _visitListBloc;

  @override
  void dispose() {
    _visitBloc.dispose();
    _visitListBloc.dispose();
  }
  
}