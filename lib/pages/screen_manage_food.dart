import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import '../blocs/bloc_food.dart';
import '../models/model_food.dart';
import '../models/model_lot.dart';
import '../blocs/events.dart';

class ManageFoodScreen extends StatefulWidget {
  ManageFoodScreen({Key key}) : super(key: key);

  _ManageFoodScreenState createState() => _ManageFoodScreenState();
}

class _ManageFoodScreenState extends State<ManageFoodScreen> {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ctrlName = new TextEditingController();
  final TextEditingController _ctrlBrand = new TextEditingController();
  final TextEditingController _ctrlImgUrl = new TextEditingController();
  final TextEditingController _ctrlQty = new TextEditingController();
  final TextEditingController _ctrlLot = new TextEditingController();
  final MoneyMaskedTextController _ctrlPrice =
      new MoneyMaskedTextController(decimalSeparator: ",", rightSymbol: "€");
  bool _scannerIsOpen = false;

  List<Lot> _lotsList = [];
  Food food;
  FoodBloc bloc;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<FoodBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout d\'une nouvelle denrée'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _streamBuilderForm(),
      ),
      resizeToAvoidBottomPadding: true,
    );
  }

  Widget _streamBuilderForm() {
    return StreamBuilder<Food>(
      stream: bloc.outFood,
      builder: (context, snapshot) {
        return formAddFood(bloc, snapshot, context);
      },
    );
  }

  Form formAddFood(
      FoodBloc bloc, AsyncSnapshot<Food> snapshot, BuildContext context) {
    if (snapshot.hasData) {
      food = snapshot.data;
      if (food.nameFood != null && _ctrlName.text.isEmpty)
        _ctrlName.text = food.nameFood;
      if (food.brandsName != null && _ctrlBrand.text.isEmpty)
        _ctrlBrand.text = food.brandsName;
      if (food.imgUrl != null && _ctrlImgUrl.text.isEmpty)
        _ctrlImgUrl.text = food.imgUrl;
      if (food.quantity != null && _ctrlQty.text.isEmpty)
        _ctrlQty.text = food.quantity.toString();
      if (food.price != null && _ctrlPrice.text == "0,00€") {
        _ctrlPrice.text = food.price.toStringAsFixed(2);
      }
      if (_lotsList.isEmpty && food.listLots != null) {
        _lotsList.addAll(food.listLots);
      }
    }

    return Form(
      key: _formKey,
      child: Container(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  inkWellPaddingImg(),
                  paddingName(),
                  paddingBrands(),
                  paddingQuantity(),
                  paddingPrice(),
                  paddingsSavedLotLabel(),
                ],
              ),
            ),
            SliverList(
              delegate: _lotsList.isNotEmpty
                  ? SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                      return listLotTile(index, snapshot);
                    }, childCount: _lotsList.length)
                  : SliverChildListDelegate([
                      ListTile(
                        title: Center(
                            child:
                                Text("Aucun lot enregistré pour cette denrée")),
                      ),
                    ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  inputLotName(),
                  paddingButton(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding paddingsSavedLotLabel() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 24.0, bottom: 14.0),
      child: Text(
        "Lots enregistrés :",
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  ListTile listLotTile(int index, AsyncSnapshot<Food> snapshot) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Text(_lotsList[index].numLot.toString()),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _lotsList.removeWhere((l) => l.numLot == _lotsList[index].numLot);
          setState(() {});
        },
      ),
    );
  }

  ListTile inputLotName() {
    return ListTile(
      title: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: TextField(
            enabled: true,
            decoration: InputDecoration(hintText: "Saisir num lot"),
            controller: _ctrlLot,
          )),
      trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            if (_ctrlLot.text.isNotEmpty) {
              Lot l = new Lot(numLot: _ctrlLot.text);
              _lotsList.add(l);
              _ctrlLot.clear();
              setState(() {});
            }
          }),
    );
  }

  InkWell inkWellPaddingImg() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            // decoration: BoxDecoration(border: Border.all()),
            constraints: new BoxConstraints.loose(new Size(800, 150)),
            child: barCodeScanner(),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _scannerIsOpen = !_scannerIsOpen;
        });
        // bloc.manageFood.add(SearchFoodInAPI(barcode: "3268840001008"));
      },
    );
  }

  Padding paddingButton(BuildContext context) {
    String btnText = "Créer";
    if (food != null) {
      btnText = "Mettre à jour";
    }
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: RaisedButton(
          child: Text(btnText),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (_formKey.currentState.validate() && food == null) {
              food = new Food();
              food.idMeal = bloc.idMeal;
              food.nameFood = _ctrlName.text;
              food.brandsName = _ctrlBrand.text;
              food.imgUrl = _ctrlImgUrl.text;
              food.quantity = num.parse(_ctrlQty.text);
              food.price = _ctrlPrice.numberValue;
              food.listLots = _lotsList;
              bloc.manageFood.add(new AddFoodEvent(food: food));
              showSnackBarCreate(context);
            } else if (_formKey.currentState.validate() && food != null) {
              if (updateFood() || updateLotFood()) {
                showSnackBarEdit(context);
              } else {
                showSnackBarNothingToUpdate(context);
              }
            }
            setState(() {});
          },
        ));
  }

  bool updateLotFood() {
    bool _updated = false;
    if (food.listLots != _lotsList) {
      _updated = true;
      bloc.manageFood.add(new UpdateFoodLotEvent(
          idFood: food.idFood, oldList: food.listLots, newList: _lotsList));
    }
    return _updated;
  }

  bool updateFood() {
    bool updated = false;
    if (food.nameFood != _ctrlName.text) {
      food.nameFood = _ctrlName.text;
      updated = true;
    }
    if (food.brandsName != _ctrlBrand.text) {
      food.brandsName = _ctrlBrand.text;
      updated = true;
    }
    if (food.imgUrl != _ctrlImgUrl.text) {
      food.imgUrl = _ctrlImgUrl.text;
      updated = true;
    }
    if (food.quantity != num.parse(_ctrlQty.text)) {
      food.quantity = num.parse(_ctrlQty.text);
      updated = true;
    }
    if (food.price != _ctrlPrice.numberValue) {
      food.price = _ctrlPrice.numberValue;
      updated = true;
    }

    bloc.manageFood.add(new UpdateFoodEvent(food: food));
    return updated;
  }

  Padding paddingUrlImg() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: TextFormField(
        autofocus: false,
        decoration:
            InputDecoration(labelText: "Url", suffixIcon: Icon(Icons.edit)),
        controller: _ctrlImgUrl,
      ),
    );
  }

  Padding paddingBrands() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: TextFormField(
        autofocus: false,
        decoration:
            InputDecoration(labelText: "Marque", suffixIcon: Icon(Icons.edit)),
        controller: _ctrlBrand,
      ),
    );
  }

  Padding paddingPrice() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: TextFormField(
        autofocus: false,
        decoration: InputDecoration(
            labelText: "Prix unitaire", suffixIcon: Icon(Icons.euro_symbol)),
        keyboardType: TextInputType.number,
        controller: _ctrlPrice,
      ),
    );
  }

  Padding paddingQuantity() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: TextFormField(
        autofocus: false,
        validator: (value) {
          if (value.isEmpty) {
            return "Ce champ ne peut pas être vide";
          }
          if (num.parse(value) < 1) {
            return "La quantité ne peut pas être inférieure à 1";
          }
        },
        decoration: InputDecoration(
            labelText: "Quantité", suffixIcon: Icon(Icons.shopping_cart)),
        keyboardType: TextInputType.number,
        inputFormatters: [WhitelistingTextInputFormatter(RegExp('[\\d]+'))],
        controller: _ctrlQty,
      ),
    );
  }

  Padding paddingName() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: TextFormField(
        autofocus: false,
        validator: (value) {
          if (value.isEmpty) {
            return "Ce champ ne peut pas être vide";
          }
        },
        decoration:
            InputDecoration(labelText: "Nom", suffixIcon: Icon(Icons.edit)),
        controller: _ctrlName,
      ),
    );
  }

  barCodeScanner() {
    if (food != null) {
      if (food.imgUrl != null) {
        if (food.imgUrl == "") {
          return Center(
            child: Text("Aucune image disponible"),
          );
        }
        return new Image(image: NetworkImage(food.imgUrl));
      }
    } else if (!_scannerIsOpen) {
      return Center(
        child: Text("Taper pour scanner un code-barres"),
      );
    } else {
      return new QrCamera(qrCodeCallback: (code) {
        bloc.manageFood.add(SearchFoodInAPI(barcode: code));
        setState(() {});
      });
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarCreate(
      BuildContext context) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Création réussie"),
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarEdit(
      BuildContext context) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Mise à jour effectuée avec succès"),
    ));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarNothingToUpdate(BuildContext context) {
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Aucune donnée n'a été mise à jour"),
    ));
  }
}
