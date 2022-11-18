import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
// import 'package:patients/app/data/pojo/delivery.dart';
// import 'package:patients/app/data/pojo/district.dart';
// import 'package:patients/app/data/pojo/employees.dart';
// import 'package:patients/app/data/pojo/employeestock.dart';
// import 'package:patients/app/data/pojo/invoicelines.dart';
// import 'package:patients/app/data/pojo/invoices.dart';
// import 'package:patients/app/data/pojo/parish.dart';
import 'package:patients/app/data/pojo/patients.dart';
// import 'package:patients/app/data/pojo/pricelistitems.dart';
// import 'package:patients/app/data/pojo/pricelists.dart';
// import 'package:patients/app/data/pojo/region.dart';
// import 'package:patients/app/data/pojo/requisitionlines.dart';
// import 'package:patients/app/data/pojo/requisitions.dart';
// import 'package:patients/app/data/pojo/stocklocations.dart';
// import 'package:patients/app/data/pojo/stockmovelines.dart';
// import 'package:patients/app/data/pojo/stockmoves.dart';
// import 'package:patients/app/data/pojo/stockquant.dart';
// import 'package:patients/app/data/pojo/subcounty.dart';
// import 'package:patients/app/data/pojo/village.dart';
import 'package:patients/app/data/services/odoo_response.dart';
// import 'package:patients/app/pages/accounts.dart';
// import 'package:patients/app/pages/addinvoice.dart';
import 'package:patients/app/pages/addpatient.dart';
import 'package:patients/app/pages/createpatient.dart';

// import 'package:patients/app/pages/draftinvoices.dart';
// import 'package:patients/app/pages/invoices.dart';
import 'package:patients/app/pages/patient_details.dart';
import 'package:patients/app/pages/patients.dart';
// import 'package:patients/app/pages/shiptocustomer.dart';
// import 'package:patients/app/pages/shiptosales_old.dart';
// import 'package:patients/app/pages/stocktaking.dart';
import 'package:patients/app/utility/constant.dart';
import 'package:patients/app/utility/strings.dart';
import 'package:patients/base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
// import 'profile.dart';
import 'settings.dart';
import 'package:intl/intl.dart';

