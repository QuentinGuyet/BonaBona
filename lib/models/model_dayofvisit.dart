import 'dart:convert';

DayOfVisit dayOfVisitFromJson(String str) {
  final jsonData = json.decode(str);
  return DayOfVisit.fromJson(jsonData);
}

String dayOfVisitToJson(DayOfVisit data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class DayOfVisit {
  int idDay;
  int idVisit;
  int numDay;
  String dateDay;
  double totalPrice;

  DayOfVisit({
    this.idDay,
    this.idVisit,
    this.numDay,
    this.dateDay,
    this.totalPrice,
  });

  factory DayOfVisit.fromJson(Map<String, dynamic> json) => new DayOfVisit(
        idDay: json["id_day"],
        idVisit: json["id_visit"],
        numDay: json["num_day"],
        dateDay: json["date_day"],
        totalPrice: json["total_price"],
      );

  Map<String, dynamic> toJson() => {
        "id_day": idDay,
        "id_visit": idVisit,
        "num_day": numDay,
        "date_day": dateDay,
      };
}
