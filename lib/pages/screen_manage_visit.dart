import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:BonaBona/blocs/bloc_visit.dart';
import 'package:BonaBona/models/model_visit.dart';
import 'package:BonaBona/blocs/events.dart';
import 'custom_widgets.dart';

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

  Visit visit;
  VisitBloc bloc;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<VisitBloc>(context);

    return Scaffold(
        appBar: CustomAppBar(
          title: const Text('Création d\'un séjour'),
        ),
        resizeToAvoidBottomPadding: false,
        body: Center(
          child: _streamBuilderForm(),
        ));
  }

  Widget _streamBuilderForm() {
    return StreamBuilder<Visit>(
        stream: bloc.outVisit,
        builder: (BuildContext context, AsyncSnapshot<Visit> snapshot) {
          if (snapshot.hasData) {
            visit = snapshot.data;
          }
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _paddingTextFormFieldName(),
                _paddingTextFromFieldStartDate(),
                _paddingTextFromFieldEndDate(),
                _paddingRaisedButtonValidForm(context),
              ],
            ),
          );
        });
  }

  Widget _paddingTextFormFieldName() {
    if (visit != null && _nameCtrlr.text.isEmpty) {
      _nameCtrlr.text = visit.nameVisit;
    }
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return "Ce champ ne peut pas être vide.";
          }
          return null;
        },
        controller: _nameCtrlr,
        style: _biggerFont,
        decoration: InputDecoration(labelText: "Nom du séjour"),
      ),
    );
  }

  Widget _paddingTextFromFieldStartDate() {
    bool enabled = true;
    Color color = Colors.black;

    if (visit != null) {
      _sDateCtrlr.text = visit.startDate;
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
              return null;
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

  Widget _paddingTextFromFieldEndDate() {
    bool enabled = true;
    Color color = Colors.black;

    if (visit != null) {
      _eDateCtrlr.text = visit.endDate;
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
              return null;
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

  Widget _paddingRaisedButtonValidForm(BuildContext context) {
    String text = "Créer";
    if (visit != null) {
      text = "Mettre à jour";
    }
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: RaisedButton(
        child: Text(text),
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (_formKey.currentState.validate() && visit == null) {
            visit = new Visit(
                nameVisit: _nameCtrlr.text,
                startDate: _sDateCtrlr.text,
                endDate: _eDateCtrlr.text);
            bloc.manageVisit.add(AddVisitEvent(visit));
            showCustomSnackBar(context, visit, action: SnackBarOperation.create);
          } else if (_formKey.currentState.validate() && visit != null) {
            if (visit.nameVisit != _nameCtrlr.text) {
              visit.nameVisit = _nameCtrlr.text;
              bloc.manageVisit.add(new UpdateVisitEvent(visit));
              showCustomSnackBar(context, visit, action: SnackBarOperation.update);
            } else {
              showCustomSnackBar(context, visit);
            }
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarNothingToUpdate(BuildContext context) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Aucune donnée n'a été mise à jour"),
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
