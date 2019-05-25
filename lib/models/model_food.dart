// To parse this JSON data, do
//
//     final meal = mealFromJson(jsonString);

import 'dart:convert';
import 'model_lot.dart';

Food mealFromJson(String str) {
    final jsonData = json.decode(str);
    return Food.fromJson(jsonData);
}

String mealToJson(Food data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Food {
    int idFood;
    int idMeal;
    String nameFood;
    String brandsName;
    String imgUrl;
    double price;
    int quantity;
    List<Lot> listLots;

    Food({
        this.idFood,
        this.idMeal,
        this.nameFood,
        this.brandsName,
        this.imgUrl,
        this.price,
        this.quantity,
        this.listLots,
    });

    String toString() {
      return "idFood: " + idFood.toString() + "\nidMeal: " + idMeal.toString() + "\nname: " + nameFood 
      + "\nbrands: " + brandsName + "\nimgUrl: " + imgUrl + "\nprice: " 
      + price.toString() + "\nquantity: " + quantity.toString() + "\nlots: " + listLots.toString(); 
    }

    factory Food.fromJson(Map<String, dynamic> json) => new Food(
        idFood: json["id_food"],
        idMeal: json["id_meal"],
        nameFood: json["name_food"],
        brandsName: json["brands_name"],
        imgUrl: json["img_url"],
        price: json["price"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "id_food": idFood,
        "id_meal": idMeal,
        "name_food": nameFood,
        "brands_name":brandsName,
        "img_url":imgUrl,
        "price": price,
        "quantity": quantity,
    };
}
