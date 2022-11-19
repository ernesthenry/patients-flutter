import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:patients/app/data/pojo/patients.dart';
import 'package:patients/app/data/services/odoo_response.dart';
// import 'package:patients/app/pages/addpatient.dart';
// import 'package:patients/app/pages/patient_details.dart';
// import 'package:patients/app/pages/patients.dart';
import 'package:patients/app/utility/constant.dart';
import 'package:patients/app/utility/strings.dart';
import 'package:patients/base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
// import 'profile.dart';
import 'settings.dart';
import 'package:intl/intl.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({Key key}) : super(key: key);

  @override
  State<AddPatient> createState() => _AddPatientState();
}

class _AddPatientState extends Base<AddPatient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  List<String> _locations = ['Kampala', 'Jinja'];
  String _selectedLocation;
  bool insured = false;
  DateTime currentDate = DateTime.now();
  String userfullname = "", email = "";
  var _imageUrl;
  int _userId = 0;
  int age;
  String _firstName = "Home";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  _savePatient(name, email, location, date_of_birth, age) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      _userId = getUID();
      // print("My User ID is " + _userId.toString());
    });
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.create(Strings.res_partner, {
          "name": name.toString(),
          "email": email,
          // "date_of_birth": date_of_birth,
          // "name": "Offline Sync Test",
          // "account_name": "Offline Sync Test",
          "age": age,
          "date_of_birth": date_of_birth,
          "location": location,
          "user_id": _userId,
        }).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                // _registerPending = false;
              });
              print("Patient registered successfully!");
              // showMessage("Success", "Customer registered successfully!");
              // pushAndRemoveUntil(Partners());
            } else {
              setState(() {
                // _registerPending = false;
              });
              print(res.getError());
              // showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Patient'),
        ),
        body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
          child: Column(
            key: _formKey,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 218, 204, 204),
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                          child: TextFormField(
                              decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Patient Name',
                          ))))),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 218, 204, 204),
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                          child: TextFormField(
                              decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Email',
                          ))))),
              Container(
                height: 60,
                width: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 218, 204, 204),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      8.0), //here include this to get padding
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(),
                    hint: Text('Choose  Location'),
                    alignment: Alignment.bottomCenter,
                    elevation: 0,
                    borderRadius: BorderRadius.circular(5),
                    value: _selectedLocation,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _locations.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  alignment: const Alignment(0, 0),
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 218, 204, 204),
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Date Of Birth',
                            ),
                            readOnly:
                                true, //set it true, so that user will not able to edit text
                            onTap: () {
                              _selectDate(context);
                            })),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  alignment: const Alignment(0, 0),
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 218, 204, 204),
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                            padding:
                                EdgeInsets.only(left: 15, right: 15, top: 5),
                            child: TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Age',
                                )))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _savePatient(userfullname, email, _selectedLocation,
                            currentDate, age);
                        final snackBar = SnackBar(
                          content: const Text('Processing Data...'),
                          backgroundColor: (Colors.green),
                          action: SnackBarAction(
                            label: 'dismiss',
                            onPressed: () {},
                          ),
                        );
                        // Validate returns true if the form is valid, or false
                        // otherwise.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a Snackbar.
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              )
            ],
          ),
        ));
  }
}
