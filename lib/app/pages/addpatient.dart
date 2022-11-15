// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:date_format/date_format.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // import 'package:package:patients/app/data/pojo/district.dart';
// // import 'package:package:patients/app/data/pojo/parish.dart';
// import 'package:patients/app/data/pojo/patients.dart';
// // import 'package:package:patients/app/data/pojo/region.dart';
// // import 'package:package:patients/app/data/pojo/subcounty.dart';
// // import 'package:package:patients/app/data/pojo/village.dart';
// import 'package:patients/app/data/services/odoo_api.dart';
// import 'package:patients/app/data/services/odoo_response.dart';
// import 'package:patients/app/pages/accounts.dart';
// import 'package:patients/app/pages/patients.dart';
// import 'package:patients/app/utility/constant.dart';
// import 'package:patients/app/utility/strings.dart';
// import 'package:patients/base.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'home.dart';
// import 'login.dart';

// class AddPatient extends StatefulWidget {
//   @override
//   _AddPatientState createState() => _AddPatientState();
// }

// class _AddPatientState extends Base<AddPatient> {
//   TextEditingController _urlCtrler = new TextEditingController();
//   TextEditingController _accountNameController = new TextEditingController();
//   TextEditingController _phoneController = new TextEditingController();
//   TextEditingController _emailController = new TextEditingController();
//   TextEditingController _qbController = new TextEditingController();
//   TextEditingController _endTimeController = new TextEditingController();
//   TextEditingController _startTimeController = new TextEditingController();
//   TextEditingController _femaleAttendeesController =
//       new TextEditingController();
//   TextEditingController _maleAttendeesController = new TextEditingController();
//   TextEditingController _lateAttendeesController = new TextEditingController();
//   TextEditingController _totalAttendeesController = new TextEditingController();
//   TextEditingController _groupsController = new TextEditingController();
//   TextEditingController _collectionOfficerController =
//       new TextEditingController();
//   // bool post_d2c = false,
//   //     leader_attended = false,
//   //     lc_stayed = false,
//   //     presentation_filter = false,
//   //     additional_d2c = false,
//   //     money_sent = false,
//   //     when_group_meets = false,
//   //     is_this_a_savings_group = false;
//   String odooURL = "";
//   int _regionId = 0,
//       _districtId = 0,
//       _subCountyId = 0,
//       _parishId = 0,
//       _villageId = 0,
//       _userId;
//   // List<Region> _regions = [];
//   List<Patient> patients = [];
//   // List<District> _districts = [];
//   // List<SubCounty> _subCountiess = [];
//   // List<Parish> _parishes = [];
//   // List<Village> _villages = [];
//   // String _regionSelection = "Select Region",
//   String _districtSelection = "Select District",
//       // _parishSelection = "Select Parish",
//       // _subCountySelection = "Select Sub-County",
//       // _villageSelection = "Select Village",
//       // _accountTypeSelection = "Spouts Account Type";
//   bool _registerPending = false, _accountNameEnabled = true;
//   BuildContext dialogContext;
//   String _displayEmployeeId = "";
//   final _timeFormat = DateFormat("HH:mm");

//   @override
//   void initState() {
//     super.initState();
//     getOdooInstance().then((odoo) {
//       // _getRegions();
//       _getEmployeeData();
//     });
//     setState(() {
//       _registerPending = false;
//       _accountNameEnabled = true;
//       _userId = getUID();
//     });
//     print("the user id is " + _userId.toString());
//   }

//   // _getAccountName() {
//   //   final formattedStr = formatDate(DateTime.now(), [dd, '.', mm, '.', yy]);
//   //   print(formattedStr);
//   //   if (_accountTypeSelection == "d2c") {
//   //     setState(() {
//   //       _accountNameEnabled = false;
//   //       _accountNameController.clear();
//   //       _accountNameController.text = "D2C";
//   //     });
//   //     if (_villageSelection != "Select Village") {
//   //       setState(() {
//   //         _accountNameController.text =
//   //             "D2C $_displayEmployeeId $_villageSelection $formattedStr";
//   //       });
//   //     }
//   //   } else if (_accountTypeSelection == "Corporates") {
//   //     setState(() {
//   //       _accountNameEnabled = false;
//   //       _accountNameController.clear();
//   //       _accountNameController.text = "CORP";
//   //     });
//   //     if (_villageSelection != "Select Village") {
//   //       setState(() {
//   //         _accountNameController.text =
//   //             "CORP $_displayEmployeeId $_villageSelection $formattedStr";
//   //       });
//   //     }
//   //   } else {
//   //     setState(() {
//   //       _accountNameEnabled = true;
//   //       _accountNameController.clear();
//   //     });
//   //   }
//   // }

//   _getEmployeeData() async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     if (preference.getString("displayemployeeid") != null) {
//       print("THE DISPLAY EMPLOYEE ID IS: " +
//           preference.getString("displayemployeeid"));

//       _displayEmployeeId = preference.getString("displayemployeeid");
//     }
//   }

