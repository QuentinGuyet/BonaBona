class Lot {
    int idFood;
    String numLot;

    Lot({
        this.idFood,
        this.numLot,
    });

    factory Lot.fromJson(Map<String, dynamic> json) => new Lot(
        idFood: json["id_food"],
        numLot: json["num_lot"],
    );

    Map<String, dynamic> toJson() => {
        "id_food": idFood,
        "num_lot": numLot,
    };
}
