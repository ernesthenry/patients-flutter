import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:patients/app/data/pojo/patients.dart';
import 'package:patients/app/data/services/odoo_response.dart';
// import 'package:patients/app/pages/accounts.dart';
// import 'package:patients/app/pages/addpatient.dart';
import 'package:patients/app/pages/createpatient.dart';
// import 'package:patients/app/pages/patient_details.dart';
import 'package:patients/app/pages/patients.dart';
import 'package:patients/app/utility/constant.dart';
import 'package:patients/app/utility/strings.dart';
import 'package:patients/base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
// import 'profile.dart';
import 'settings.dart';
import 'package:intl/intl.dart';

List<Patient> _patients = [];
List<Patient> searchdata = [];

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends Base<Home> {
  //Odoo _odoo;
  String userfullname = "", email = "";
  var _imageUrl;
  int _userId = 0;
  String _firstName = "Home";
  String _result;

  String fullname = "";
  final value = new NumberFormat("#,##0", "en_US");
  String _patientId = "";
  String _displaypatientId = "";
  String _currentMonth = "";
  bool _isDialogShowing = false;

  String returnMonth(DateTime date) {
    return new DateFormat.MMMM().format(date);
  }

  _clearPrefs() async {
    odoo.destroy();
    preferences.remove(Constants.USER_PREF);
    preferences.remove(Constants.SESSION);
    pushAndRemoveUntil(Login());
  }

  _refreshData() async {
    isConnected().then((isInternet) async {
      if (isInternet) {
        _isDialogShowing = true;
        showDialog(
          context: context, // <<----
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Please wait"),
              content: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  new SizedBox(
                    width: 10,
                  ),
                  new Text("Synchronizing data ....."),
                ],
              ),
            );
          },
        );
        getOdooInstance().then((odoo) {
          setState(() {
            _userId = getUID();
            _firstName = getUserFullName();
          });
          print("the user id is " + _userId.toString());
          print("the fullname is " + _firstName.toString());
        });
        await getPatients;
        await new Future.delayed(new Duration(seconds: 6));
        Navigator.of(context).pop();
      }
    });
  }

  // Future<void> _refreshPatients() async {
  //   SharedPreferences preference = await SharedPreferences.getInstance();
  //   isConnected().then((isInternet) {
  //     showMessage("Please Wait", "Refreshing List .....");
  //     // showSnackBar("Refreshing customers list");
  //     if (isInternet) {
  //       showLoading();
  //       odoo.searchRead(Strings.patients_module, [
  //         ['parent_id', "=", false],
  //         ['company_type', "!=", 'person']
  //       ], [
  //         'email',
  //         'name',
  //         'phone',
  //         'parent_id'
  //       ]).then(
  //         (OdooResponse res) {
  //           if (!res.hasError()) {
  //             setState(() {
  //               _patients = [];
  //               hideLoading();
  //               String session = getSession();
  //               session = session.split(",")[0].split(";")[0];
  //               for (var i in res.getRecords()) {
  //                 if (i["name"].toString().length > 1) {
  //                   _patients.add(
  //                     new Patient(
  //                         id: i["id"],
  //                         email: i["email"] is! bool ? i["email"] : "N/A",
  //                         name: i["name"].toString(),
  //                         phone: i["phone"] is! bool ? i["phone"] : "N/A",
  //                         parent_id: i["parent_id"]),
  //                   );
  //                 }
  //               }
  //             });
  //             var patientlist = jsonEncode(res.getRecords());
  //             preference.setString("offlinepatients", patientlist);
  //             preference.setString(
  //                 "offlinepatientslastupdated", DateTime.now().toString());
  //             print("Updated offline patients repository at " +
  //                 DateTime.now().toString());
  //           } else {
  //             print(res.getError());
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
  //     }
  //     Navigator.of(context).pop();
  //   });
  // }

  // _getPatients() async {
  //   SharedPreferences preference = await SharedPreferences.getInstance();
  //   isConnected().then((isInternet) {
  //     if (isInternet) {
  //       showLoading();
  //       odoo.searchRead(Strings.patients_module, [
  //         ['parent_id', "=", false],
  //         ['company_type', "!=", 'person']
  //       ], [
  //         'email',
  //         'name',
  //         'phone',
  //         'parent_id',
  //         // 'company_type'
  //       ]).then(
  //         (OdooResponse res) {
  //           if (!res.hasError()) {
  //             setState(() {
  //               hideLoading();
  //               String session = getSession();
  //               session = session.split(",")[0].split(";")[0];
  //               for (var i in res.getRecords()) {
  //                 if (i["name"].toString().length > 1 &&
  //                     i["parent_id"] is bool) {
  //                   _patients.add(
  //                     new Patient(
  //                       id: i["id"],
  //                       email: i["email"] is! bool ? i["email"] : "N/A",
  //                       name: i["name"].toString(),
  //                       phone: i["phone"] is! bool ? i["phone"] : "N/A",
  //                       parent_id:
  //                           i["parent_id"] is! bool ? i["parent_id"] : [],
  //                       imageUrl: getURL() +
  //                           "/web/image?model=res.partner&field=image&" +
  //                           session +
  //                           "&id=" +
  //                           i["id"].toString(),
  //                     ),
  //                   );
  //                 }
  //               }
  //             });
  //             var patientlist = jsonEncode(res.getRecords());
  //             preference.setString("offlinecustomers", patientlist);
  //             preference.setString(
  //                 "offlinepatientslastupdated", DateTime.now().toString());
  //             print("Updated offline patients repository at " +
  //                 DateTime.now().toString());
  //           } else {
  //             print(res.getError());
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
  //     }
  //   });
  // }

  getPatients() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userfullname = getUserFullName();
      email = getUserEmail();
      print("Email is " + email.toString());
    });
    if (preference.getString("offlinepatients") != null) {
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
          odoo.searchRead(Strings.patients_module, [
            ['parent_id', "=", false],
            ['company_type', "!=", 'person']
          ], [
            'email',
            'name',
            'phone',
            'parent_id',
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
    setState(() {
      _currentMonth = returnMonth(DateTime.now());
    });
    getOdooInstance().then((odoo) {
      setState(() {
        _userId = getUID();
        _firstName = getUserFullName();
      });
      print("the user id is " + _userId.toString());
      print("the fullname is " + _firstName.toString());
    });
    getPatients();
  }

  @override
  Widget build(BuildContext context) {
    final emptyView = Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          height: 150,
          width: 150,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.person_outline,
                  color: Colors.grey.shade300,
                  size: 100,
                ),
                Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Text(
                    "No Patients",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
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
          IconButton(
              onPressed: () async {
                var result = await showSearch<String>(
                  context: context,
                  delegate: CustomDelegate(),
                );
                setState(() => _result = result);
              },
              icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                _refreshData();
                // _refreshPatients();
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ))
        ],
      ),
      drawer: Drawer(
          elevation: 20.0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(userfullname != null ? userfullname : "User"),
                accountEmail: Text(email != null ? email : "email"),
                currentAccountPicture: Image.network(_imageUrl != null
                    ? _imageUrl
                    : "https://image.flaticon.com/icons/png/512/1144/1144760.png"),
                decoration: BoxDecoration(color: Colors.blueAccent),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: () {
                  print("Home Clicked");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Logout"),
                onTap: () {
                  print("Logout Clicked");
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext ctxt) {
                      return AlertDialog(
                        title: Text(
                          "Log Out?",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        content: Text(
                          "Are you sure you want to log out?",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _clearPrefs();
                            },
                            child: Text(
                              "Logout",
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
                },
              ),
            ],
          )),
      body: (_patients.length > 0
          ? Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                reverse: false,
                itemCount: _patients.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, i) => InkWell(
                  onTap: () {
                    push(PatientDetails(data: _patients[i]));
                  },
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Divider(
                          height: 10.0,
                        ),
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Constants.secondaryColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      _patients[i].name ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          subtitle: Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.mail,
                                      color: Constants.secondaryColor,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _patients[i].email ?? "",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15.0),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Constants.secondaryColor,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _patients[i].phone ?? "",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : emptyView),
    );
  }
}

class CustomDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: Icon(Icons.chevron_left), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    var listToShow;
    if (query.isNotEmpty)
      listToShow = _patients
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    // .where((e) => e.contains(query) && e.startsWith(query))
    // .toList();
    else
      listToShow = _patients;

    return ListView.builder(
      itemCount: listToShow.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, i) => InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      PatientDetails(data: listToShow[i])));
        },
        child: Card(
          child: Column(
            children: <Widget>[
              Divider(
                height: 10.0,
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Constants.secondaryColor,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            listToShow[i].name ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                subtitle: Container(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mail,
                            color: Constants.secondaryColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            listToShow[i].email ?? "",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 15.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.phone ?? "",
                            color: Constants.secondaryColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            listToShow[i].phone ?? "",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 15.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReconnectingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SpinKitCubeGrid(
                  color: Colors.blue,
                  size: 50.0,
                )),
            SizedBox(height: 12),
            Text(
              'Initializing app...',
            ),
          ],
        ),
      );
}

class PatientDetails extends StatefulWidget {
  PatientDetails({this.data});

  final data;

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends Base<PatientDetails>
    with SingleTickerProviderStateMixin {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  BuildContext dialogContext;
  String name = "";
  String image_URL = "";
  String email = "";
  String location = "";
  String history = "";
  String qrcode = "";
  String date_of_birth = "";
  var phone = "";
  var mobile = "";
  var street = "";
  var street2 = "";
  var city = "";
  var state_id = "";
  var zip = "";
  var title = "";
  var website = "";
  var jobposition = "";
  var country = "";
  var account_name = "",
      patient_location = "",
      patient_history = "",
      region = "",
      district = "",
      county = "",
      subCounty = "",
      parish = "",
      village_name = "",
      start_time = "",
      time_end = "",
      female_att = 0,
      male_att = 0,
      late_att = 0,
      total_att = 0,
      collection_officer = "",
      post_d2c = false,
      leader_attended = false,
      lc_stayed = false,
      presentation_filter = false,
      additional_d2c = false,
      money_sent = false,
      when_group_meets = false,
      is_this_a_savings_group = false,
      no_of_groups = 0,
      flat = 0.0,
      flat_amount = 0.0,
      commission = 0.0,
      commission_amount = 0.0,
      other_commission = 0.0;
  Patient _patient;
  TabController _controller;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _jobTitleController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  var _selectedIndex = 0;
  // List<Patient> _patients = [];
  List<Patient> _allPatients = [];
  bool _registerPending = false;
  List<Widget> list = [
    Tab(
      text: 'Profile',
    ),
    // Tab(text: 'D2C Details'),
    // Tab(text: 'Commission'),
    // Tab(text: 'Patients'),
  ];

  //UPDATE PATIENTS LIST  AFTER ADDING NEW ONE.
  _updatePatientsList() {
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.patients_module, [
          ['parent_id', "ilike", _patient.name],
          ['company_type', "=", 'person']
        ], [
          'email',
          // 'name',
          // 'phone'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                _patients = [];
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
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  //UPDATE CONTACTS FOR ALL PARTNERS
  _updateUniversalPatients() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.patients_module, [
          ['parent_id', "!=", false],
          ['company_type', "=", 'person']
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
                    _allPatients.add(
                      new Patient(
                          id: i["id"],
                          email: i["email"] is! bool ? i["email"] : "N/A",
                          name: i["name"].toString(),
                          phone: i["phone"] is! bool ? i["phone"] : "N/A",
                          parent_id: i["parent_id"]),
                    );
                  }
                }
              });
              var patientlist = jsonEncode(res.getRecords());
              preference.setString("offlinepatientsts", patientlist);
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

