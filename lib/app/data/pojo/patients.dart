import 'dart:convert';
import 'dart:ffi';

Patient welcomeFromJson(String str) => Patient.fromJson(json.decode(str));

String loginModelToJson(Patient data) => json.encode(data.toJson());

class Patient {
  int id;
  String name;
  String email;
  String imageUrl;
  String patient_location;
  Bool insured;
  int patient_id;
  int age;
  int user_id;
  List parent_id;
  String patient_history;
  String date_of_birth;
  String dependants;
  String insurance_company;
  String qr_code;

  Patient(
      {this.id,
      this.name,
      this.email,
      this.imageUrl,
      this.patient_location,
      this.insured,
      this.patient_id,
      this.age,
      this.user_id,
      this.parent_id,
      this.patient_history,
      this.date_of_birth,
      this.dependants,
      this.insurance_company,
      this.qr_code});

  static List encodeToJson(List<Patient> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      imageUrl: json["imageUrl"],
      patient_location: json["patient_location"],
      insured: json["insured"],
      patient_history: json["patient_history"],
      patient_id: json["patient_id"],
      age: json["age"],
      user_id: json["user_id"],
      date_of_birth: json["date_of_birth"],
      parent_id: json["parent_id"],
      dependants: json["dependants"],
      insurance_company: json["insurance_company"],
      qr_code: json["qr_code"]);

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "email": this.email,
      "imageUrl": this.imageUrl,
      "patient_location": this.patient_location,
      "insured": this.insured,
      "patient_history": this.patient_history,
      "patient_id": this.patient_id,
      "age": this.age,
      "user_id": this.user_id,
      "date_of_birth": this.date_of_birth,
      "parent_id": this.parent_id,
      "dependants": this.dependants,
      "insurance_company": this.insurance_company,
      "qr_code": this.qr_code
    };
  }
}
