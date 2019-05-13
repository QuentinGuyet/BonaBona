// To parse this JSON data, do
//
//     final meal = mealFromJson(jsonString);

import 'dart:convert';

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

    Food({
        this.idFood,
        this.idMeal,
        this.nameFood,
        this.brandsName,
        this.imgUrl,
        this.price,
        this.quantity,
    });

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
