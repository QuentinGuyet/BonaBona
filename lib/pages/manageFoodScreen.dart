import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import '../blocs/FoodBloc.dart';
import '../models/model_food.dart';
import '../Events.dart';

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
  final MoneyMaskedTextController _ctrlPrice =
      new MoneyMaskedTextController(decimalSeparator: ",", rightSymbol: "€");
  bool _scannerIsOpen = false;

  @override
  Widget build(BuildContext context) {
    final FoodBloc bloc = BlocProvider.of<FoodBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout d\'une nouvelle denrée'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _streamBuilderForm(bloc),
      ),
      resizeToAvoidBottomPadding: true,
    );
  }

  Widget _streamBuilderForm(FoodBloc bloc) {
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
      var food = snapshot.data;
      if (food.nameFood != null && _ctrlName.text.isEmpty)
        _ctrlName.text = food.nameFood;
      if (food.brandsName != null && _ctrlBrand.text.isEmpty)
        _ctrlBrand.text = food.brandsName;
      if (food.imgUrl != null && _ctrlImgUrl.text.isEmpty)
        _ctrlImgUrl.text = food.imgUrl;
      if (food.quantity != null && _ctrlQty.text.isEmpty)
        _ctrlQty.text = food.quantity.toString();
      if (food.price != null && _ctrlPrice.text == "0,00€") {
        _ctrlPrice.text = food.price.toString();
      }
    }

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              inkWellPaddingImg(snapshot, bloc),
              paddingName(snapshot, bloc),
              paddingBrands(),
              paddingQuantity(),
              paddingPrice(),
              paddingButton(snapshot, context, bloc),
            ],
          ),
        ));
  }

  InkWell inkWellPaddingImg(AsyncSnapshot<Food> snapshot, FoodBloc bloc) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            // decoration: BoxDecoration(border: Border.all()),
            constraints: new BoxConstraints.loose(new Size(800, 150)),
            child: barCodeScanner(snapshot, bloc),
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

  Padding paddingButton(
      AsyncSnapshot<Food> snapshot, BuildContext context, FoodBloc bloc) {
    String btnText = "Créer";
    if (snapshot.hasData) {
      btnText = "Mettre à jour";
    }
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: RaisedButton(
          child: Text(btnText),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (_formKey.currentState.validate() && !snapshot.hasData) {
              var f = new Food(
                  idMeal: bloc.idMeal,
                  nameFood: _ctrlName.text,
                  brandsName: _ctrlBrand.text,
                  imgUrl: _ctrlImgUrl.text,
                  quantity: num.parse(_ctrlQty.text),
                  price: _ctrlPrice.numberValue);
              bloc.manageFood.add(new AddFoodEvent(food: f));
              showSnackBarCreate(context);
            } else if (_formKey.currentState.validate() && snapshot.hasData) {
              var f = new Food(
                  idFood: snapshot.data.idFood,
                  idMeal: snapshot.data.idMeal,
                  nameFood: _ctrlName.text,
                  brandsName: _ctrlBrand.text,
                  imgUrl: _ctrlImgUrl.text,
                  quantity: num.parse(_ctrlQty.text),
                  price: _ctrlPrice.numberValue);
              bloc.manageFood.add(new UpdateFoodEvent(food: f));
              showSnackBarEdit(context);
            }
            setState(() {});
          },
        ));
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
        validator: (value) {
          print(value);
        },
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

  Padding paddingName(AsyncSnapshot<Food> snapshot, FoodBloc bloc) {
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

  barCodeScanner(AsyncSnapshot<Food> snapshot, FoodBloc bloc) {
    if (snapshot.hasData) {
      if (snapshot.data.imgUrl != null) {
        if (snapshot.data.imgUrl == "") {
          return Center(
            child: Text("Aucune image disponible"),
          );
        }
        return new Image(image: NetworkImage(snapshot.data.imgUrl));
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
}
