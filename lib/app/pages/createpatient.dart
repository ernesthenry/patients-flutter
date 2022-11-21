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
import 'home.dart';
import 'package:intl/intl.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({Key key}) : super(key: key);

  @override
  State<AddPatient> createState() => _AddPatientState();
}

class _AddPatientState extends Base<AddPatient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController _urlCtrler = new TextEditingController();
  TextEditingController _accountNameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  // TextEditingController _locationController = new TextEditingController();
  // TextEditingController _dateController = new TextEditingController();
  TextEditingController _ageController = new TextEditingController();
  List<Patient> _patients = [];
  List<String> _locations = ['Kampala', 'Jinja'];
  String _selectedLocation;
  bool insured = false;
  DateTime currentDate = DateTime.now();
  String userfullname = "", email = "";
  var _imageUrl;
  int _userId = 0;
  int age;
  String _firstName = "Home";
  String odooURL = "";
  bool _registerPending = false, _accountNameEnabled = true;
  BuildContext dialogContext;

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

  getPatients() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {});
    if (preference.getString("offlinepatients") != null) {
      print(preference.getString("offlinepatients"));
      var patientlist = json.decode(preference.getString("offlinepatients"));
      setState(() {
        for (var i in patientlist) {
          if (i["name"].toString().length > 1) {
            _patients.add(
              new Patient(
                id: i["id"],
                email: i["email"] is! bool ? i["email"] : "N/A",
                name: i["name"].toString(),
                phone: i["phone"] is! bool ? i["phone"] : "N/A",
              ),
            );
          }
        }
      });
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          odoo.searchRead(Strings.res_partner, [
            ['parent_id', "!=", false],
            // ['company_type', "=", 'person']
          ], [
            'email',
            'name',
            'phone',
            'parent_id'
          ]).then(
            (OdooResponse res) {
              if (!res.hasError()) {
                setState(() {
                  hideLoading();
                  String session = getSession();
                  session = session.split(",")[0].split(";")[0];
                  for (var i in res.getRecords()) {
                    if (i["name"].toString().length > 1) {
                      _patients.add(
                        new Patient(
                          id: i["id"],
                          email: i["email"] is! bool ? i["email"] : "N/A",
                          name: i["name"].toString(),
                          phone: i["phone"] is! bool ? i["phone"] : "N/A",
                        ),
                      );
                    }
                  }
                });
                var patientlist = jsonEncode(res.getRecords());
                preference.setString("offlinepatients", patientlist);
                preference.setString(
                    "offlinepatientslastupdated", DateTime.now().toString());
                print("Updated offline patients repository at " +
                    DateTime.now().toString());
              } else {
                print(res.getError());
                showMessage("Warning", res.getErrorMessage());
              }
            },
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getOdooInstance().then((odoo) {
      getPatients();
    });
    setState(() {
      _registerPending = false;
      _accountNameEnabled = true;
      _userId = getUID();
      getPatients();
    });
    print("the user id is " + _userId.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Constants.primaryColor,
            centerTitle: true,
            title: Text("Patients"),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.person_add,
                  color: Colors.white,
                ),
                onPressed: () {
                  push(AddPatient());
                },
              ),
            ]),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Form(
                child: Column(
              key: _formKey,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15),
                    width: _width * 0.89,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 218, 204, 204),
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      controller: _accountNameController,
                      enabled: _accountNameEnabled,
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Constants.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15),
                    width: _width * 0.89,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 218, 204, 204),
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Constants.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15),
                    width: _width * 0.89,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 218, 204, 204),
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Phone Contact",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Constants.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   height: 60,
                //   width: 380,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     color: Color.fromARGB(255, 218, 204, 204),
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.all(
                //         8.0), //here include this to get padding
                //     child: DropdownButton(
                //       isExpanded: true,
                //       underline: Container(),
                //       hint: Text('Choose  Location'),
                //       alignment: Alignment.bottomCenter,
                //       elevation: 0,
                //       borderRadius: BorderRadius.circular(5),
                //       value: _selectedLocation,
                //       icon: const Icon(Icons.keyboard_arrow_down),
                //       items: _locations.map((String items) {
                //         return DropdownMenuItem(
                //           value: items,
                //           child: Text(items),
                //         );
                //       }).toList(),
                //       onChanged: (String newValue) {
                //         setState(() {
                //           _selectedLocation = newValue;
                //         });
                //       },
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: Stack(
                //     alignment: const Alignment(0, 0),
                //     children: <Widget>[
                //       Container(
                //           decoration: BoxDecoration(
                //             color: Color.fromARGB(255, 218, 204, 204),
                //             borderRadius: new BorderRadius.circular(10.0),
                //           ),
                //           child: TextFormField(
                //               obscureText: true,
                //               decoration: InputDecoration(
                //                 border: InputBorder.none,
                //                 labelText: 'Date Of Birth',
                //               ),
                //               readOnly:
                //                   true, //set it true, so that user will not able to edit text
                //               onTap: () {
                //                 _selectDate(context);
                //               })),
                //     ],
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: Stack(
                //     alignment: const Alignment(0, 0),
                //     children: <Widget>[
                //       Container(
                //           decoration: BoxDecoration(
                //             color: Color.fromARGB(255, 218, 204, 204),
                //             borderRadius: new BorderRadius.circular(10.0),
                //           ),
                //           child: Padding(
                //               padding:
                //                   EdgeInsets.only(left: 15, right: 15, top: 5),
                //               child: TextFormField(
                //                   obscureText: true,
                //                   decoration: InputDecoration(
                //                     border: InputBorder.none,
                //                     labelText: 'Age',
                //                   )))),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15),
                    width: _width * 0.89,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 218, 204, 204),
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Age",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.person_add_rounded,
                          color: Constants.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print("+++ phone +++" + _phoneController.text);
                          print("+++ email +++" + _emailController.text);
                          print("+++ name +++" + _accountNameController.text);
                          print("+++ age +++" + _ageController.text);
                          _savePatient(
                            _accountNameController.text,
                            _emailController.text,
                            _phoneController.text,
                            // _selectedLocation,
                            // _ageController.text,
                          );

                          setState(() {
                            _emailController.text = "";
                            _phoneController.text = "";
                            // _selectedLocation = "";
                            _accountNameController.text = "";
                            // _ageController.text = "";
                          });

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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                )
              ],
            ))));
  }

  _savePatient(accountName, email, phone) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: Text("Please wait"),
          content: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new SizedBox(
                width: 10,
              ),
              new Text("Processing ....."),
            ],
          ),
        );
      },
    );
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.create(Strings.res_partner, {
          "name": accountName,
          "user_id": _userId,
          "email": email,
          "phone": phone,
          // "age": age,
          // "location": location,
        }).then(
          (OdooResponse res) async {
            if (!res.hasError()) {
              setState(() {
                _registerPending = false;
              });
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(seconds: 3), () {
                pushAndRemoveUntil(Home());
              });
              showMessage("Success", "Patient registered successfully!");
              // await getPartners();
            } else {
              setState(() {
                _registerPending = false;
              });
              print(res.getError());
              Navigator.pop(dialogContext);
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlinepatientsadded") != null &&
            preference.getString("offlinepatientsadded") != "") {
          print("ADDING SUBSEQUENT OFFLINE PATIENT");
          List _patients = [];
          String patientsString = preference.getString("offlinepatientsadded");
          // print("THE OFFLINE PATIENTS STRING " +
          //     preference.getString("offlinecustomersadded"));
          var patientlist = jsonDecode(patientsString);
          // print(
          //     "THE OFFLINE   PATINTS DECODED OBJECT " + cutomerlist.toString());
          setState(() {
            for (var i in patientlist) {
              _patients.add(
                {
                  "email": i["email"],
                  "name": i["name"],
                  "phone": i["phone"],
                  "age": i["age"],
                  "user_id": i["user_id"],
                },
              );
            }
            _patients.add(
              {
                "name": accountName,
                "age": age,
                "user_id": _userId,
                "email": email,
                "phone": phone,
              },
            );
          });
          var offlinepatientsadded = jsonEncode(_patients);
          // print("THE NEW OFFLINE ADDED CUSTOMERS OBJECT IS " +
          //     offlinecustomersadded);
          preference.setString("offlinepatientsadded", offlinepatientsadded);
          if (preference.getString("offlinepatients") == null ||
              preference.getString("offlinepatients") == "") {
            preference.setString("offlinepatients", offlinepatientsadded);
          } else {
            String patientsString = preference.getString("offlinecustomers");
            // print(preference.getString("offlinecustomers"));
            var patientlist = json.decode(patientsString);
            List _offlinePatients = [];
            setState(() {
              for (var i in patientlist) {
                _offlinePatients.add(
                  {
                    "email": i["email"],
                    "name": i["name"],
                    "phone": i["phone"],
                    "age": i["age"],
                    "user_id": i["user_id"],
                  },
                );
              }
              _offlinePatients.add(
                {
                  "name": accountName,
                  "age": age,
                  "user_id": _userId,
                  "email": email,
                  "phone": phone,
                },
              );
            });
            var offlinepatientsupdate = jsonEncode(_offlinePatients);
            // print("THE NEW OFFLINE PATIENTS OBJECT IS " +
            //     offlinepatientsupdate);
            preference.setString("offlinepatients", offlinepatientsupdate);
          }
          _showSuccessMessage(
              "Patient has been saved to your phone.\nPlease connect to the internet to sync.");
        } else {
          print("ADDING FIRST OFFLINE PATIENT");
          List _patients = [];
          _patients.add(
            {
              "name": accountName,
              "age": age,
              "user_id": _userId,
              "email": email,
              "phone": phone,
            },
          );
          var offlinepatientsadded = jsonEncode(_patients);
          preference.setString("offlinepatientsadded", offlinepatientsadded);
          if (preference.getString("offlinepatients") == null ||
              preference.getString("offlinepatients") == "") {
            preference.setString("offlinepatients", offlinepatientsadded);
          } else {
            String patientsString = preference.getString("offlinepatients");
            print(preference.getString("offlinepatients"));
            var patientlist = json.decode(patientsString);
            List _offlinePatients = [];
            setState(() {
              for (var i in patientlist) {
                _offlinePatients.add(
                  {
                    "email": i["email"],
                    "name": i["name"],
                    "phone": i["phone"],
                    "age": i["age"],
                    "user_id": i["user_id"],
                  },
                );
              }
              _offlinePatients.add(
                {
                  "name": accountName,
                  "age": age,
                  "user_id": _userId,
                  "email": email,
                  "phone": phone,
                },
              );
            });
            var offlinepatientsaddedupdate = jsonEncode(_offlinePatients);
            preference.setString("offlinepatients", offlinepatientsaddedupdate);
          }
          _showSuccessMessage(
              "Patient has been created offline.\nPlease connect to the internet to sync.");
          // Navigator.pop(dialogContext);
        }
      }
    });
  }

  _showSuccessMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Warning: Offline",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                pushReplacement(Home());
                // Navigator.of(context).pop();
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // //SAVE PARTNER TO REMOTE ODOO
  // _savePatient(accountName, email, phone, age) async {
  //   SharedPreferences preference = await SharedPreferences.getInstance();
  //   setState(() {
  //     _userId = getUID();
  //     // print("My User ID is " + _userId.toString());
  //   });
  //   isConnected().then((isInternet) {
  //     if (isInternet) {
  //       showLoading();
  //       odoo.create(Strings.res_partner, {
  //         "name": accountName.toString(),
  //         // "account_name": accountName.toString(),
  //         // "name": "Offline Sync Test",
  //         // "account_name": "Offline Sync Test",
  //         "age": age,
  //         "phone": phone,
  //         "email": email,
  //         "user_id": _userId,
  //       }).then(
  //         (OdooResponse res) {
  //           if (!res.hasError()) {
  //             setState(() {
  //               // _registerPending = false;
  //             });
  //             print("Customer registered successfully!");
  //             // showMessage("Success", "Customer registered successfully!");
  //             // pushAndRemoveUntil(Partners());
  //           } else {
  //             setState(() {
  //               // _registerPending = false;
  //             });
  //             print(res.getError());
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
  //     }
  //   });
  // }
}
