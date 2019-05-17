import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import '../blocs/VisitListBloc.dart';
import '../blocs/VisitBloc.dart';
import '../models/model.dart';
import '../Events.dart';

class ManageVisitScreen extends StatefulWidget {
  ManageVisitScreen({Key key}) : super(key: key);

  _ManageVisitScreenState createState() => _ManageVisitScreenState();
}

class _ManageVisitScreenState extends State<ManageVisitScreen> {
  final TextEditingController _nameCtrlr = TextEditingController();
  final TextEditingController _sDateCtrlr = TextEditingController();
  final TextEditingController _eDateCtrlr = TextEditingController();

  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    final VisitBloc bloc = BlocProvider.of<VisitBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Création d\'un séjour'),
          backgroundColor: Colors.green,
        ),
        resizeToAvoidBottomPadding: false,
        body: Center(
          child: _streamBuilderForm(bloc),
        ));
  }

  Widget _streamBuilderForm(VisitBloc bloc) {
    return StreamBuilder<Visit>(
        stream: bloc.outVisit,
        builder: (BuildContext context, AsyncSnapshot<Visit> snapshot) {
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _paddingTextFormFieldName(snapshot),
                _paddingTextFromFieldStartDate(snapshot),
                _paddingTextFromFieldEndDate(snapshot),
                _paddingRaisedButtonValidForm(context, snapshot, bloc),
              ],
            ),
          );
        });
  }

  Widget _paddingTextFormFieldName(AsyncSnapshot<Visit> snapshot) {
    if (snapshot.hasData && _nameCtrlr.text.isEmpty) {
      _nameCtrlr.text = snapshot.data.nameVisit;
    }
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return "Ce champ ne peut pas être vide.";
          }
        },
        controller: _nameCtrlr,
        style: _biggerFont,
        decoration: InputDecoration(labelText: "Nom du séjour"),
      ),
    );
  }

  Widget _paddingTextFromFieldStartDate(AsyncSnapshot<Visit> snapshot) {
    bool enabled = true;
    Color color = Colors.black;

    if (snapshot.hasData) {
      _sDateCtrlr.text = snapshot.data.startDate;
      enabled = false;
      color = Colors.grey;
    }
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        child: IgnorePointer(
          child: TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return "Ce champ ne peut pas être vide.";
              }
            },
            controller: _sDateCtrlr,
            style: TextStyle(color: color),
            enabled: enabled,
            decoration: InputDecoration(labelText: "Début du séjour"),
          ),
        ),
        onTap: () {
          if (enabled) _showDatePicker(_sDateCtrlr);
        },
      ),
    );
  }

  Widget _paddingTextFromFieldEndDate(AsyncSnapshot<Visit> snapshot) {
    bool enabled = true;
    Color color = Colors.black;

    if (snapshot.hasData) {
      _eDateCtrlr.text = snapshot.data.endDate;
      enabled = false;
      color = Colors.grey;
    }
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        child: IgnorePointer(
          child: TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return "Ce champ ne peut pas être vide.";
              } else if (DateTime.parse(_invertDateStr(_sDateCtrlr.text))
                  .isAfter(DateTime.parse(_invertDateStr(_eDateCtrlr.text)))) {
                return "La fin du séjour est avant la date de début.";
              }
            },
            controller: _eDateCtrlr,
            enabled: enabled,
            style: TextStyle(color: color),
            maxLines: null,
            decoration: InputDecoration(labelText: "Fin du séjour"),
          ),
        ),
        onTap: () {
          if (enabled) _showDatePicker(_eDateCtrlr);
        },
      ),
    );
  }

  Widget _paddingRaisedButtonValidForm(
      BuildContext context, AsyncSnapshot<Visit> snapshot, VisitBloc bloc) {
    String text = "Créer";
    if (snapshot.hasData) {
      text = "Mettre à jour";
    }
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: RaisedButton(
        child: Text(text),
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (_formKey.currentState.validate() && !snapshot.hasData) {
            var v = new Visit(
              nameVisit: _nameCtrlr.text,
              startDate: _sDateCtrlr.text,
              endDate: _eDateCtrlr.text);
            bloc.manageVisit.add(AddVisitEvent(v));
            showSnackBarCreate(context);
          } else if (_formKey.currentState.validate()) {
            var v = snapshot.data;
            v.nameVisit = _nameCtrlr.text;
            bloc.manageVisit.add(new UpdateVisitEvent(v));
            showSnackBarEdit(context);
          }
          setState(() {
            _nameCtrlr.clear();
            _sDateCtrlr.clear();
            _eDateCtrlr.clear();
          });
        },
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarCreate(
      BuildContext context) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Le séjour ${_nameCtrlr.text} a été créé."),
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarEdit(
      BuildContext context) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content:
          Text("Le séjour ${_nameCtrlr.text} a été correctement mis à jour."),
    ));
  }

  void _showDatePicker(TextEditingController txtEditControler) async {
    DateTime selected;
    selected = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2019),
      lastDate: DateTime(2100),
    );
    String strSelected = "";
    if (selected != null)
      strSelected = new DateFormat('dd/MM/yyyy').format(selected).toString();
    txtEditControler.text = strSelected;
  }

  String _invertDateStr(String dateStr) {
    List<String> dateSplit = [];
    String newDateStr;

    if (dateStr.isNotEmpty) {
      dateSplit = dateStr.split("/");
      newDateStr = dateSplit[2] + '-' + dateSplit[1] + '-' + dateSplit[0];
    }

    return newDateStr;
  }
}
