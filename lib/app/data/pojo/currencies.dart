class Currency {
  int id;
  String name;
  String imageUrl;
  String symbol;
  double rate;

  Currency({
    this.id,
    this.name,
    this.symbol,
    this.rate,
  });
}
// class Currency {
//   Result result;

//   Currency({this.result});

//   Currency.fromJson(Map<String, dynamic> json) {
//     result =
//         json['result'] != null ? new Result.fromJson(json['result']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.result != null) {
//       data['result'] = this.result.toJson();
//     }
//     return data;
//   }
// }

// class Result {
//   int id;
//   String name;
//   double rate;
//   String symbol;

//   Result({this.id, this.name, this.rate, this.symbol});

//   Result.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     symbol = json['symbol'];
//     rate = json['rate'] is! bool ? json['rate'] : 0.0;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['symbol'] = this.symbol;
//     data['rate'] = this.rate;
//     return data;
//   }
// }
