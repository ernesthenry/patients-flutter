import 'dart:convert';

import 'employeestock.dart';

Employees welcomeFromJson(String str) => Employees.fromJson(json.decode(str));

String loginModelToJson(Employees data) => json.encode(data.toJson());

class Employees {
  int id;
  String name;
  String job_title;
  String work_email;
  String work_phone;
  String company_user_code;
  String mobile_phone;
  List location_id;
  List inventory_report;

  Employees({
    this.id,
    this.name,
    this.job_title,
    this.work_email,
    this.work_phone,
    this.mobile_phone,
    this.company_user_code,
    this.location_id,
    this.inventory_report,
  });

  static List encodeToJson(List<Employees> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  factory Employees.fromJson(Map<String, dynamic> json) => Employees(
        id: json["id"],
        name: json["name"],
        job_title: json["job_title"],
        work_email: json["work_email"],
        work_phone: json["work_phone"],
        mobile_phone: json["mobile_phone"],
        company_user_code: json["company_user_code"],
        location_id: json["location_id"],
      );

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "job_title": this.job_title,
      "work_email": this.work_email,
      "work_phone": this.work_phone,
      "mobile_phone": this.mobile_phone,
      "company_user_code": this.company_user_code,
      "location_id": this.location_id
    };
  }
}