// import 'shiptosales.dart';
// import 'viewemployeestock.dart';

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
  // List<String> _locations = ['Kampala', 'Jinja'];
  // String _selectedLocation;
  // List<EmployeeStock> _employeeStock = [];
  // List<EmployeeStock> _allEmployeeStock = [];
  // List<StockPicking> _stockPickings = [];
  // List<Invoice> _invoices = [];
  List<Patient> _patients = [];
  // List<Partner> _contacts = [];
  // List<StockMoves> _stockMoves = [];
  // List<StockMoveLines> _stockMoveLines = [];
  // List<StockQuant> _employeeStockQuant = [];
  // List<Employees> _salesOfficers = [];
  // List<PriceList> _priceLists = [];
  // List<PriceListItem> _priceListItems = [];
  // List<InvoiceLine> _invoiceLines = [];
  // List<Region> _regions = [];
  // List<District> _districts = [];
  // List<SubCounty> _subCountiess = [];
  // List<Parish> _parishes = [];
  // List<Village> _villages = [];
  // List<Requisition> _requisitions = [];
  // List<RequisitionLine> _requisitionLines = [];
  // List<StockLocation> _employeeStockLocations = [];
  // List<Employees> _employees = [];
  String fullname = "";
  // LoaderOverlay loaderOverlay;
  final value = new NumberFormat("#,##0", "en_US");
  String _patientId = "";
  String _displaypatientId = "";
  String _currentMonth = "";
  // int _customerLocationId;
  // String _customerLocationSelection = '';
  // bool _isTeamLeader = false;
  List _employeeLocationId = [];
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
        await _getPatients();
        await new Future.delayed(new Duration(seconds: 6));
        Navigator.of(context).pop();
      }
    });
  }

  
  //GET PATIENTS/CLIENTS
  _getPatients() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.res_partner, [
          ['parent_id', "=", false],
          ['company_type', "!=", 'person'],
          //  ['user_id', "=", 2]
        ], [
          'name',
          // 'patient_history',
          // 'date_of_birth',
          // 'parent_id',
          // 'patient_location'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  if (i["name"].toString().length > 1 &&
                      i["parent_id"] is bool) {
                    _patients.add(
                      new Patient(
                        id: i["id"],
                        // date_of_birth: i["date_of_birth"] is! bool ? i["date_of_birth"] : "N/A",
                        name: i["name"].toString(),
                        // age: i["age"] is! bool ? i["age"] : "N/A",
                        // patient_location: i["patient_location"] is! bool ? i["patient_location"] : "N/A",
                        parent_id:
                            i["parent_id"] is! bool ? i["parent_id"] : [],
                        imageUrl: getURL() +
                            "/web/image?model=res.partner&field=image&" +
                            session +
                            "&id=" +
                            i["id"].toString(),
                      ),
                    );
                  }
                }
              });
              var patientlist = jsonEncode(res.getRecords());
              print("patients list from the API" + patientlist);
              // print(res.getRecords())
              preference.setString("offlinepatients", patientlist);
              preference.setString(
                  "offlinepatientslastupdated", DateTime.now().toString());
              print("Updated offline patient repository at " +
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
  //SAVE PATIENT TO REMOTE ODOO
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
              showMessage("Success", "Customer registered successfully!");
              // pushAndRemoveUntil(Partners());
            } else {
              setState(() {
                // _registerPending = false;
              });
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  // _saveContact(name, position, parentId, email, phone) async {
  //   SharedPreferences preference = await SharedPreferences.getInstance();
  //   setState(() {
  //     // _registerPending = true;
  //   });
  //   isConnected().then((isInternet) {
  //     if (isInternet) {
  //       showLoading();
  //       odoo.create(Strings.res_partner, {
  //         "name": name,
  //         "parent_id": parentId,
  //         "email": email,
  //         "phone": phone,
  //         "function": position,
  //         "company_type": "person"
  //       }).then(
  //         (OdooResponse res) async {
  //           if (!res.hasError()) {
  //             await _getContacts();
  //             showMessage("Success", "Contact registered successfully!");
  //             // pushReplacement(Partners());
  //           } else {
  //             print(res.getError());
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
  //     }
  //   });
  // }

  
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
      alignment: Alignment.center,
      child: Center(
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
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(_firstName + " - " + _displaypatientId.toString()),
        actions: [
          IconButton(
              onPressed: () {
                _refreshData();
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
              // ListTile(
              //   leading: Icon(Icons.library_books_sharp),
              //   title: Text("Accounts"),
              //   onTap: () {
              //     print("Accounts Clicked");
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Accounts()),
              //     );
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.library_books_sharp),
              //   title: Text("Invoices"),
              //   onTap: () {
              //     print("Invoices Clicked");
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Invoices()),
              //     );
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text("Profile"),
              //   onTap: () {
              //     print("Profile Clicked");
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => ProfilePage()),
              //     );
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.settings),
              //   title: Text("Settings"),
              //   onTap: () {
              //     print("About Clicked");
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Settings()),
              //     );
              //   },
              // ),
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
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          for (var item in _patients) Text(item.name),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: ListView(
              // gridDelegate:
              //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              children: <Widget>[
                Container(
                  height: _patients.isEmpty ? 110 : 220,
                  width: double.maxFinite,
                  child: Card(
                    child: SingleChildScrollView(
                      child: DataTable(
                        showBottomBorder: true,
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) {
                            return Color(0xff3179ca);
                          },
                        ),
                        dataRowColor: MaterialStateColor.resolveWith(
                          (states) {
                            return Color(0xffc4eefd);
                          },
                        ),
                        columnSpacing: 10,
                        // dataRowHeight: 1,
                        columns: [
                          DataColumn(
                              label: Text('$_currentMonth',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Name',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Age',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Location ',
                                  style: TextStyle(color: Colors.white))),
                        ],
                        rows: _patients.isEmpty
                            ? [
                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Text(
                                        "Data Unavailable",
                                        overflow: TextOverflow.visible,
                                      ),
                                    )), //Extracting from Map element the value
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                    DataCell(Text("")),
                                  ],
                                )
                              ]
                            : _patients // Loops through dataColumnText, each iteration assigning the value to element
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        child: Text(
                                          element.name[1].toString(),
                                          overflow: TextOverflow.visible,
                                        ),
                                      )), //Extracting from Map element the value
                                      DataCell(Text(
                                          element.patient_history.toString())),
                                      DataCell(Text(element.age.toString())),
                                      DataCell(Text(
                                          element.date_of_birth.toString())),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // GestureDetector(
                //   onTap: () {
                //     push(ShipToSales());
                //   },
                //   child: Container(
                //     height: 80,
                //     child: Card(
                //       color: Color(0xff00a3d2),
                //       shadowColor: Colors.grey[700],
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           FaIcon(
                //             FontAwesomeIcons.truckLoading,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 12,
                //           ),
                //           Text(
                //             "Ship stock to Sales Officer",
                //             style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // GestureDetector(
                //   onTap: () {
                //     push(ShipToCustomer());
                //   },
                //   child: Container(
                //     height: 80,
                //     child: Card(
                //       color: Color(0xff00a3d2),
                //       shadowColor: Colors.grey[700],
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           FaIcon(
                //             FontAwesomeIcons.shippingFast,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 12,
                //           ),
                //           Text(
                //             "Ship stock to Customer",
                //             style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // GestureDetector(
                //   onTap: () {
                //     push(StockTaking());
                //   },
                //   child: Container(
                //     height: 80,
                //     child: Card(
                //       color: Color(0xff00a3d2),
                //       shadowColor: Colors.grey[700],
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           FaIcon(
                //             FontAwesomeIcons.edit,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 12,
                //           ),
                //           Text(
                //             "Record Stock Count",
                //             style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                // GestureDetector(
                //   onTap: () {
                //     push(ViewEmploeeStock());
                //   },
                //   child: Container(
                //     height: 80,
                //     child: Card(
                //       color: Color(0xff00a3d2),
                //       shadowColor: Colors.grey[700],
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           FaIcon(
                //             FontAwesomeIcons.search,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 12,
                //           ),
                //           Text(
                //             "Check Staff Stock Balance",
                //             style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddPatient())),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
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

