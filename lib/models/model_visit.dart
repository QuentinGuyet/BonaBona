import 'dart:convert';

Visit visitFromJson(String str) {
    final jsonData = json.decode(str);
    return Visit.fromJson(jsonData);
}

String visitToJson(Visit data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Visit {
    int idVisit;
    String nameVisit;
    String startDate;
    String endDate;
    int nbDays;

    Visit({
        this.idVisit,
        this.nameVisit,
        this.startDate,
        this.endDate,
        this.nbDays,
    });

    factory Visit.fromJson(Map<String, dynamic> json) => new Visit(
        idVisit: json["id_visit"],
        nameVisit: json["name_visit"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        nbDays: json["nb_days"],
    );

    Map<String, dynamic> toJson() => {
        "id_visit": idVisit,
        "name_visit": nameVisit,
        "start_date": startDate,
        "end_date": endDate,
        "nb_days": nbDays,
    };

    @override
  String toString() {
    return "id: $idVisit, name: $nameVisit, startDate: $startDate, endDate: $endDate, nbDays: $nbDays";
  }
}
