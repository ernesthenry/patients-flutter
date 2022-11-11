import 'dart:convert';

Partner welcomeFromJson(String str) => Partner.fromJson(json.decode(str));

String loginModelToJson(Partner data) => json.encode(data.toJson());

class Partner {
  int id;
  String name;
  String imageUrl;
  String email;
  String phone;
  String address;
  String account_name;
  int qb_cust;
  int user_id;
  List parent_id;
  String subCounty;
  String district;
  String parish;
  String region;

  Partner(
      {this.id,
      this.name,
      this.imageUrl,
      this.email,
      this.phone,
      this.address,
      this.account_name,
      this.district,
      this.parish,
      this.region,
      this.subCounty,
      this.qb_cust,
      this.parent_id,
      this.user_id});

  static List encodeToJson(List<Partner> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        id: json["id"],
        name: json["name"],
        imageUrl: json["imageUrl"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        account_name: json["account_name"],
        district: json["district"],
        parish: json["parish"],
        region: json["region"],
        subCounty: json["subCounty"],
        // ninexpirydate: DateTime.parse(json["ninexpirydate"]),
        qb_cust: json["qb_cust"],
        user_id: json["user_id"],
      );

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "imageUrl": this.imageUrl,
      "email": this.email,
      "phone": this.phone,
      "address": this.address,
      "account_name": this.account_name,
      "district": this.district,
      "parish": this.parish,
      "region": this.region,
      "subCounty": this.subCounty,
      "qb_cust": this.qb_cust,
      "user_id": this.user_id,
    };
  }
}