//   // _getRegions() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   if (preference.getString("offlinecustomersadded") != null) {
//   //     // preference.setString("offlinecustomersadded", "");
//   //     // preference.setString("offlinecustomers", "");
//   //     print("THE ADDED OFFLINE CUSTOMERS ARE: " +
//   //         preference.getString("offlinecustomersadded"));
//   //   }
//   //   if (preference.getString("offlineregions") != null) {
//   //     String regionsString = preference.getString("offlineregions");
//   //     print(regionsString);
//   //     var regionlist = json.decode(regionsString);
//   //     setState(() {
//   //       for (var i in regionlist) {
//   //         _regions.add(
//   //           new Region(
//   //             id: i["id"],
//   //             name: i["name"].toString(),
//   //           ),
//   //         );
//   //       }
//   //     });
//   //   } else {
//   //     isConnected().then((isInternet) {
//   //       if (isInternet) {
//   //         showLoading();
//   //         //GET REGIONS
//   //         odoo.searchRead(Strings.region, [], ['id', 'name']).then(
//   //           (OdooResponse res) {
//   //             if (!res.hasError()) {
//   //               setState(() {
//   //                 hideLoading();
//   //                 String session = getSession();
//   //                 session = session.split(",")[0].split(";")[0];
//   //                 for (var i in res.getRecords()) {
//   //                   _regions.add(
//   //                     new Region(
//   //                       id: i["id"],
//   //                       name: i["name"].toString(),
//   //                     ),
//   //                   );
//   //                 }
//   //                 var regionlist = jsonEncode(res.getRecords());
//   //                 preference.setString("offlineregions", regionlist);
//   //                 preference.setString(
//   //                     "offlineregionslastupdated", DateTime.now().toString());
//   //                 print("Updated offline region repository at " +
//   //                     DateTime.now().toString());
//   //               });
//   //             } else {
//   //               print(res.getError());
//   //               showMessage("Warning", res.getErrorMessage());
//   //             }
//   //           },
//   //         );
//   //       }
//   //     });
//   //   }
//   // }

//   _getDistricts() async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     setState(() {
//       _districts.clear();
//     });
//     if (preference.getString("offlinedistricts") != null) {
//       String districtsString = preference.getString("offlinedistricts");
//       print(districtsString);
//       var districtlist = json.decode(districtsString);
//       setState(() {
//         for (var i in districtlist) {
//           if (i["region"] is! bool &&
//               _regionSelection.length > 2 &&
//               i["region"][1] == _regionSelection) {
//             _districts.add(
//               new District(
//                 id: i["id"],
//                 name: i["name"].toString(),
//               ),
//             );
//           }
//         }
//       });
//     } else {
//       isConnected().then((isInternet) {
//         if (isInternet) {
//           showLoading();
//           //GET DISTRICTS
//           print("PARENT REGION IS " + _regionSelection);
//           odoo.searchRead(Strings.district, [
//             ['region', 'ilike', _regionSelection]
//           ], [
//             'id',
//             'name'
//           ]).then(
//             (OdooResponse res) {
//               if (!res.hasError()) {
//                 setState(() {
//                   hideLoading();
//                   String session = getSession();
//                   int count = 0;
//                   session = session.split(",")[0].split(";")[0];
//                   for (var i in res.getRecords()) {
//                     _districts.add(
//                       new District(
//                         id: i["id"],
//                         name: i["name"].toString(),
//                       ),
//                     );
//                   }
//                   var districtlist = jsonEncode(res.getRecords());
//                   preference.setString("offlinedistricts", districtlist);
//                   preference.setString(
//                       "offlinedistrictslastupdated", DateTime.now().toString());
//                   print("Updated offline district repository at " +
//                       DateTime.now().toString());
//                 });
//               } else {
//                 print(res.getError());
//                 showMessage("Warning", res.getErrorMessage());
//               }
//             },
//           );
//         }
//       });
//     }
//   }

//   // _getParishes() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     _parishes.clear();
//   //   });
//   //   if (preference.getString("offlineparishes") != null) {
//   //     String parishesString = preference.getString("offlineparishes");
//   //     print(parishesString);
//   //     var parishlist = json.decode(parishesString);
//   //     setState(() {
//   //       for (var i in parishlist) {
//   //         if (i["subcounty"] is! bool &&
//   //             _subCountySelection.length > 2 &&
//   //             i["subcounty"][1] == _subCountySelection) {
//   //           // && i["subCounty"][1] == _subCountySelection) {
//   //           _parishes.add(
//   //             new Parish(
//   //               id: i["id"],
//   //               name: i["name"].toString(),
//   //             ),
//   //           );
//   //         }
//   //       }
//   //     });
//   //   } else {
//   //     isConnected().then((isInternet) {
//   //       if (isInternet) {
//   //         showLoading();
//   //         //GET PARISHES
//   //         print("PARENT SUB COUNTY IS " + _subCountySelection);
//   //         odoo.searchRead(Strings.parish, [
//   //           ['subCounty', 'ilike', _subCountySelection]
//   //         ], [
//   //           'id',
//   //           'name'
//   //         ]).then(
//   //           (OdooResponse res) {
//   //             if (!res.hasError()) {
//   //               setState(() {
//   //                 hideLoading();
//   //                 String session = getSession();
//   //                 int count = 0;
//   //                 session = session.split(",")[0].split(";")[0];
//   //                 for (var i in res.getRecords()) {
//   //                   _parishes.add(
//   //                     new Parish(
//   //                       id: i["id"],
//   //                       name: i["name"].toString(),
//   //                     ),
//   //                   );
//   //                 }
//   //                 var parishlist = jsonEncode(res.getRecords());
//   //                 preference.setString("offlineparishes", parishlist);
//   //                 preference.setString(
//   //                     "offlineparisheslastupdated", DateTime.now().toString());
//   //                 print("Updated offline parish repository at " +
//   //                     DateTime.now().toString());
//   //               });
//   //             } else {
//   //               print(res.getError());
//   //               showMessage("Warning", res.getErrorMessage());
//   //             }
//   //           },
//   //         );
//   //       }
//   //     });
//   //   }
//   // }

