import 'dart:convert';
import 'dart:ffi';

Patient welcomeFromJson(String str) => Patient.fromJson(json.decode(str));

String loginModelToJson(Patient data) => json.encode(data.toJson());

class Patient {
  int id;
  String name;
  String email;
  String phone;
  String imageUrl;
  String patient_location;
  String patient_history;
  Bool insured;
  int patient_id;
  int age;
  int user_id;
  List parent_id;
  String date_of_birth;
  String dependants;
  String insurance_company;
  String qr_code;

  Patient(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.imageUrl,
      this.patient_location,
      this.patient_history,
      this.insured,
      this.patient_id,
      this.age,
      this.user_id,
      this.parent_id,
      this.date_of_birth,
      this.dependants,
      this.insurance_company,
      this.qr_code});

  static List encodeToJson(List<Patient> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toJson())).toList();

    // using toSet - toList strategy
    final uniqueJsonList = jsonList.toSet().toList();

    // convert each item back to the original form using JSON decoding
    final result = uniqueJsonList.map((item) => jsonDecode(item)).toList();

    return result;
    // print(result);

    // var seen = Set<String>();
    // List<String> uniquelist =
    //     jsonList.where((patient) => seen.add(patient)).toList();
    // print(uniquelist);
  }

  // convert each item to a string by using JSON encoding
  // final jsonList = List.map((item) => jsonEncode(item)).toList();

  // // using toSet - toList strategy
  // final uniqueJsonList = jsonList.toSet().toList();

  // // convert each item back to the original form using JSON decoding
  // final result = uniqueJsonList.map((item) => jsonDecode(item)).toList();

  // print(result);

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
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
      "phone": this.phone,
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