  // LOAD PATIENTS DATA
  _getPatients() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {});
    if (preference.getString("offlinepatients") != null) {
      print(preference.getString("offlinepatients"));
      var patientlist = json.decode(preference.getString("offlinepatients"));
      setState(() {
        for (var i in patientlist) {
          if (i["name"].toString().length > 1 &&
              i["parent_id"][0] == _patient.id) {
            print("PARENT ID IS " + i["parent_id"].toString());
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
          odoo.searchRead(Strings.patients_module, [
            ['parent_id', "ilike", _patient.name],
            ['company_type', "=", 'person']
          ], [
            'email',
            'name',
            'phone'
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

    _patient = widget.data;
    _getPatients();
    _controller = TabController(length: list.length, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });

    getOdooInstance().then((odoo) {
      _getProfileData();
    });
  }

  _getProfileData() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        odoo.searchRead(Strings.patients_module, [
          ["id", "=", _patient.id]
        ], []).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                final result = res.getResult()['records'][0];
                name = result["name"];
                print("----------name-------------$name");
                email = result["email"];
                print("----------email-------------$email");
                phone = result['phone'] is! bool ? result['phone'] : "N/A";
                print("----------phone-------------$phone");
                location = result['patient_location'] is! bool
                    ? result['patient_location']
                    : "N/A";
                print("----------location-------------$location");
                history = result['patient_history'] is! bool
                    ? result['patient_history']
                    : "";
                print("----------history-------------$history");
                qrcode = result['qr_code'] is! bool ? result['qr_code'] : "";
                // city = result['city'] is! bool ? result['city'] : "";
                image_URL = getURL() +
                    "/web/image?model=patients.patients&field=image&" +
                    session +
                    "&id=" +
                    _patient.id.toString();
              });
            }
          },
        );
      } else {
        if (preference.getString("offlinepatients") != null) {
          print(preference.getString("offlinepatients"));
          var patientlist =
              json.decode(preference.getString("offlinepatients"));
          setState(() {
            name = _patient.name;
            location = _patient.patient_location;
            history = _patient.patient_history;
            account_name = _patient.name;
            qrcode = _patient.qr_code;
            image_URL = "";
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final upper_header = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 5.0, bottom: 5.0)),
        ],
      ),
    );

    final lower = Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            unselectedLabelColor: Colors.grey[700],
            labelColor: Color(0xff00a09d),
            indicatorColor: Color(0xff00a09d),
            tabs: [
              Tab(
                text: "Profile",
              ),
              // Tab(
              //   text: "D2C Details",
              // ),
              // Tab(
              //   text: "Commission",
              // ),
              // Tab(
              //   text: "Patients",
              // ),
            ],
            controller: _controller,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Name",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            // Text(
                            //   "Account Type",
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold, fontSize: 16),
                            // ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Patient History",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Location",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Date Of Birth",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "QRcode",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: VerticalDivider(
                            color: Co`lors.grey[400],
                            thickness: 1,
                          ),
                          height: 220,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Row(
                                children: [
                                  Flexible(
                                    child: new Container(
                                      padding: new EdgeInsets.only(right: 13.0),
                                      child: new Text(
                                        name ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              history ?? "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              location ?? "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              date_of_birth,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              region,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              village_name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: MaterialButton(
                        child: Text(
                          "New Order",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.indigo.shade400,
                        // onPressed: () {
                        //   push(AddInvoice(
                        //     partner: [_partner.id, _partner.name],
                        //   ));
                        // },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Add patient"),
                        IconButton(
                            icon: new Icon(
                              Icons.add_circle,
                              color: Colors.blue[900],
                              size: 22,
                            ),
                            onPressed: _addPatient)
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ListView.builder(
                            itemCount: _patients.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, i) => InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            PatientDetails(
                                                data: _patients[i])));
                              },
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    Divider(
                                      height: 10.0,
                                    ),
                                    ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Text(
                                                  _patients[i].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.mail,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  _patients[i].email,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0),
                                                ),
                                                Text(
                                                  _patients[i].patient_location,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  _patients[i].phone,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.31,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(background: upper_header),
            ),
          ];
        },
        body: lower,
      ),
    );
  }

  _addPatient() async {
    hideLoading();
    // setState(() {
    //   _lineQuantityController.text = "1";
    //   _linePriceSubtotalController.text = "0";
    //   _productSelection = "Select Product";
    // });
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            title: Text(
              "Add Patient",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Full Name",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _jobTitleController,
                          enabled: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Job Position",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.title,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _phoneNumberController,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _saveContact(
                      _nameController.text,
                      // _jobTitleController.text,
                      _patient.id,
                      _emailController.text,
                      _phoneNumberController.text);
                  // setState(() {
                  //   _invoiceLines.add(InvoiceLine(
                  //     name: _productSelection,
                  //     product_id: _productId,
                  //     account_id: [_accountId, _accountSelection],
                  //     quantity: double.tryParse(_lineQuantityController.text),
                  //     product_uom_id: [_uomId, _uomSelection],
                  //     price_unit:
                  //         double.tryParse(_linePriceSubtotalController.text),
                  //     price_total:
                  //         double.tryParse(_linePriceSubtotalController.text),
                  //   ));
                  // });
                  // _calculateTotals();
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
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
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return CupertinoAlertDialog(
            title: Text(
              "Add Product",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Full Name",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _jobTitleController,
                          enabled: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Job Position",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.title,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _phoneNumberController,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _saveContact(
                      _nameController.text,
                      // _jobTitleController.text,
                      _patient.id,
                      _emailController.text,
                      _phoneNumberController.text);
                  // setState(() {
                  //   _invoiceLines.add(InvoiceLine(
                  //     product_id: _productId,
                  //     account_id: [_accountId, _accountSelection],
                  //     quantity: double.tryParse(_lineQuantityController.text),
                  //     product_uom_id: [_uomId, _uomSelection],
                  //     price_total:
                  //         double.tryParse(_linePriceSubtotalController.text),
                  //   ));
                  // });
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
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
  }

  _saveContact(name, parentId, email, phone) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      // _registerPending = true;
    });
    showDialog(
      context: context, // <<----
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: Text("Please wait"),
          content: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Processing ....."),
            ],
          ),
        );
      },
    );
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.create(Strings.patients_module, {
          "name": name,
          "parent_id": parentId,
          "email": email,
          "phone": phone,
          // "function": position,
          "company_type": "person"
        }).then(
          (OdooResponse res) async {
            if (!res.hasError()) {
              setState(() {
                _registerPending = false;
              });
              await _updatePatientsList();
              Navigator.pop(dialogContext);
              showDialog(
                context: context, // <<----
                barrierDismissible: false,
                builder: (BuildContext context) {
                  dialogContext = context;
                  return AlertDialog(
                    title: Text("Success"),
                    content: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        new Text("Contact registered successfully"),
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      MaterialButton(
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          _updatePatientsList();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
              // showMessage("Success", "Contact registered successfully!");
              // pushReplacement(Partners());
            } else {
              setState(() {
                _registerPending = false;
              });
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlinepatientsadded") != null &&
            preference.getString("offlinepatientsadded") != "") {
          print("ADDING SUBSEQUENT OFFLINE PATIENT");
          List _patients = [];
          String patientsString = preference.getString("offlinecontactsadded");
          // print("THE OFFLINE CUSTOMERS STRING " +
          //     preference.getString("offlinepatientadded"));
          var patientlist = jsonDecode(patientsString);
          // print(
          //     "THE OFFLINE CUSTOMERS DECODED OBJECT " + cutomerlist.toString());
          setState(() {
            for (var i in patientlist) {
              _patients.add(
                {
                  "email": i["email"],
                  "name": i["name"],
                  "phone": i["phone"],
                  // "account_name": i["account_name"],
                  // "region": i["region"],
                  // "district": i["district"],
                  // "parish": i["parish"],
                  // "subCounty": i["subCounty"],
                  // "user_id": i["user_id"],
                  // "qb_cust": i["qb_cust"],
                },
              );
            }
            _patients.add(
              {
                "name": name,
                "email": email,
                "phone": phone,
              },
            );
          });
          var offlinepatientsadded = jsonEncode(_patients);
          // print("THE NEW OFFLINE ADDED CUSTOMERS OBJECT IS " +
          //     offlinepatientadded);
          preference.setString("offlinepatientsadded", offlinepatientsadded);
          if (preference.getString("offlinepatients") == null ||
              preference.getString("offlinepatients") == "") {
            preference.setString("offlinepatients", offlinepatientsadded);
          } else {
            String customersString = preference.getString("offlinepatients");
            // print(preference.getString("offlinecustomers"));
            var patientlist = json.decode(customersString);
            List _offlinePatients = [];
            setState(() {
              for (var i in patientlist) {
                _offlinePatients.add(
                  {
                    "email": i["email"],
                    // "name": i["name"],
                    // "phone": i["phone"],
                  },
                );
              }
              _offlinePatients.add(
                {
                  "name": name,
                  // "email": email,
                  // "phone": phone,
                },
              );
            });
            var offlinepatientsupdate = jsonEncode(_offlinePatients);
            // print("THE NEW OFFLINE CUSTOMERS OBJECT IS " +
            //     offlinepatientsupdate);
            preference.setString("offlinepatients", offlinepatientsupdate);
          }
          _showSuccessMessage(
              "Patient has been saved to your phone.\nPlease connect to the internet to sync.");
        } else {
          print("ADDING FIRST OFFLINE CONTACT");
          List _patients = [];
          _patients.add(
            {
              "name": name,
              // "email": email,
              // "phone": phone,
            },
          );
          var offlinepatientadded = jsonEncode(_patients);
          preference.setString("offlinepatientsadded", offlinepatientadded);
          if (preference.getString("offlinepatients") == null ||
              preference.getString("offlinepatients") == "") {
            preference.setString("offlinepatients", offlinepatientadded);
          } else {
            String patientString = preference.getString("offlinepatients");
            print(preference.getString("offlinepatients"));
            var patientlist = json.decode(patientString);
            List _offlinePatients = [];
            setState(() {
              for (var i in patientlist) {
                _offlinePatients.add(
                  {
                    'email': i["email"],
                    'name': i["name"],
                    'phone': i["phone"],
                  },
                );
              }
              _offlinePatients.add(
                {
                  "name": name,
                  "email": email,
                  "phone": phone,
                },
              );
            });
            var offlinepatientaddedupdate = jsonEncode(_offlinePatients);
            preference.setString("offlinepatients", offlinepatientaddedupdate);
          }
          _showSuccessMessage(
              "Phone has been saved to your phone.\nPlease connect to the internet to sync.");
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
            TextButton(
              onPressed: () async {
                // pushReplacement(Partners());
                await _getPatients();
                Navigator.of(context).pop();
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

  BoxDecoration customDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 2),
          color: Colors.grey[300],
          blurRadius: 5,
        )
      ],
    );
  }
}
