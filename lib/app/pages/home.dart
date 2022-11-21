import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:patients/app/data/pojo/patients.dart';
import 'package:patients/app/data/services/odoo_response.dart';
// import 'package:patients/app/pages/accounts.dart';
import 'package:patients/app/pages/addpatient.dart';
import 'package:patients/app/pages/createpatient.dart';
import 'package:patients/app/pages/patient_details.dart';
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
        // await _getPatients();
        await _getPatients;
        await new Future.delayed(new Duration(seconds: 6));
        Navigator.of(context).pop();
      }
    });
  }

  _getPatients() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userfullname = getUserFullName();
      email = getUserEmail();
      print("Email is " + email.toString());
    });
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
            // 'mobile',
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
    _getPatients();
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
      // bottomNavigationBar: SalomonBottomBar(
      //   currentIndex: _SelectedTab.values.indexOf(_selectedTab),
      //   onTap: (int index) {
      //     // page.animateToPage(index,
      //     //     curve: null, duration: Duration(milliseconds: 100));
      //     page.jumpToPage(index);
      //     setState(() {
      //       _selectedTab = _SelectedTab.values[index];
      //     });
      //   },
      //   items: [
      //     /// Home
      //     SalomonBottomBarItem(
      //       icon: Icon(Icons.shop),
      //       title: Text("Dealers"),
      //       selectedColor: Constants.primaryColor,
      //     ),

      //     /// Likes
      //     SalomonBottomBarItem(
      //       icon: Icon(Icons.person),
      //       title: Text("Agents"),
      //       selectedColor: Constants.primaryColor,
      //     ),

      //     /// Search
      //     SalomonBottomBarItem(
      //       icon: Icon(Icons.people),
      //       title: Text("Farmers"),
      //       selectedColor: Constants.primaryColor,
      //     ),
      //   ],
      // ),
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
          // IconButton(
          //     onPressed: () async {
          //       var result = await showSearch<String>(
          //         context: context,
          //         delegate: CustomDelegate(),
          //       );
          //       setState(() => _result = result);
          //     },
          //     icon: Icon(Icons.search)),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _refreshPartners();
      //   },
      //   // label: const Text(''),
      //   child: const Icon(Icons.replay),
      //   backgroundColor: Constants.secondaryColor,
      // ),
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
                    // push(PartnerDetails(data: _partners[i]));
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
        // onTap: () {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (BuildContext context) =>
        //               PartnerDetails(data: listToShow[i])));
        // },
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
                            color: Constants.secondaryColor,
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
                            color: Constants.secondaryColor,
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
