import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:BonaBona/blocs/bloc_food.dart';
import 'package:BonaBona/models/model_food.dart';
import 'package:BonaBona/models/model_lot.dart';
import 'package:BonaBona/blocs/events.dart';
import 'custom_widgets.dart';

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

  List<Lot> _listLots;
  Food food;
  FoodBloc bloc;
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<FoodBloc>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Ajout d\'une nouvelle denrée'),
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
        return formAddFood(snapshot, context);
      },
    );
  }

  Form formAddFood(AsyncSnapshot<Food> snapshot, BuildContext context) {
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
      if (food.listLots != null && _listLots == null) {
        _listLots = new List<Lot>();
        _listLots.addAll(food.listLots);
      }
    } else {
      food = new Food();
    }
    if (_listLots == null) {
      _listLots = new List<Lot>();
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
              delegate: buildSliverDelegate(),
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

  buildSliverDelegate() {
    if (_listLots != null && _listLots.isNotEmpty) {
      return SliverChildBuilderDelegate((BuildContext context, int index) {
        return listLotTile(index);
      }, childCount: _listLots.length);
    } else {
      return SliverChildListDelegate([
        ListTile(
          title: Center(
            child: Text("Aucun lot enregistré pour cette denrée"),
          ),
        ),
      ]);
    }
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

  ListTile listLotTile(int index) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Text(_listLots[index].numLot.toString()),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          if (!changed) changed = true;
          _listLots.removeWhere((l) => l.numLot == _listLots[index].numLot);
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
              _listLots.add(l);
              _ctrlLot.clear();
              setState(() {});
            }
          }),
    );
  }

  Padding paddingButton(BuildContext context) {
    String btnText = "Créer";
    if (food.idFood != null) {
      btnText = "Mettre à jour";
    }
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: RaisedButton(
          child: Text(btnText),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (_formKey.currentState.validate() && food.idFood == null) {
              food.idMeal = bloc.idMeal;
              food.nameFood = _ctrlName.text;
              food.brandsName = _ctrlBrand.text;
              food.imgUrl = _ctrlImgUrl.text;
              food.quantity = num.parse(_ctrlQty.text);
              food.price = _ctrlPrice.numberValue;
              food.listLots = new List<Lot>();
              food.listLots.addAll(_listLots);
              bloc.manageFood.add(new AddFoodEvent(food: food));
              showCustomSnackBar(context, food,
                  action: SnackBarOperation.create);
            } else if (_formKey.currentState.validate() &&
                food.idFood != null) {
              if (updateFood() || updateLotFood()) {
                showCustomSnackBar(context, food,
                    action: SnackBarOperation.update);
              } else {
                showCustomSnackBar(context, food,
                    action: SnackBarOperation.none);
              }
            }
            setState(() {});
          },
        ));
  }

  bool updateLotFood() {
    bool _updated = false;
    if (food.listLots != _listLots) {
      _updated = true;
      bloc.manageFood.add(new UpdateFoodLotEvent(
          idFood: food.idFood, oldList: food.listLots, newList: _listLots));
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
          return null;
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
          return null;
        },
        decoration:
            InputDecoration(labelText: "Nom", suffixIcon: Icon(Icons.edit)),
        controller: _ctrlName,
      ),
    );
  }

  InkWell inkWellPaddingImg() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Container(
          child: Center(
              child: Container(
            constraints: new BoxConstraints.loose(new Size(800, 150)),
            child: imageZone(),
          )),
        ),
      ),
      onTap: () {
        if (food.idFood == null) {
          setState(() {
            _scannerIsOpen = !_scannerIsOpen;
          });
        }
      },
    );
  }

  imageZone() {
    if (_scannerIsOpen) {
      return new QrCamera(qrCodeCallback: (code) {
        bloc.manageFood.add(SearchFoodInAPI(barcode: code));
        setState(() {
          _scannerIsOpen = !_scannerIsOpen;
        });
      });
    } else if (!_scannerIsOpen && food.imgUrl != null) {
      if (food.imgUrl.isNotEmpty)
        return imageFromFood();
      else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.broken_image,
                size: 50.0,
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Pas d'image disponible pour ce produit"),
              ),
            ],
          ),
        );
      }
    }
    return StreamBuilder(
      stream: bloc.productState,
      builder: (BuildContext dataStateContext,
          AsyncSnapshot<DataState> dataStateSnapshot) {
        return StreamBuilder(
            stream: bloc.loadingProductState,
            builder: (BuildContext loadingStateContext,
                AsyncSnapshot<LoadingState> loadingStateSnapshot) {
              if (!loadingStateSnapshot.hasData) {
                // Loading
                return Center(
                  child: new CircularProgressIndicator(),
                );
              }
              if (dataStateSnapshot.hasData &&
                  dataStateSnapshot.data == DataState.notFound) {
                // NotFound
                return Center(
                  child: Text("Produit non trouvé"),
                );
              } else {
                //Not started
                return Center(
                  child: Text("Taper pour scanner un code-barres"),
                );
              }
            });
      },
    );
  }

  // inkWellScanner() {
  //   return StreamBuilder(
  //       stream: bloc.searchStarted,
  //       builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
  //         if (snapshot.hasData && snapshot.data) {
  //         } else if (food.idFood != null) {
  // return
  //           ));
  //         } else {}
  //       });
  // }

  Image imageFromFood() {
    return new Image(
      image: NetworkImage(food.imgUrl),
    );
  }
}