//   // _getSubCounties() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     _subCountiess.clear();
//   //   });
//   //   if (preference.getString("offlinesubcounties") != null) {
//   //     String subcountiesString = preference.getString("offlinesubcounties");
//   //     print("++++++++++++++++THIS IS THE OFFLINE SUBCOUNTY REPO");
//   //     print(subcountiesString);
//   //     var subcountylist = json.decode(subcountiesString);
//   //     setState(() {
//   //       for (var i in subcountylist) {
//   //         if (i["district"] is! bool &&
//   //             _districtSelection.length > 2 &&
//   //             i["district"][1] == _districtSelection) {
//   //           _subCountiess.add(
//   //             new SubCounty(
//   //               id: i["id"],
//   //               name: i["name"].toString(),
//   //             ),
//   //           );
//   //         }
//   //       }
//   //     });
//   //   } else {
//   //     isConnected().then((isInternet) {
//   //       if (isInternet) {
//   //         showLoading();
//   //         //GET SUBCOUNTIES
//   //         print("PARENT DISTRICT IS " + _districtSelection);
//   //         odoo.searchRead(Strings.sub_county, [
//   //           ['district', 'ilike', _districtSelection]
//   //         ], [
//   //           'id',
//   //           'name'
//   //         ]).then(
//   //           (OdooResponse res) {
//   //             if (!res.hasError()) {
//   //               setState(() {
//   //                 hideLoading();
//   //                 String session = getSession();
//   //                 int count = 0;
//   //                 session = session.split(",")[0].split(";")[0];
//   //                 for (var i in res.getRecords()) {
//   //                   _subCountiess.add(
//   //                     new SubCounty(
//   //                       id: i["id"],
//   //                       name: i["name"].toString(),
//   //                     ),
//   //                   );
//   //                 }
//   //                 var subcountylist = jsonEncode(res.getRecords());
//   //                 preference.setString("offlinesubcounties", subcountylist);
//   //                 preference.setString("offlinesubcountieslastupdated",
//   //                     DateTime.now().toString());
//   //                 print("Updated offline subcounty repository at " +
//   //                     DateTime.now().toString());
//   //               });
//   //             } else {
//   //               print(res.getError());
//   //               showMessage("Warning", res.getErrorMessage());
//   //             }
//   //           },
//   //         );
//   //       }
//   //     });
//   //   }
//   // }

