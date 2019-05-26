import 'dart:convert';

Meal mealFromJson(String str) {
    final jsonData = json.decode(str);
    return Meal.fromJson(jsonData);
}

String mealToJson(Meal data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Meal {
    int idMeal;
    int idDay;
    String nameMeal;
    double totalPrice;

    Meal({
        this.idMeal,
        this.idDay,
        this.nameMeal,
        this.totalPrice,
    });

    factory Meal.fromJson(Map<String, dynamic> json) => new Meal(
        idMeal: json["id_meal"],
        idDay: json["id_day"],
        nameMeal: json["name_meal"],
        totalPrice: json["total_price"],
    );

    Map<String, dynamic> toJson() => {
        "id_meal": idMeal,
        "id_day": idDay,
        "name_meal": nameMeal,
        "total_price": totalPrice,
    };
}
