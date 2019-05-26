import 'package:bloc_pattern/bloc_pattern.dart';

import 'bloc_visit.dart';
import 'bloc_visit_list.dart';

class AppVisitBloc extends BlocBase {
  VisitBloc _visitBloc;
  VisitListBloc _visitListBloc;

  AppVisitBloc() {
    _visitBloc = VisitBloc();
    _visitListBloc = VisitListBloc();
  }

  VisitBloc get visitBloc => _visitBloc;
  VisitListBloc get visitListBloc => _visitListBloc;

  @override
  void dispose() {
    _visitBloc.dispose();
    _visitListBloc.dispose();
  }
}