//   // _getVillages() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     _villages.clear();
//   //   });
//   //   if (preference.getString("offlinevillages") != null) {
//   //     String villagesString = preference.getString("offlinevillages");
//   //     print(villagesString);
//   //     var villagelist = json.decode(villagesString);
//   //     setState(() {
//   //       for (var i in villagelist) {
//   //         if (i["parish"] is! bool &&
//   //             _parishSelection.length > 2 &&
//   //             i["parish"][1].toString().contains(_parishSelection)) {
//   //           print('PARISH VALUE IS ' + i["parish"][1]);
//   //           _villages.add(
//   //             new Village(
//   //               id: i["id"],
//   //               name: i["name"].toString(),
//   //             ),
//   //           );
//   //         }
//   //       }
//   //     });
//   //   } else {
//   //     isConnected().then((isInternet) {
//   //       if (isInternet) {
//   //         showLoading();
//   //         // GET VILLAGES
//   //         print("PARENT PARISH IS " + _parishSelection);
//   //         odoo.searchRead(Strings.village, [
//   //           ['parish', 'ilike', _parishSelection]
//   //         ], [
//   //           'id',
//   //           'name'
//   //         ]).then(
//   //           (OdooResponse res) {
//   //             if (!res.hasError()) {
//   //               setState(() {
//   //                 hideLoading();
//   //                 String session = getSession();
//   //                 int count = 0;
//   //                 session = session.split(",")[0].split(";")[0];
//   //                 for (var i in res.getRecords()) {
//   //                   _villages.add(
//   //                     new Village(
//   //                       id: i["id"],
//   //                       name: i["name"].toString(),
//   //                     ),
//   //                   );
//   //                 }
//   //                 var villagelist = jsonEncode(res.getRecords());
//   //                 preference.setString("offlinevillages", villagelist);
//   //                 preference.setString(
//   //                     "offlinevillageslastupdated", DateTime.now().toString());
//   //                 print("Updated offline village repository at " +
//   //                     DateTime.now().toString());
//   //               });
//   //             } else {
//   //               print(res.getError());
//   //               showMessage("Warning", res.getErrorMessage());
//   //             }
//   //           },
//   //         );
//   //       }
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     var _height = MediaQuery.of(context).size.height;
//     var _width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text("New Patient"),
//       ),
//       body: ListView(
//         children: <Widget>[
//           SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Center(
//                           child: DropdownButton<String>(
//                         isExpanded: true,
//                         hint: Row(
//                           children: [
//                             Icon(
//                               Icons.account_box,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               _accountTypeSelection,
//                               style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400),
//                             ),
//                           ],
//                         ),
//                         items: <String>[
//                           'd2c',
//                           'Corporates',
//                           // 'other',
//                           // 'Suppliers',
//                           // 'Partners',
//                           // 'CBOs',
//                           // 'Healh Clinic/Hospital',
//                           // 'Hotels & Restaurants',
//                           // 'Individuals',
//                           // 'NGOs',
//                           // 'Microfinance Institutions',
//                           // 'Public and Government Facilities',
//                           // 'Religious Institutions',
//                           // 'Retail & Wholesale',
//                           // 'SACCOS & Coops, School'
//                         ].map((String value) {
//                           return new DropdownMenuItem<String>(
//                             value: value,
//                             child: new Row(
//                               children: [
//                                 Icon(
//                                   Icons.account_box,
//                                   color: Theme.of(context).primaryColor,
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 new Text(
//                                   value,
//                                   style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (newVal) {
//                           setState(() {
//                             _accountTypeSelection = newVal;
//                             print(_accountTypeSelection);
//                           });
//                           _getAccountName();
//                         },
//                       )),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: TextFormField(
//                 controller: _accountNameController,
//                 enabled: _accountNameEnabled,
//                 decoration: InputDecoration(
//                   hintText: "Account Name",
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                   prefixIcon: Icon(
//                     Icons.person,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Center(
//                         child: DropdownButton(
//                           isExpanded: true,
//                           hint: Row(
//                             children: [
//                               Icon(
//                                 Icons.location_city,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               // Text(
//                               //   _regionSelection,
//                               //   style: TextStyle(
//                               //       color: Colors.grey,
//                               //       fontSize: 16,
//                               //       fontWeight: FontWeight.w400),
//                               // ),
//                             ],
//                           ),
//                           items: _regions.map((item) {
//                             return new DropdownMenuItem(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_city,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   new Text(
//                                     item.name,
//                                     style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ],
//                               ),
//                               value: item.id,
//                             );
//                           }).toList(),
//                           onChanged: (newVal) {
//                             List itemsList = _regions.map((item) {
//                               if (item.id == newVal) {
//                                 setState(() {
//                                   _regionSelection = item.name;
//                                   _regionId = item.id;
//                                   print(_regionSelection);
//                                   print(_regionId);
//                                 });
//                               }
//                               _getDistricts();
//                             }).toList();
//                           },
//                           // value: _mySelection,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Center(
//                         child: DropdownButton(
//                           isExpanded: true,
//                           hint: Row(
//                             children: [
//                               Icon(
//                                 Icons.location_city,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Text(
//                                 _districtSelection,
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                           items: _districts.map((item) {
//                             return new DropdownMenuItem(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_city,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   new Text(
//                                     item.name,
//                                     style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ],
//                               ),
//                               value: item.id,
//                             );
//                           }).toList(),
//                           onChanged: (newVal) {
//                             List itemsList = _districts.map((item) {
//                               if (item.id == newVal) {
//                                 setState(() {
//                                   _districtSelection = item.name;
//                                   _districtId = item.id;
//                                   print(_districtSelection);
//                                   print(_districtId);
//                                 });
//                                 _getSubCounties();
//                               }
//                             }).toList();
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Center(
//                         child: DropdownButton(
//                           isExpanded: true,
//                           hint: Row(
//                             children: [
//                               Icon(
//                                 Icons.location_city,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Text(
//                                 _subCountySelection,
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                           items: _subCountiess.map((item) {
//                             return new DropdownMenuItem(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_city,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   new Text(
//                                     item.name,
//                                     style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ],
//                               ),
//                               value: item.id,
//                             );
//                           }).toList(),
//                           onChanged: (newVal) {
//                             List itemsList = _subCountiess.map((item) {
//                               if (item.id == newVal) {
//                                 setState(() {
//                                   _subCountySelection = item.name;
//                                   _subCountyId = item.id;
//                                   print(_subCountySelection);
//                                   print(_subCountyId);
//                                 });
//                                 _getParishes();
//                               }
//                             }).toList();
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Center(
//                         child: DropdownButton(
//                           isExpanded: true,
//                           hint: Row(
//                             children: [
//                               Icon(
//                                 Icons.location_city,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Text(
//                                 _parishSelection,
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                           items: _parishes.map((item) {
//                             return new DropdownMenuItem(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_city,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   new Text(
//                                     item.name,
//                                     style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ],
//                               ),
//                               value: item.id,
//                             );
//                           }).toList(),
//                           onChanged: (newVal) {
//                             List itemsList = _parishes.map((item) {
//                               if (item.id == newVal) {
//                                 setState(() {
//                                   _parishSelection = item.name;
//                                   _parishId = item.id;
//                                   print(_parishSelection);
//                                   print(_parishId);
//                                 });
//                                 _getVillages();
//                               }
//                             }).toList();
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Center(
//                         child: DropdownButton(
//                           isExpanded: true,
//                           hint: Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on_outlined,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Text(
//                                 _villageSelection,
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                           items: _villages.map((item) {
//                             return new DropdownMenuItem(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_on_outlined,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   new Text(
//                                     item.name,
//                                     style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ],
//                               ),
//                               value: item.id,
//                             );
//                           }).toList(),
//                           onChanged: (newVal) {
//                             List itemsList = _villages.map((item) {
//                               if (item.id == newVal) {
//                                 setState(() {
//                                   _villageSelection = item.name;
//                                   _villageId = item.id;
//                                   print(_villageSelection);
//                                   print(_villageId);
//                                 });
//                               }
//                             }).toList();
//                             _getAccountName();
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   hintText: "Email Address",
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                   prefixIcon: Icon(
//                     Icons.mail,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Phone Contact",
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                   prefixIcon: Icon(
//                     Icons.phone,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               margin: EdgeInsets.only(bottom: 15),
//               width: _width * 0.89,
//               decoration: customDecoration(),
//               child: TextFormField(
//                 keyboardType: TextInputType.number,
//                 controller: _qbController,
//                 decoration: InputDecoration(
//                   hintText: "QB Customer ID",
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                   prefixIcon: Icon(
//                     Icons.camera_front_rounded,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Divider(),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               padding: EdgeInsets.symmetric(vertical: 16.0),
//               child: ElevatedButton(
//                 // shape: RoundedRectangleBorder(
//                 //   borderRadius: BorderRadius.circular(30),
//                 // ),
//                 onPressed: () {
//                   _addD2cInfo();
//                 },
//                 // padding: EdgeInsets.all(12),
//                 // color: Color(0xff00a09d),
//                 child: Text(
//                   'Add D2C Information',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: "Montserrat",
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Divider(),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 15),
//             child: _registerPending
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Registering Account.....",
//                         style: TextStyle(
//                             fontWeight: FontWeight.w500, fontSize: 18),
//                       ),
//                     ],
//                   )
//                 // ? CircularProgressIndicator(
//                 //     valueColor:
//                 //         new AlwaysStoppedAnimation<Color>(Color(0xff00a09d)),
//                 //   )
//                 : Container(
//                     width: MediaQuery.of(context).size.width,
//                     padding: EdgeInsets.symmetric(vertical: 16.0),
//                     child: ElevatedButton(
//                       // shape: RoundedRectangleBorder(
//                       //   borderRadius: BorderRadius.circular(30),
//                       // ),
//                       onPressed: () {
//                         _savePatient(
//                             _accountNameController.text,
//                             _regionId,
//                             _districtId,
//                             _parishId,
//                             57,
//                             90000,
//                             _emailController.text,
//                             _phoneController.text,
//                             _qbController.text,
//                             _accountTypeSelection);

//                         setState(() {
//                           // _regionSelection = "Select Region";
//                           _districtSelection = "Select District";
//                           // _parishSelection = "Select Parish";
//                           // _subCountySelection = "Select Sub-County";
//                           // _villageSelection = "Select Village";
//                           // _accountTypeSelection = "Spouts Account Type";
//                           _emailController.text = "";
//                           _phoneController.text = "";
//                           _qbController.text = "";
//                           _accountNameController.text = "";
//                         });
//                       },
//                       // padding: EdgeInsets.all(12),
//                       // color: Color(0xff00a09d),
//                       child: Text(
//                         'Create Patient',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: "Montserrat",
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//           )
//         ],
//       ),
//     );
//   }

//   _addD2cInfo() async {
//     hideLoading();
//     // setState(() {
//     //   _lineQuantityController.text = "1";
//     //   _linePriceSubtotalController.text = "0";
//     //   _productSelection = "Select Product";
//     // });
//     if (Platform.isAndroid) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext ctxt) {
//           return AlertDialog(
//             title: Text(
//               "D2C Info",
//               style: TextStyle(
//                 fontFamily: "Montserrat",
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             content:
//                 StatefulBuilder(// You need this, notice the parameters below:
//                     builder: (BuildContext context, StateSetter setState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Container(
//                       margin: EdgeInsets.only(bottom: 15),
//                       // width: _width * 0.89,
//                       decoration: customDecoration(),
//                       child: DateTimeField(
//                         format: _timeFormat,
//                         controller: _startTimeController,
//                         decoration: InputDecoration(
//                           hintText: "Start Time",
//                           border: InputBorder.none,
//                           hintStyle: TextStyle(color: Colors.grey),
//                           prefixIcon: Icon(
//                             Icons.access_time_outlined,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         onShowPicker: (context, currentValue) async {
//                           final time = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.fromDateTime(
//                                 currentValue ?? DateTime.now()),
//                           );
//                           return DateTimeField.convert(time);
//                         },
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(bottom: 15),
//                       // width: _width * 0.89,
//                       decoration: customDecoration(),
//                       child: DateTimeField(
//                         format: _timeFormat,
//                         controller: _endTimeController,
//                         decoration: InputDecoration(
//                           hintText: "End Time",
//                           border: InputBorder.none,
//                           hintStyle: TextStyle(color: Colors.grey),
//                           prefixIcon: Icon(
//                             Icons.access_time_outlined,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         onShowPicker: (context, currentValue) async {
//                           final time = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.fromDateTime(
//                                 currentValue ?? DateTime.now()),
//                           );
//                           return DateTimeField.convert(time);
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Container(
//                         margin: EdgeInsets.only(bottom: 15),
//                         width: double.infinity,
//                         decoration: customDecoration(),
//                         child: TextFormField(
//                           controller: _femaleAttendeesController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             hintText: "Female Attendees",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                             prefixIcon: Icon(
//                               Icons.calculate,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                           onChanged: (value) {
//                             // if (value != "" && value != null) {
//                             //   double total =
//                             //       double.tryParse(value) * _productPrice;
//                             //   _linePriceSubtotalController.text =
//                             //       total.toString();
//                             // } else {
//                             //   _linePriceSubtotalController.text = "0";
//                             // }
//                           },
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Container(
//                         margin: EdgeInsets.only(bottom: 15),
//                         width: double.infinity,
//                         decoration: customDecoration(),
//                         child: TextFormField(
//                           controller: _maleAttendeesController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             hintText: "Male Attendees",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                             prefixIcon: Icon(
//                               Icons.calculate,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                           onChanged: (value) {},
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Container(
//                         margin: EdgeInsets.only(bottom: 15),
//                         width: double.infinity,
//                         decoration: customDecoration(),
//                         child: TextFormField(
//                           controller: _lateAttendeesController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             hintText: "Late Attendees",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                             prefixIcon: Icon(
//                               Icons.calculate,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                           onChanged: (value) {},
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Container(
//                         margin: EdgeInsets.only(bottom: 15),
//                         width: double.infinity,
//                         decoration: customDecoration(),
//                         child: TextFormField(
//                           controller: _totalAttendeesController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             hintText: "Total Attendees",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                             prefixIcon: Icon(
//                               Icons.calculate,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                           onChanged: (value) {},
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Container(
//                         margin: EdgeInsets.only(bottom: 15),
//                         width: double.infinity,
//                         decoration: customDecoration(),
//                         child: TextFormField(
//                           controller: _collectionOfficerController,
//                           keyboardType: TextInputType.text,
//                           decoration: InputDecoration(
//                             hintText: "Collection Officer",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                             prefixIcon: Icon(
//                               Icons.calculate,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                           onChanged: (value) {},
//                         ),
//                       ),
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "Post D2C",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: post_d2c,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           post_d2c = !post_d2c;
//                         });
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "Leader Attended",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: leader_attended,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           leader_attended = !leader_attended;
//                         });
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "LC Stayed",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: lc_stayed,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           lc_stayed = !lc_stayed;
//                         });
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "Leader had Filter",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: presentation_filter,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           presentation_filter = !presentation_filter;
//                         });
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "Money Sent",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: money_sent,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           money_sent = !money_sent;
//                         });
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "Additional D2C",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: additional_d2c,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           additional_d2c = !additional_d2c;
//                         });
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: new Text(
//                         "Savings Group",
//                         style: TextStyle(color: Colors.black, fontSize: 12),
//                       ),
//                       value: is_this_a_savings_group,
//                       activeColor: Theme.of(context).primaryColor,
//                       checkColor: Colors.white,
//                       onChanged: (bool values) {
//                         setState(() {
//                           is_this_a_savings_group = !is_this_a_savings_group;
//                         });
//                       },
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Container(
//                         margin: EdgeInsets.only(bottom: 15),
//                         width: double.infinity,
//                         decoration: customDecoration(),
//                         child: TextFormField(
//                           controller: _groupsController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             hintText: "No. groups",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                             prefixIcon: Icon(
//                               Icons.calculate,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                           onChanged: (value) {},
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _maleAttendeesController.clear();
//                     _femaleAttendeesController.clear();
//                     _lateAttendeesController.clear();
//                     _totalAttendeesController.clear();
//                     _collectionOfficerController.clear();
//                     _groupsController.clear();
//                     _startTimeController.clear();
//                     _endTimeController.clear();
//                     // post_d2c = false;
//                     // leader_attended = false;
//                     // lc_stayed = false;
//                     // presentation_filter = false;
//                     // additional_d2c = false;
//                     // money_sent = false;
//                     // when_group_meets = false;
//                     // is_this_a_savings_group = false;
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   "Cancel",
//                   style: TextStyle(
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   "Proceed",
//                   style: TextStyle(
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     }
//     if (Platform.isIOS) {
//       showCupertinoDialog(
//         context: context,
//         builder: (BuildContext ctxt) {
//           return CupertinoAlertDialog(
//             title: Text(
//               "D2C Info",
//               style: TextStyle(
//                 fontFamily: "Montserrat",
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             content:
//                 StatefulBuilder(// You need this, notice the parameters below:
//                     builder: (BuildContext context, StateSetter setState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [],
//                 ),
//               );
//             }),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   "Cancel",
//                   style: TextStyle(
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   "Proceed",
//                   style: TextStyle(
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   _savePatient(accountName, district, patient_age, patient_location, email,
//       phone, qbcustomerid, spouts_account_type) async {
//     SharedPreferences preference = await SharedPreferences.getInstance();

//     showDialog(
//       context: context, // <<----
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         dialogContext = context;
//         return AlertDialog(
//           title: Text("Please wait"),
//           content: new Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               new CircularProgressIndicator(),
//               new SizedBox(
//                 width: 10,
//               ),
//               new Text("Processing ....."),
//             ],
//           ),
//         );
//       },
//     );
//     isConnected().then((isInternet) {
//       if (isInternet) {
//         showLoading();
//         odoo.create(Strings.res_partner, {
//           "name": accountName,
//           "account_name": accountName,
//           "region": region,
//           "spouts_account_type": spouts_account_type,
//           "district": district,
//           "parish": _parishId,
//           "subcounty": _subCountyId,
//           "user_id": _userId,
//           "village_name": _villageId,
//           "email": email,
//           "phone": phone,
//           "qb_cust": qbcustomerid,
//           "post_d2c": post_d2c,
//           "leader_attended": leader_attended,
//           "lc_stayed": lc_stayed,
//           "presentation_filter": presentation_filter,
//           "additional_d2c": additional_d2c,
//           "money_sent": money_sent,
//           "is_this_a_savings_group": is_this_a_savings_group,
//           // "start_time": _startTimeController.text + ":00",
//           // "time_end": _endTimeController.text + ":00",
//           "no_of_groups": _groupsController.text,
//           "female_att": _femaleAttendeesController.text,
//           "male_att": _maleAttendeesController.text,
//           "late_att": _lateAttendeesController.text,
//           "total_att": _totalAttendeesController.text
//         }).then(
//           (OdooResponse res) async {
//             if (!res.hasError()) {
//               setState(() {
//                 _registerPending = false;
//               });
//               Navigator.pop(dialogContext);
//               showMessage("Success", "Customer registered successfully!");
//               await _getPartners();
//             } else {
//               setState(() {
//                 _registerPending = false;
//               });
//               print(res.getError());
//               Navigator.pop(dialogContext);
//               showMessage("Warning", res.getErrorMessage());
//             }
//           },
//         );
//       } else {
//         if (preference.getString("offlinecustomersadded") != null &&
//             preference.getString("offlinecustomersadded") != "") {
//           print("ADDING SUBSEQUENT OFFLINE CUSTOMER");
//           List _partners = [];
//           String customersString =
//               preference.getString("offlinecustomersadded");
//           // print("THE OFFLINE CUSTOMERS STRING " +
//           //     preference.getString("offlinecustomersadded"));
//           var cutomerlist = jsonDecode(customersString);
//           // print(
//           //     "THE OFFLINE CUSTOMERS DECODED OBJECT " + cutomerlist.toString());
//           setState(() {
//             for (var i in cutomerlist) {
//               _partners.add(
//                 {
//                   "email": i["email"],
//                   "name": i["name"],
//                   "phone": i["phone"],
//                   "account_name": i["account_name"],
//                   "region": i["region"],
//                   "district": i["district"],
//                   "parish": i["parish"],
//                   "subCounty": i["subCounty"],
//                   "user_id": i["user_id"],
//                   "qb_cust": i["qb_cust"],
//                 },
//               );
//             }
//             _partners.add(
//               {
//                 "name": accountName,
//                 "account_name": accountName,
//                 "region": region.toString(),
//                 "district": district.toString(),
//                 "parish": parish.toString(),
//                 "subCounty": subCounty.toString(),
//                 "user_id": _userId,
//                 // "village": "",
//                 "email": email,
//                 "phone": phone,
//                 "qb_cust": int.tryParse(qbcustomerid)
//               },
//             );
//           });
//           var offlinecustomersadded = jsonEncode(_partners);
//           // print("THE NEW OFFLINE ADDED CUSTOMERS OBJECT IS " +
//           //     offlinecustomersadded);
//           preference.setString("offlinecustomersadded", offlinecustomersadded);
//           if (preference.getString("offlinecustomers") == null ||
//               preference.getString("offlinecustomers") == "") {
//             preference.setString("offlinecustomers", offlinecustomersadded);
//           } else {
//             String customersString = preference.getString("offlinecustomers");
//             // print(preference.getString("offlinecustomers"));
//             var cutomerlist = json.decode(customersString);
//             List _offlinePartners = [];
//             setState(() {
//               for (var i in cutomerlist) {
//                 _offlinePartners.add(
//                   {
//                     "email": i["email"],
//                     "name": i["name"],
//                     "phone": i["phone"],
//                     "account_name": i["account_name"],
//                     "region": i["region"],
//                     "district": i["district"],
//                     "parish": i["parish"],
//                     "subCounty": i["subCounty"],
//                     "user_id": i["user_id"],
//                     "qb_cust": i["qb_cust"],
//                   },
//                 );
//               }
//               _offlinePartners.add(
//                 {
//                   "name": accountName,
//                   "account_name": accountName,
//                   "region": region.toString(),
//                   "district": district.toString(),
//                   "parish": parish.toString(),
//                   "subCounty": subCounty.toString(),
//                   "user_id": _userId,
//                   // "village": "",
//                   "email": email,
//                   "phone": phone,
//                   "qb_cust": int.tryParse(qbcustomerid)
//                 },
//               );
//             });
//             var offlinecustomersupdate = jsonEncode(_offlinePartners);
//             // print("THE NEW OFFLINE CUSTOMERS OBJECT IS " +
//             //     offlinecustomersupdate);
//             preference.setString("offlinecustomers", offlinecustomersupdate);
//           }
//           _showSuccessMessage(
//               "Customer has been saved to your phone.\nPlease connect to the internet to sync.");
//         } else {
//           print("ADDING FIRST OFFLINE CUSTOMER");
//           List _partners = [];
//           _partners.add(
//             {
//               "name": accountName,
//               "account_name": accountName,
//               "region": region.toString(),
//               "district": district.toString(),
//               "parish": parish.toString(),
//               "subCounty": subCounty.toString(),
//               "user_id": _userId,
//               // "village": "",
//               "email": email,
//               "phone": phone,
//               "qb_cust": int.tryParse(qbcustomerid)
//             },
//           );
//           var offlinecustomersadded = jsonEncode(_partners);
//           preference.setString("offlinecustomersadded", offlinecustomersadded);
//           if (preference.getString("offlinecustomers") == null ||
//               preference.getString("offlinecustomers") == "") {
//             preference.setString("offlinecustomers", offlinecustomersadded);
//           } else {
//             String customersString = preference.getString("offlinecustomers");
//             print(preference.getString("offlinecustomers"));
//             var cutomerlist = json.decode(customersString);
//             List _offlinePartners = [];
//             setState(() {
//               for (var i in cutomerlist) {
//                 _offlinePartners.add(
//                   {
//                     'email': i["email"],
//                     'name': i["name"],
//                     'phone': i["phone"],
//                     'account_name': i["account_name"],
//                     'region': i["region"],
//                     'district': i["district"],
//                     'parish': i["parish"],
//                     'subCounty': i["subCounty"],
//                     'user_id': i["user_id"],
//                     'qb_cust': i["qb_cust"],
//                   },
//                 );
//               }
//               _offlinePartners.add(
//                 {
//                   "name": accountName,
//                   "account_name": accountName,
//                   "region": region.toString(),
//                   "district": district.toString(),
//                   "parish": parish.toString(),
//                   "subCounty": subCounty.toString(),
//                   "user_id": _userId,
//                   // "village": "",
//                   "email": email,
//                   "phone": phone,
//                   "qb_cust": int.tryParse(qbcustomerid)
//                 },
//               );
//             });
//             var offlinecustomersaddedupdate = jsonEncode(_offlinePartners);
//             preference.setString(
//                 "offlinecustomers", offlinecustomersaddedupdate);
//           }
//           _showSuccessMessage(
//               "Customer has been saved to your phone.\nPlease connect to the internet to sync.");
//           // Navigator.pop(dialogContext);
//         }
//       }
//     });
//   }

//   //GET PARTNERS/CUSTOMERS
//   _getPartners() async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     isConnected().then((isInternet) {
//       if (isInternet) {
//         showLoading();
//         odoo.searchRead(Strings.res_partner, [
//           // ['user_id', "ilike", '$userfullname'],
//           ['company_type', "=", 'company']
//         ], [
//           'email',
//           'name',
//           'phone'
//         ]).then(
//           (OdooResponse res) {
//             if (!res.hasError()) {
//               setState(() {
//                 hideLoading();
//                 String session = getSession();
//                 session = session.split(",")[0].split(";")[0];
//                 for (var i in res.getRecords()) {
//                   if (i["name"].toString().length > 1) {
//                     _partners.add(
//                       new Partner(
//                         id: i["id"],
//                         email: i["email"] is! bool ? i["email"] : "N/A",
//                         name: i["name"].toString(),
//                         phone: i["phone"] is! bool ? i["phone"] : "N/A",
//                         imageUrl: getURL() +
//                             "/web/image?model=res.partner&field=image&" +
//                             session +
//                             "&id=" +
//                             i["id"].toString(),
//                       ),
//                     );
//                   }
//                 }
//               });
//               var customerlist = jsonEncode(res.getRecords());
//               preference.setString("offlinecustomers", customerlist);
//               preference.setString(
//                   "offlinecustomerslastupdated", DateTime.now().toString());
//               print("Updated offline customer repository at " +
//                   DateTime.now().toString());
//             } else {
//               print(res.getError());
//               showMessage("Warning", res.getErrorMessage());
//             }
//           },
//         );
//       }
//     });
//     pushReplacement(Accounts());
//   }

//   _showSuccessMessage(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext ctxt) {
//         return AlertDialog(
//           title: Text(
//             "Warning: Offline",
//             style: TextStyle(
//               fontFamily: "Montserrat",
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           content: Text(
//             message,
//             style: TextStyle(
//               fontFamily: "Montserrat",
//               fontSize: 18,
//               color: Colors.black,
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 pushReplacement(Accounts());
//                 // Navigator.of(context).pop();
//               },
//               child: Text(
//                 "Ok",
//                 style: TextStyle(
//                   fontFamily: "Montserrat",
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   _showLogoutMessage(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext ctxt) {
//         return AlertDialog(
//           title: Text(
//             "Warning",
//             style: TextStyle(
//               fontFamily: "Montserrat",
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           content: Text(
//             message,
//             style: TextStyle(
//               fontFamily: "Montserrat",
//               fontSize: 18,
//               color: Colors.black,
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 pushReplacement(Partners());
//               },
//               child: Text(
//                 "Logout",
//                 style: TextStyle(
//                   fontFamily: "Montserrat",
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   _clearPrefs() async {
//     odoo.destroy();
//     preferences.remove(Constants.USER_PREF);
//     preferences.remove(Constants.SESSION);
//     pushAndRemoveUntil(Login());
//   }

//   BoxDecoration customDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         BoxShadow(
//           offset: Offset(0, 2),
//           color: Colors.grey[300],
//           blurRadius: 5,
//         )
//       ],
//     );
//   }
// }
