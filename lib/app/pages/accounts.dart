import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:patients/app/data/pojo/district.dart';
// import 'package:package:patients/app/data/pojo/invoices.dart';
// import 'package:package:patients/app/data/pojo/parish.dart';
import 'package:patients/app/data/pojo/patients.dart';
import 'package:patients/app/data/services/odoo_response.dart';
import 'package:patients/app/pages/createpatient.dart';
// import 'package:patients/app/pages/invoices.dart';
import 'package:patients/app/pages/patient_details.dart';
import 'package:patients/app/utility/constant.dart';
import 'package:patients/app/utility/strings.dart';
import 'package:patients/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'profile.dart';
import 'settings.dart';

List<Patient> searchdata = [];
List<Patient> _patients = [];

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends Base<Accounts> {
  //Odoo _odoo;

  String userfullname = "", email = "";
  // var _imageUrl;
  int _userId;
  String _result;
  BuildContext dialogContext;

  _getAccounts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userfullname = getUserFullName();
      email = getUserEmail();
      print("Email is " + email.toString());
    });
    if (preference.getString("offlineaccounts") != null) {
      print(preference.getString("offlineaccounts"));
      var patientlist = json.decode(preference.getString("offlineaccounts"));
      setState(() {
        for (var i in patientlist) {
          if (i["name"].toString().length > 1) {
            _patients.add(
              new Patient(
                id: i["id"],
                email: i["email"] is! bool ? i["email"] : "N/A",
                name: i["patient_name"].toString(),
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
            // ['parent_id', "!=", false],
            ['company_type', "=", 'company']
          ], [
            'email',
            'name',
            'phone',
            'parent_id',
            'company_type'
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
                            parent_id:
                                i["parent_id"] is! bool ? i["parent_id"] : []),
                      );
                      // searchdata.add(
                      //   new Partner(
                      //       id: i["id"],
                      //       email: i["email"] is! bool ? i["email"] : "N/A",
                      //       name: i["name"].toString(),
                      //       phone: i["phone"] is! bool ? i["phone"] : "N/A",
                      //       parent_id: i["parent_id"]),
                      // );
                    }
                  }
                });
                var patientlist = jsonEncode(res.getRecords());
                preference.setString("offlineaccounts", patientlist);
                preference.setString(
                    "offlineaccountslastupdated", DateTime.now().toString());
                print("Updated offline accounts repository at " +
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

  Future<void> _refreshAccounts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      showMessage("Please Wait", "Refreshing List .....");
      // showSnackBar("Refreshing patients list");
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.patients_module, [
          ['parent_id', "=", false],
          // ['company_type', "=", 'company']
        ], [
          'email',
          'name',
          'phone',
          'parent_id',
          // 'company_type'
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
                          parent_id:
                              i["parent_id"] is! bool ? i["parent_id"] : []),
                    );
                  }
                }
              });
              var patientlist = jsonEncode(res.getRecords());
              preference.setString("offlineaccounts", patientlist);
              preference.setString(
                  "offlineaccountslastupdated", DateTime.now().toString());
              print("Updated offline accounts repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
      Navigator.of(context).pop();
    });
  }

  _clearPrefs() async {
    odoo.destroy();
    preferences.remove(Constants.USER_PREF);
    preferences.remove(Constants.SESSION);
    pushAndRemoveUntil(Login());
  }

  @override
  void initState() {
    super.initState();
    getOdooInstance().then((odoo) {
      _getAccounts();
      _refreshAccounts();

      _userId = getUID();
      print("the user id is " + _userId.toString());
    });
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
                    Strings.no_patients,
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
        title: Text("Accounts"),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _refreshAccounts();
        },
        // label: const Text(''),
        child: const Icon(Icons.replay),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _patients.length > 0
          ? Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                reverse: true,
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
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      _patients[i].name,
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
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _patients[i].email,
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
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      _patients[i].phone,
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
          : emptyView,
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
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            listToShow[i].name,
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
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            listToShow[i].email,
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
                            Icons.phone,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            listToShow[i].phone,
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
