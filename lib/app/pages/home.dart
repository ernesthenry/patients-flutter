// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// // import 'package:patients/app/data/pojo/delivery.dart';
// // import 'package:patients/app/data/pojo/district.dart';
// // import 'package:patients/app/data/pojo/employees.dart';
// // import 'package:patients/app/data/pojo/employeestock.dart';
// // import 'package:patients/app/data/pojo/invoicelines.dart';
// // import 'package:patients/app/data/pojo/invoices.dart';
// // import 'package:patients/app/data/pojo/parish.dart';
// import 'package:patients/app/data/pojo/patients.dart';
// // import 'package:patients/app/data/pojo/pricelistitems.dart';
// // import 'package:patients/app/data/pojo/pricelists.dart';
// // import 'package:patients/app/data/pojo/region.dart';
// // import 'package:patients/app/data/pojo/requisitionlines.dart';
// // import 'package:patients/app/data/pojo/requisitions.dart';
// // import 'package:patients/app/data/pojo/stocklocations.dart';
// // import 'package:patients/app/data/pojo/stockmovelines.dart';
// // import 'package:patients/app/data/pojo/stockmoves.dart';
// // import 'package:patients/app/data/pojo/stockquant.dart';
// // import 'package:patients/app/data/pojo/subcounty.dart';
// // import 'package:patients/app/data/pojo/village.dart';
// import 'package:patients/app/data/services/odoo_response.dart';
// // import 'package:patients/app/pages/accounts.dart';
// // import 'package:patients/app/pages/addinvoice.dart';
// import 'package:patients/app/pages/addpatient.dart';
// // import 'package:patients/app/pages/draftinvoices.dart';
// // import 'package:patients/app/pages/invoices.dart';
// import 'package:patients/app/pages/patient_details.dart';
// import 'package:patients/app/pages/patients.dart';
// // import 'package:patients/app/pages/shiptocustomer.dart';
// // import 'package:patients/app/pages/shiptosales_old.dart';
// // import 'package:patients/app/pages/stocktaking.dart';
// import 'package:patients/app/utility/constant.dart';
// import 'package:patients/app/utility/strings.dart';
// import 'package:patients/base.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'login.dart';
// // import 'profile.dart';
// // import 'settings.dart';
// import 'package:intl/intl.dart';

// // import 'shiptosales.dart';
// // import 'viewemployeestock.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends Base<Home> {
//   //Odoo _odoo;
//   String userfullname = "", email = "";
//   // var _imageUrl;
//   int _userId = 0;
//   String _firstName = "Home";
//   // List<EmployeeStock> _employeeStock = [];
//   // List<EmployeeStock> _allEmployeeStock = [];
//   // List<StockPicking> _stockPickings = [];
//   // List<Invoice> _invoices = [];
//   List<Patient> _patients = [];
//   // List<Partner> _contacts = [];
//   // List<StockMoves> _stockMoves = [];
//   // List<StockMoveLines> _stockMoveLines = [];
//   // List<StockQuant> _employeeStockQuant = [];
//   // List<Employees> _salesOfficers = [];
//   // List<PriceList> _priceLists = [];
//   // List<PriceListItem> _priceListItems = [];
//   // List<InvoiceLine> _invoiceLines = [];
//   // List<Region> _regions = [];
//   // List<District> _districts = [];
//   // List<SubCounty> _subCountiess = [];
//   // List<Parish> _parishes = [];
//   // List<Village> _villages = [];
//   // List<Requisition> _requisitions = [];
//   // List<RequisitionLine> _requisitionLines = [];
//   // List<StockLocation> _employeeStockLocations = [];
//   // List<Employees> _employees = [];
//   String fullname = "";
//   // LoaderOverlay loaderOverlay;
//   final value = new NumberFormat("#,##0", "en_US");
//   String _patientId = "";
//   String _displaypatientId = "";
//   String _currentMonth = "";
//   // int _customerLocationId;
//   // String _customerLocationSelection = '';
//   // bool _isTeamLeader = false;
//   List _employeeLocationId = [];
//   bool _isDialogShowing = false;

//   String returnMonth(DateTime date) {
//     return new DateFormat.MMMM().format(date);
//   }

//   _clearPrefs() async {
//     odoo.destroy();
//     preferences.remove(Constants.USER_PREF);
//     preferences.remove(Constants.SESSION);
//     pushAndRemoveUntil(Login());
//   }

//   _refreshData() async {
//     isConnected().then((isInternet) async {
//       if (isInternet) {
//         _isDialogShowing = true;
//         showDialog(
//           context: context, // <<----
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Please wait"),
//               content: new Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   new CircularProgressIndicator(),
//                   new SizedBox(
//                     width: 10,
//                   ),
//                   new Text("Synchronizing data ....."),
//                 ],
//               ),
//             );
//           },
//         );
//         getOdooInstance().then((odoo) {
//           setState(() {
//             _userId = getUID();
//             _firstName = getUserFullName();
//           });
//           print("the user id is " + _userId.toString());
//           print("the fullname is " + _firstName.toString());
//         });
//         await _getPatientData(_userId);
//         // await _getSalesOfficers();
//         // await _getEmployees();
//         // await _getCustomerLocation();
//         // await _getRequisitions();
//         // await _getRequisitionLines();
//         // await _getAllEmployeeStock();
//         // await _getContacts();
//         await _getPatients();
//         // await _getDraftInvoices();
//         // await _getInvoices();
//         // await _getInvoiceLines();
//         // await _getStockPickings();
//         // await _getStockMoves();
//         // await _getStockMoveLines();
//         await new Future.delayed(new Duration(seconds: 6));
//         Navigator.of(context).pop();
//       }
//     });
//   }

//   // //GET PATIENT NAME AND ID
//   _getPatientData(userid) async {
//     var patientId;
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     //GET DASHBOARD TABLE BEFORE GETTING EMPLOYEE DATA
//     if (preference.getString("offlineemployeestock") != null) {
//       print(preference.getString("offlineemployeestock"));
//       var patientlist = json.decode(preference.getString("offlineemployeestock"));
//       print("adding locally stored stock before update from odoo");
//       setState(() {
//         for (var i in patientlist) {
//           _patients.add(
//             new Patient(
//               id: i["id"],
//               patient_name: i["patient_name"],
//               patient_id: i["categ_id"] is! bool ? i["categ_id"] : [],
//               product_id: i["patient_id"] is! bool ? i["patient_id"] : [],
//               quantity_in: i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
//               patient_location:
//                   i["patient_location"] is! bool ? i["patient_location"] : 0.0,
//               quantity_adjust:
//                   i["quantity_adjust"] is! bool ? i["quantity_adjust"] : 0.0,
//               quantity_begin:
//                   i["quantity_begin"] is! bool ? i["quantity_begin"] : 0.0,
//               quantity_finish:
//                   i["quantity_finish"] is! bool ? i["quantity_finish"] : 0.0,
//               amount_adjust:
//                   i["amount_adjust"] is! bool ? i["amount_adjust"] : 0.0,
//               amount_begin:
//                   i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
//               amount_finish:
//                   i["amount_finish"] is! bool ? i["amount_finish"] : 0.0,
//               amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
//               amount_out: i["amount_out"] is! bool ? i["amount_out"] : 0.0,
//             ),
//           );
//         }
//       });
//     }

//     isConnected().then((isInternet) {
//       if (isInternet) {
//         odoo.searchRead(Strings.res_partner, [
//           ['user_id', "=", _userId]
//         ], [
//           'id',
//           'user_id',
//           'patient-name',
//           'date_of_birth',
//           'age',
//           'patient_location',
//           'insured',
//           'patient_history',
//         ]).then(
//           (OdooResponse res) {
//             if (!res.hasError()) {
//               setState(() {
//                 hideLoading();
//                 String session = getSession();
//                 session = session.split(",")[0].split(";")[0];
//                 final result = res.getResult()['records'][0];

//                 _patientId = result["company_user_code"] is! bool
//                     ? result["company_user_code"]
//                     : "000";
//                 // _isTeamLeader = result["team_leader"];
//                 // _employeeLocationId =
//                 //     result["location_id"] is! bool ? result["location_id"] : [];
//                 _displaypatientId = _patientId?.substring(
//                     (_patientId.length - 3).clamp(0, _patientId.length));

//                 var patientdata = jsonEncode(result);
//                 preference.setString("offlineemployeedata", patientdata);
//                 preference.setString("offlineemployeedatalastupdated",
//                     DateTime.now().toString());
//                 print("Updated offline offlineemployee data at " +
//                     DateTime.now().toString());
//               });
//               if (_patientId != null) {
//                 _getPatients();
//                 // _getEmployeeStock()
//                 // _getEmployeeBarCodeStock();
//                 // _getEmployeeStockLocations();
//                 // _getStockPickings();
//                 // _getRequisitions();
//               }
//               // preference.setString("employeeid", _patientId);
//               // preference.setString("displayemployeeid", _displaypatientId);
//             } else {
//               print(res.getError());
//               showMessage("Warning", res.getErrorMessage());
//             }
//           },
//         );
//       } else {
//         print("Failed to update patients data. Device Offline.");
//       }
//     });
//   }

//   //GET EMPLOYEES WITH STOCK LOCATIONS
//   // _getEmployees() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       odoo.searchRead(Strings.hr_employee, [
//   //         ['location_id', "!=", false]
//   //       ], [
//   //         'id',
//   //         'user_id',
//   //         'name',
//   //         'job_title',
//   //         'company_user_code',
//   //         'location_src_id',
//   //         'location_id',
//   //         'team_leader',
//   //         'inventory_report'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _employees.add(
//   //                   new Employees(
//   //                     id: i["id"],
//   //                     name: i["name"],
//   //                     job_title: i["job_title"] is! bool ? i["job_title"] : "",
//   //                     location_id:
//   //                         i["location_id"] is! bool ? i["location_id"] : [],
//   //                     mobile_phone:
//   //                         i["mobile_phone"] is! bool ? i["mobile_phone"] : "",
//   //                     inventory_report: i["inventory_report"] is! bool
//   //                         ? i["inventory_report"]
//   //                         : [],
//   //                   ),
//   //                 );
//   //               }

//   //               var employeedata = jsonEncode(res.getRecords());
//   //               preference.setString("offlineemployees", employeedata);
//   //               preference.setString(
//   //                   "offlineemployeeslastupdated", DateTime.now().toString());
//   //               print("Updated offline offlineemployees repository at " +
//   //                   DateTime.now().toString());
//   //             });
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print("Failed to update employee data. Device Offline.");
//   //     }
//   //   });
//   // }

//   //GET EMPLOYEE BARCODE STOCK
//   // _getEmployeeBarCodeStock() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.stock_quant, [
//   //         ['location_id', 'ilike', _employeeLocationId[1]],
//   //         ['lot_id', '!=', false]
//   //       ], [
//   //         'id',
//   //         'display_name',
//   //         'lot_id',
//   //         'location_id',
//   //         'owner_id',
//   //         'product_id',
//   //         'product_uom_id',
//   //         'on_hand',
//   //         'package_id',
//   //         'quantity',
//   //         'reserved_quantity',
//   //         'value'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _employeeStockQuant.add(
//   //                   new StockQuant(
//   //                     id: i["id"],
//   //                     display_name: i["display_name"],
//   //                     lot_id: i["lot_id"] is! bool ? i["lot_id"] : [],
//   //                     location_id:
//   //                         i["location_id"] is! bool ? i["location_id"] : [],
//   //                     owner_id: i["owner_id"] is! bool ? i["owner_id"] : [],
//   //                     package_id:
//   //                         i["package_id"] is! bool ? i["package_id"] : [],
//   //                     product_id:
//   //                         i["product_id"] is! bool ? i["product_id"] : [],
//   //                     quantity: i["quantity"] is! bool ? i["quantity"] : 0.0,
//   //                     value: i["value"] is! bool ? i["value"] : 0.0,
//   //                     reserved_quantity: i["reserved_quantity"] is! bool
//   //                         ? i["reserved_quantity"]
//   //                         : 0.0,
//   //                     product_uom_id: i["product_uom_id"] is! bool
//   //                         ? i["product_uom_id"]
//   //                         : [],
//   //                     on_hand: i["on_hand"],
//   //                   ),
//   //                 );
//   //               }
//   //               var stocklist = jsonEncode(res.getRecords());
//   //               preference.setString("offlineemployeebarcodestock", stocklist);
//   //               preference.setString("offlineemployeebarcodestocklastupdated",
//   //                   DateTime.now().toString());
//   //               print("Updated offline employee bar code stock repository at " +
//   //                   DateTime.now().toString());
//   //             });
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     }
//   //   });
//   // }

//   //GET EMPLOYEE STOCK
//   // _getEmployeeStock() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.hr_employee_stock, [
//   //         ['report_id', 'ilike', '$_firstName']
//   //       ], [
//   //         'id',
//   //         'report_id',
//   //         'product_id',
//   //         'categ_id',
//   //         'quantity_in',
//   //         'quantity_out',
//   //         'quantity_adjust',
//   //         'quantity_begin',
//   //         'quantity_finish',
//   //         'amount_begin',
//   //         'amount_adjust',
//   //         'amount_finish',
//   //         'amount_in',
//   //         'amount_out',
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               _employeeStock = [];
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _employeeStock.add(
//   //                   new EmployeeStock(
//   //                     id: i["id"],
//   //                     report_id: i["report_id"],
//   //                     categ_id: i["categ_id"] is! bool ? i["categ_id"] : [],
//   //                     product_id:
//   //                         i["product_id"] is! bool ? i["product_id"] : [],
//   //                     quantity_in:
//   //                         i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
//   //                     quantity_out:
//   //                         i["quantity_out"] is! bool ? i["quantity_out"] : 0.0,
//   //                     quantity_adjust: i["quantity_adjust"] is! bool
//   //                         ? i["quantity_adjust"]
//   //                         : 0.0,
//   //                     quantity_begin: i["quantity_begin"] is! bool
//   //                         ? i["quantity_begin"]
//   //                         : 0.0,
//   //                     quantity_finish: i["quantity_finish"] is! bool
//   //                         ? i["quantity_finish"]
//   //                         : 0.0,
//   //                     amount_adjust: i["amount_adjust"] is! bool
//   //                         ? i["amount_adjust"]
//   //                         : 0.0,
//   //                     amount_begin:
//   //                         i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
//   //                     amount_finish: i["amount_finish"] is! bool
//   //                         ? i["amount_finish"]
//   //                         : 0.0,
//   //                     amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
//   //                     amount_out:
//   //                         i["amount_out"] is! bool ? i["amount_out"] : 0.0,
//   //                   ),
//   //                 );
//   //               }
//   //               var stocklist = jsonEncode(res.getRecords());
//   //               preference.setString("offlineemployeestock", stocklist);
//   //               preference.setString("offlineemployeestocklastupdated",
//   //                   DateTime.now().toString());
//   //               print("Updated offline employee stock repository at " +
//   //                   DateTime.now().toString());
//   //             });
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else if (preference.getString("offlineemployeestock") != null) {
//   //       print(preference.getString("offlineemployeestock"));
//   //       var stocklist =
//   //           json.decode(preference.getString("offlineemployeestock"));
//   //       setState(() {
//   //         _employeeStock = [];
//   //         for (var i in stocklist) {
//   //           _employeeStock.add(
//   //             new EmployeeStock(
//   //               id: i["id"],
//   //               report_id: i["report_id"],
//   //               categ_id: i["categ_id"] is! bool ? i["categ_id"] : [],
//   //               product_id: i["product_id"] is! bool ? i["product_id"] : [],
//   //               quantity_in: i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
//   //               quantity_out:
//   //                   i["quantity_out"] is! bool ? i["quantity_out"] : 0.0,
//   //               quantity_adjust:
//   //                   i["quantity_adjust"] is! bool ? i["quantity_adjust"] : 0.0,
//   //               quantity_begin:
//   //                   i["quantity_begin"] is! bool ? i["quantity_begin"] : 0.0,
//   //               quantity_finish:
//   //                   i["quantity_finish"] is! bool ? i["quantity_finish"] : 0.0,
//   //               amount_adjust:
//   //                   i["amount_adjust"] is! bool ? i["amount_adjust"] : 0.0,
//   //               amount_begin:
//   //                   i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
//   //               amount_finish:
//   //                   i["amount_finish"] is! bool ? i["amount_finish"] : 0.0,
//   //               amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
//   //               amount_out: i["amount_out"] is! bool ? i["amount_out"] : 0.0,
//   //             ),
//   //           );
//   //         }
//   //       });
//   //     }
//   //   });
//   // }


//   //GET EMPLOYEE STOCK LOCATIONS
//   // _getEmployeeStockLocations() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       //GET STOCK LOCATIONS
//   //       odoo.searchRead(Strings.stock_location, [
//   //         ['usage', '=', 'internal'],
//   //         ['location_id', '!=', false],
//   //       ], [
//   //         'id',
//   //         'display_name',
//   //         'usage',
//   //         'location_id'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _employeeStockLocations.add(
//   //                   new StockLocation(
//   //                     id: i["id"],
//   //                     display_name: i["display_name"].toString(),
//   //                     usage: i["usage"] is! bool ? i["usage"] : "internal",
//   //                     location_id:
//   //                         i["location_id"] is! bool ? i["location_id"] : [],
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var stocklocationslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinestocklocations", stocklocationslist);
//   //             preference.setString("offlinestocklocationslastupdated",
//   //                 DateTime.now().toString());
//   //             print("Updated offline stock locations repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     }
//   //   });
//   // }

//   //GET STOCK DATA FOR ALL EMPLOYEES UNDER RESPECTIVE LCOATIONS
//   // _getAllEmployeeStock() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.hr_employee_stock, [
//   //         ['report_id', '!=', false]
//   //       ], [
//   //         'id',
//   //         'report_id',
//   //         'product_id',
//   //         'categ_id',
//   //         'quantity_in',
//   //         'quantity_out',
//   //         'quantity_adjust',
//   //         'quantity_begin',
//   //         'quantity_finish',
//   //         'amount_begin',
//   //         'amount_adjust',
//   //         'amount_finish',
//   //         'amount_in',
//   //         'amount_out'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               _allEmployeeStock = [];
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _allEmployeeStock.add(
//   //                   new EmployeeStock(
//   //                     id: i["id"],
//   //                     report_id: i["report_id"] is! bool ? i["report_id"] : [],
//   //                     categ_id: i["categ_id"] is! bool ? i["categ_id"] : [],
//   //                     product_id:
//   //                         i["product_id"] is! bool ? i["product_id"] : [],
//   //                     quantity_in:
//   //                         i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
//   //                     quantity_out:
//   //                         i["quantity_out"] is! bool ? i["quantity_out"] : 0.0,
//   //                     quantity_adjust: i["quantity_adjust"] is! bool
//   //                         ? i["quantity_adjust"]
//   //                         : 0.0,
//   //                     quantity_begin: i["quantity_begin"] is! bool
//   //                         ? i["quantity_begin"]
//   //                         : 0.0,
//   //                     quantity_finish: i["quantity_finish"] is! bool
//   //                         ? i["quantity_finish"]
//   //                         : 0.0,
//   //                     amount_adjust: i["amount_adjust"] is! bool
//   //                         ? i["amount_adjust"]
//   //                         : 0.0,
//   //                     amount_begin:
//   //                         i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
//   //                     amount_finish: i["amount_finish"] is! bool
//   //                         ? i["amount_finish"]
//   //                         : 0.0,
//   //                     amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
//   //                     amount_out:
//   //                         i["amount_out"] is! bool ? i["amount_out"] : 0.0,
//   //                   ),
//   //                 );
//   //               }
//   //               var stocklist = jsonEncode(res.getRecords());
//   //               preference.setString("offlineallemployeestock", stocklist);
//   //               preference.setString("offlineallemployeestocklastupdated",
//   //                   DateTime.now().toString());
//   //               print("Updated offline all employee stock repository at " +
//   //                   DateTime.now().toString());
//   //             });
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else if (preference.getString("offlineallemployeestock") != null) {
//   //       print(preference.getString("offlineallemployeestock"));
//   //       var stocklist =
//   //           json.decode(preference.getString("offlineallemployeestock"));
//   //       setState(() {
//   //         _allEmployeeStock = [];
//   //         for (var i in stocklist) {
//   //           _allEmployeeStock.add(
//   //             new EmployeeStock(
//   //               id: i["id"],
//   //               report_id: i["report_id"],
//   //               categ_id: i["categ_id"] is! bool ? i["categ_id"] : [],
//   //               product_id: i["product_id"] is! bool ? i["product_id"] : [],
//   //               quantity_in: i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
//   //               quantity_out:
//   //                   i["quantity_out"] is! bool ? i["quantity_out"] : 0.0,
//   //               quantity_adjust:
//   //                   i["quantity_adjust"] is! bool ? i["quantity_adjust"] : 0.0,
//   //               quantity_begin:
//   //                   i["quantity_begin"] is! bool ? i["quantity_begin"] : 0.0,
//   //               quantity_finish:
//   //                   i["quantity_finish"] is! bool ? i["quantity_finish"] : 0.0,
//   //               amount_adjust:
//   //                   i["amount_adjust"] is! bool ? i["amount_adjust"] : 0.0,
//   //               amount_begin:
//   //                   i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
//   //               amount_finish:
//   //                   i["amount_finish"] is! bool ? i["amount_finish"] : 0.0,
//   //               amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
//   //               amount_out: i["amount_out"] is! bool ? i["amount_out"] : 0.0,
//   //             ),
//   //           );
//   //         }
//   //       });
//   //     }
//   //   });
//   // }

// //GET SALES OFFICERS
//   // _getSalesOfficers() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.hr_employee, [
//   //         ['department_id', "ilike", "Sales & Marketing / Sales Department"]
//   //       ], [
//   //         'name',
//   //         'job_title',
//   //         'work_email',
//   //         'work_phone',
//   //         'mobile_phone',
//   //         'company_user_code',
//   //         'location_id'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 if (i["name"].toString().length > 1) {
//   //                   _salesOfficers.add(
//   //                     new Employees(
//   //                       id: i["id"],
//   //                       work_email:
//   //                           i["work_email"] is! bool ? i["work_email"] : "N/A",
//   //                       name: i["name"].toString(),
//   //                       work_phone:
//   //                           i["work_phone"] is! bool ? i["work_phone"] : "N/A",
//   //                       mobile_phone: i["mobile_phone"] is! bool
//   //                           ? i["mobile_phone"]
//   //                           : "N/A",
//   //                       company_user_code: i["company_user_code"] is! bool
//   //                           ? i["company_user_code"]
//   //                           : "N/A",
//   //                       job_title:
//   //                           i["job_title"] is! bool ? i["job_title"] : "N/A",
//   //                       location_id:
//   //                           i["location_id"] is! bool ? i["location_id"] : [],
//   //                     ),
//   //                   );
//   //                 }
//   //               }
//   //             });
//   //             var salesofficerslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinesalesofficers", salesofficerslist);
//   //             preference.setString(
//   //                 "offlinesalesofficerslastupdated", DateTime.now().toString());
//   //             print("Updated offline sales officers repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     }
//   //   });
//   // }

//   //GET PATIENTS/CLIENTS
//   _getPatients() async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     isConnected().then((isInternet) {
//       if (isInternet) {
//         showLoading();
//         odoo.searchRead(Strings.res_partner, [
//           ['parent_id', "=", false],
//           ['company_type', "!=", 'person']
//         ], [
//           'name',
//           'patient_history',
//           'date_of_birth',
//           'parent_id',
//           'patient_location'
//         ]).then(
//           (OdooResponse res) {
//             if (!res.hasError()) {
//               setState(() {
//                 hideLoading();
//                 String session = getSession();
//                 session = session.split(",")[0].split(";")[0];
//                 for (var i in res.getRecords()) {
//                   if (i["name"].toString().length > 1 &&
//                       i["parent_id"] is bool) {
//                     _patients.add(
//                       new Patient(
//                         id: i["id"],
//                         date_of_birth: i["date_of_birth"] is! bool ? i["date_of_birth"] : "N/A",
//                         patient_name: i["patient_name"].toString(),
//                         age: i["age"] is! bool ? i["age"] : "N/A",
//                         parent_id:
//                             i["parent_id"] is! bool ? i["parent_id"] : [],
//                         imageUrl: getURL() +
//                             "/web/image?model=res.partner&field=image&" +
//                             session +
//                             "&patient_location=" +
//                             i["patient_location"].toString(),
//                       ),
//                     );
//                   }
//                 }
//               });
//               var patientlist = jsonEncode(res.getRecords());
//               preference.setString("offlinecustomers", patientlist);
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
//   }

//   //GET STOCK REQUISITIONS
//   // _getRequisitions() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.requisition, [
//   //         ['state', '=', 'confirm'],
//   //         ['location_src_id', 'ilike', _employeeLocationId[1].toString()]
//   //       ], [
//   //         'id',
//   //         'location_src_id',
//   //         'location_dest_id',
//   //         'picking_type_id',
//   //         'notes',
//   //         'name',
//   //         'request_date',
//   //         // 'requested_by',
//   //         'employee_id',
//   //         'product_lines',
//   //         'state'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _requisitions.add(
//   //                   new Requisition(
//   //                     id: i["id"],
//   //                     name: i['name'] is! bool ? i['name'] : "",
//   //                     requested_by:
//   //                         i["requested_by"] is! bool ? i["requested_by"] : [],
//   //                     employee_id:
//   //                         i['employee_id'] is! bool ? i['employee_id'] : [],
//   //                     request_date:
//   //                         i['request_date'] is! bool ? i['request_date'] : "",
//   //                     state: i['state'] is! bool ? i['state'] : "",
//   //                     product_lines:
//   //                         i['product_lines'] is! bool ? i['product_lines'] : [],
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var requisitionslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinerequisitions", requisitionslist);
//   //             preference.setString(
//   //                 "offlinerequisitionslastupdated", DateTime.now().toString());
//   //             print("Updated offline requisitions repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     }
//   //   });
//   // }

//   //GET REQUISITION LINES
//   // _getRequisitionLines() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       odoo.searchRead(Strings.requisition_line, [
//   //         ['product_id', "!=", false],
//   //         // ["stock_req_id", "ilike", "ST/REQ/006"],
//   //       ], [
//   //         'id',
//   //         'product_id',
//   //         'quantity',
//   //         'stock_req_id'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _requisitionLines.add(
//   //                   new RequisitionLine(
//   //                     id: i["id"],
//   //                     quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
//   //                     product_id:
//   //                         i["product_id"] is! bool ? i["product_id"] : [],
//   //                     stock_req_id:
//   //                         i["stock_req_id"] is! bool ? i["stock_req_id"] : [],
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelineslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinerequisitionlines", invoicelineslist);
//   //             preference.setString("offlinerequisitionlineslastupdated",
//   //                 DateTime.now().toString());
//   //             print("Updated offline requsition lines repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print("Failed to update offline requisition lines. Device Offline.");
//   //     }
//   //   });
//   // }

//   //GET CONTACTS
//   _getContacts() async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     isConnected().then((isInternet) {
//       if (isInternet) {
//         showLoading();
//         odoo.searchRead(Strings.res_partner, [
//           ['parent_id', "!=", false],
//           ['company_type', "=", 'person']
//         ], [
//           'email',
//           'name',
//           'phone',
//           'parent_id',
//           'company_type'
//         ]).then(
//           (OdooResponse res) {
//             if (!res.hasError()) {
//               setState(() {
//                 hideLoading();
//                 String session = getSession();
//                 session = session.split(",")[0].split(";")[0];
//                 for (var i in res.getRecords()) {
//                   if (i["name"].toString().length > 1) {
//                     _contacts.add(
//                       new Partner(
//                           id: i["id"],
//                           email: i["email"] is! bool ? i["email"] : "N/A",
//                           name: i["name"].toString(),
//                           phone: i["phone"] is! bool ? i["phone"] : "N/A",
//                           parent_id: i["parent_id"]),
//                     );
//                   }
//                 }
//               });
//               var customerlist = jsonEncode(res.getRecords());
//               preference.setString("offlinecontacts", customerlist);
//               preference.setString(
//                   "offlinecontactslastupdated", DateTime.now().toString());
//               print("Updated offline contacts repository at " +
//                   DateTime.now().toString());
//             } else {
//               print(res.getError());
//               showMessage("Warning", res.getErrorMessage());
//             }
//           },
//         );
//       }
//     });
//   }

//   //GET STOCK PICKINGS
//   // _getStockPickings() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.stock_picking, [
//   //         ['location_id', "ilike", _employeeLocationId[1]],
//   //         ["sale_id", '!=', false],
//   //         ["state", '=', 'confirmed']
//   //       ], [
//   //         'id',
//   //         'state',
//   //         'location_id',
//   //         'partner_id',
//   //         'origin',
//   //         'date_deadline',
//   //         'move_type',
//   //         'group_id',
//   //         'scheduled_date',
//   //         'move_ids_without_package',
//   //         'move_line_ids_without_package',
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _stockPickings.add(
//   //                   new StockPicking(
//   //                     id: i["id"],
//   //                     state: i["state"] is! bool ? i["state"] : "N/A",
//   //                     location_id:
//   //                         i["location_id"] is! bool ? i["location_id"] : [],
//   //                     date_deadline:
//   //                         i['date_deadline'] is! bool ? i['date_deadline'] : "",
//   //                     scheduled_date: i['scheduled_date'] is! bool
//   //                         ? i['scheduled_date']
//   //                         : "",
//   //                     move_ids_without_package:
//   //                         i['move_ids_without_package'] is! bool
//   //                             ? i['move_ids_without_package']
//   //                             : [],
//   //                     move_line_ids_without_package:
//   //                         i['move_line_ids_without_package'] is! bool
//   //                             ? i['move_line_ids_without_package']
//   //                             : [],
//   //                     origin: i['origin'] is! bool ? i['origin'] : "-",
//   //                     partner_id: i["partner_id"],
//   //                     group_id: i["group_id"] is! bool ? i["group_id"] : [],
//   //                     move_type: i['move_type'] is! bool ? i['move_type'] : "",
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinestockpickings", invoicelist);
//   //             preference.setString(
//   //                 "offlinestockpickingslastupdated", DateTime.now().toString());
//   //             print("Updated offline stock picking repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print(preference.getString("Can't update invoices. Device Offline."));
//   //     }
//   //   });
//   // }

//   //GET INVOICES
//   // _getInvoices() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   // setState(() {
//   //   //   fullname = getUserFullName();
//   //   //   print("The full name is " + fullname);
//   //   // });
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.account_move, [
//   //         ['move_type', "=", 'out_invoice'],
//   //         ['payment_state', "!=", 'not_paid'],
//   //         ['invoice_user_id', "ilike", '$_firstName']
//   //       ], [
//   //         'id',
//   //         'invoice_date',
//   //         'payment_reference',
//   //         'line_ids',
//   //         'amount_total',
//   //         'amount_residual',
//   //         'state',
//   //         'move_type',
//   //         'partner_id',
//   //         'payment_state'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _invoices.add(
//   //                   new Invoice(
//   //                       id: i["id"],
//   //                       invoice_date: i["invoice_date"] is! bool
//   //                           ? i["invoice_date"]
//   //                           : "N/A",
//   //                       payment_reference: i["payment_reference"] is! bool
//   //                           ? i["payment_reference"]
//   //                           : "N/A",
//   //                       journal_id:
//   //                           i['journal_id'] is! bool ? i['journal_id'] : "",
//   //                       currency_id:
//   //                           i['currency_id'] is! bool ? i['currency_id'] : "",
//   //                       invoice_payment_term_id:
//   //                           i['invoice_payment_term_id'] is! bool
//   //                               ? i['invoice_payment_term_id']
//   //                               : "",
//   //                       edi_state:
//   //                           i['edi_state'] is! bool ? i['edi_state'] : "",
//   //                       invoice_user_id: i['invoice_user_id'] is! bool
//   //                           ? i['invoice_user_id'].toString()
//   //                           : "",
//   //                       amount_tax:
//   //                           i['amount_tax'] is! bool ? i['amount_tax'] : "",
//   //                       amount_untaxed:
//   //                           i['amount_tax'] is! bool ? i['amount_tax'] : "",
//   //                       picking_type_id: i['picking_type_id'] is! bool
//   //                           ? i['picking_type_id']
//   //                           : "",
//   //                       team_id: i['team_id'] is! bool ? i['team_id'] : "",
//   //                       line_ids: i['line_ids'] is! bool ? i['line_ids'] : [],
//   //                       amount_total: i["amount_total"] is! bool
//   //                           ? i["amount_total"]
//   //                           : "N/A",
//   //                       amount_residual: i["amount_residual"] is! bool
//   //                           ? i["amount_residual"]
//   //                           : "N/A",
//   //                       state: i['state'] is! bool ? i['state'] : "-",
//   //                       partner_id: i["partner_id"],
//   //                       payment_state: i['payment_state'] is! bool
//   //                           ? i['payment_state']
//   //                           : "-"),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelist = jsonEncode(res.getRecords());
//   //             preference.setString("offlineinvoices", invoicelist);
//   //             preference.setString(
//   //                 "offlineinvoiceslastupdated", DateTime.now().toString());
//   //             print("Updated offline invoice repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print(preference.getString("Can't update invoices. Device Offline."));
//   //     }
//   //   });
//   // }

//   //GET DRAFT INVOICES
//   // _getDraftInvoices() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       odoo.searchRead(Strings.account_move, [
//   //         ['state', '=', 'draft'],
//   //         ['move_type', "=", 'out_invoice'],
//   //         ['invoice_user_id', "ilike", '$fullname']
//   //       ], [
//   //         'id',
//   //         'invoice_date',
//   //         'payment_reference',
//   //         'line_ids',
//   //         'amount_total',
//   //         'amount_residual',
//   //         'state',
//   //         'move_type',
//   //         'partner_id',
//   //         'payment_state'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _invoices.add(
//   //                   new Invoice(
//   //                       id: i["id"],
//   //                       invoice_date: i["invoice_date"] is! bool
//   //                           ? i["invoice_date"]
//   //                           : "N/A",
//   //                       payment_reference: i["payment_reference"] is! bool
//   //                           ? i["payment_reference"]
//   //                           : "N/A",
//   //                       journal_id:
//   //                           i['journal_id'] is! bool ? i['journal_id'] : "",
//   //                       currency_id:
//   //                           i['currency_id'] is! bool ? i['currency_id'] : "",
//   //                       invoice_payment_term_id:
//   //                           i['invoice_payment_term_id'] is! bool
//   //                               ? i['invoice_payment_term_id']
//   //                               : "",
//   //                       edi_state:
//   //                           i['edi_state'] is! bool ? i['edi_state'] : "",
//   //                       invoice_user_id: i['invoice_user_id'] is! bool
//   //                           ? i['invoice_user_id']
//   //                           : "",
//   //                       amount_tax:
//   //                           i['amount_tax'] is! bool ? i['amount_tax'] : "",
//   //                       amount_untaxed:
//   //                           i['amount_tax'] is! bool ? i['amount_tax'] : "",
//   //                       picking_type_id: i['picking_type_id'] is! bool
//   //                           ? i['picking_type_id']
//   //                           : "",
//   //                       team_id: i['team_id'] is! bool ? i['team_id'] : "",
//   //                       line_ids: i['line_ids'] is! bool ? i['line_ids'] : [],
//   //                       amount_total: i["amount_total"] is! bool
//   //                           ? i["amount_total"]
//   //                           : "N/A",
//   //                       amount_residual: i["amount_residual"] is! bool
//   //                           ? i["amount_residual"]
//   //                           : "N/A",
//   //                       state: i['state'] is! bool ? i['state'] : "-",
//   //                       partner_id: i["partner_id"],
//   //                       payment_state: i['payment_state'] is! bool
//   //                           ? i['payment_state']
//   //                           : "-"),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinedraftinvoices", invoicelist);
//   //             preference.setString(
//   //                 "offlinedraftinvoiceslastupdated", DateTime.now().toString());
//   //             print("Updated offline draft invoice repository at " +
//   //                 DateTime.now().toString());
//   //             print("TETS");
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print("No offline draft invoices saved");
//   //     }
//   //   });
//   // }

//   //GET INVOICE LINES
//   // _getInvoiceLines() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       odoo.searchRead(Strings.account_move_line, [
//   //         ['product_id', "!=", false],
//   //         ['product_uom_id', "!=", false],
//   //       ], [
//   //         'id',
//   //         'price_unit',
//   //         'product_id',
//   //         'price_total',
//   //         'quantity',
//   //         'product_uom_id',
//   //         'account_id',
//   //         'price_unit'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _invoiceLines.add(
//   //                   new InvoiceLine(
//   //                     id: i["id"],
//   //                     quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
//   //                     price_total:
//   //                         i["price_total"] is! bool ? i["price_total"] : 0.0,
//   //                     price_unit:
//   //                         i["price_unit"] is! bool ? i["price_unit"] : 0.0,
//   //                     name: i["product_id"] is! bool
//   //                         ? i["product_id"][1]
//   //                         : "Unkown",
//   //                     product_uom_id: i["product_uom_id"] is! bool
//   //                         ? i["product_uom_id"]
//   //                         : "pcs",
//   //                     account_id:
//   //                         i["account_id"] is! bool ? i["account_id"] : [],
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelineslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlineinvoicelines", invoicelineslist);
//   //             preference.setString(
//   //                 "offlineinvoicelineslastupdated", DateTime.now().toString());
//   //             print("Updated offline invoice lines repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print("Failed to update offline invoice lines. Device Offline.");
//   //     }
//   //   });
//   // }

//   // _getStockMoves() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       odoo.searchRead(Strings.stock_move, [
//   //         ['product_id', "!=", false],
//   //         ['product_uom', "!=", false],
//   //       ], [
//   //         'id',
//   //         'product_uom_qty',
//   //         'product_id',
//   //         // 'forecast_availabilty',
//   //         'product_uom',
//   //         // 'move_ids_without_package',
//   //         // 'move_line_ids_without_package'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _stockMoves.add(
//   //                   new StockMoves(
//   //                     id: i["id"],
//   //                     // forecast_availabilty: i["forecast_availabilty"] is! bool
//   //                     //     ? i["forecast_availabilty"]
//   //                     //     : "",
//   //                     product_uom_qty: i["product_uom_qty"] is! bool
//   //                         ? i["product_uom_qty"]
//   //                         : 0.0,
//   //                     product_id:
//   //                         i["product_id"] is! bool ? i["product_id"] : [],
//   //                     product_uom:
//   //                         i["product_uom"] is! bool ? i["product_uom"] : [],
//   //                     // move_ids_without_package:
//   //                     //     i["move_ids_without_package"] is! bool
//   //                     //         ? i["move_ids_without_package"]
//   //                     //         : [],
//   //                     // move_line_ids_without_package:
//   //                     //     i["move_line_ids_without_package"] is! bool
//   //                     //         ? i["move_line_ids_without_package"]
//   //                     //         : [],
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelineslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinestockmoves", invoicelineslist);
//   //             preference.setString(
//   //                 "offlinestockmoveslastupdated", DateTime.now().toString());
//   //             print("Updated offline stock moves repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print("Failed to update offline stock moves. Device Offline.");
//   //     }
//   //   });
//   // }

//   //GET STOCK MOVE LINES
//   // _getStockMoveLines() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       odoo.searchRead(Strings.stock_move_lines, [
//   //         ['product_id', "!=", false],
//   //         ['product_uom_id', "!=", false],
//   //       ], [
//   //         'id',
//   //         'product_qty',
//   //         'product_uom_qty',
//   //         'product_id',
//   //         'move_id',
//   //         'product_uom_id',
//   //         'location_dest_id',
//   //         'location_id'
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               for (var i in res.getRecords()) {
//   //                 _stockMoveLines.add(
//   //                   new StockMoveLines(
//   //                     id: i["id"],
//   //                     product_qty:
//   //                         i["product_qty"] is! bool ? i["product_qty"] : 1.0,
//   //                     product_uom_qty: i["product_uom_qty"] is! bool
//   //                         ? i["product_uom_qty"]
//   //                         : 1.0,
//   //                     move_id: i["move_id"] is! bool ? i["move_id"] : [],
//   //                     product_id:
//   //                         i["product_id"] is! bool ? i["product_id"] : [],
//   //                     product_uom_id: i["product_uom_id"] is! bool
//   //                         ? i["product_uom_id"]
//   //                         : "pcs",
//   //                     location_id:
//   //                         i["location_id"] is! bool ? i["location_id"] : [],
//   //                     location_dest_id: i["location_dest_id"] is! bool
//   //                         ? i["location_dest_id"]
//   //                         : [],
//   //                   ),
//   //                 );
//   //               }
//   //             });
//   //             var invoicelineslist = jsonEncode(res.getRecords());
//   //             preference.setString("offlinestockmovelines", invoicelineslist);
//   //             preference.setString("offlinestockmovelineslastupdated",
//   //                 DateTime.now().toString());
//   //             print("Updated offline stock move lines repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     } else {
//   //       print("Failed to update offline stock move lines. Device Offline.");
//   //     }
//   //   });
//   // }

//   //SAVE PATIENT TO REMOTE ODOO
//   _savePatient(patient_name, date_of_birth, age, patient_history, insured, insurance_company, patient_id qr_code)
//    async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     setState(() {
//       _userId = getUID();
//       // print("My User ID is " + _userId.toString());
//     });
//     isConnected().then((isInternet) {
//       if (isInternet) {
//         showLoading();
//         odoo.create(Strings.res_partner, {
//           "name": patient_name.toString(),
//           "date_of_birth": date_of_birth,
//           // "name": "Offline Sync Test",
//           // "account_name": "Offline Sync Test",
//           "age": age,
//           "patient_history": patient_history,
//           "patient_location": patient_location,
//           "user_id": _userId,
//           "qr_code": qr_code,
//           "patient_id": patient_id
//         }).then(
//           (OdooResponse res) {
//             if (!res.hasError()) {
//               setState(() {
//                 // _registerPending = false;
//               });
//               print("Patient registered successfully!");
//               // showMessage("Success", "Customer registered successfully!");
//               // pushAndRemoveUntil(Partners());
//             } else {
//               setState(() {
//                 // _registerPending = false;
//               });
//               print(res.getError());
//               showMessage("Warning", res.getErrorMessage());
//             }
//           },
//         );
//       }
//     });
//   }

//   _saveContact(name, position, parentId, email, phone) async {
//     SharedPreferences preference = await SharedPreferences.getInstance();
//     setState(() {
//       // _registerPending = true;
//     });
//     isConnected().then((isInternet) {
//       if (isInternet) {
//         showLoading();
//         odoo.create(Strings.res_partner, {
//           "name": name,
//           "parent_id": parentId,
//           "email": email,
//           "phone": phone,
//           "function": position,
//           "company_type": "person"
//         }).then(
//           (OdooResponse res) async {
//             if (!res.hasError()) {
//               await _getContacts();
//               showMessage("Success", "Contact registered successfully!");
//               // pushReplacement(Partners());
//             } else {
//               print(res.getError());
//               showMessage("Warning", res.getErrorMessage());
//             }
//           },
//         );
//       }
//     });
//   }

//   //GET CUSTOMERS DEFAULT LOCATION
//   // _getCustomerLocation() async {
//   //   SharedPreferences preference = await SharedPreferences.getInstance();
//   //   isConnected().then((isInternet) {
//   //     if (isInternet) {
//   //       showLoading();
//   //       //GET STOCK LOCATIONS
//   //       odoo.searchRead(Strings.stock_location, [
//   //         ['usage', '=', 'customer'],
//   //         ['location_id', 'ilike', 'Partner Locations']
//   //       ], [
//   //         'id',
//   //         'name',
//   //         'location_id',
//   //         'usage',
//   //       ]).then(
//   //         (OdooResponse res) {
//   //           if (!res.hasError()) {
//   //             setState(() {
//   //               hideLoading();
//   //               String session = getSession();
//   //               session = session.split(",")[0].split(";")[0];
//   //               if (res.getRecords().toString().length > 3) {
//   //                 _customerLocationId = res.getRecords()[0]["id"];
//   //                 _customerLocationSelection = res.getRecords()[0]
//   //                         ["location_id"][1] +
//   //                     "/" +
//   //                     res.getRecords()[0]["name"];
//   //               }
//   //             });
//   //             var customerlocationdata = jsonEncode(res.getRecords());
//   //             preference.setString(
//   //                 "offlinecustomerlocation", customerlocationdata);
//   //             preference.setString("offlinecustomerlocationlastupdated",
//   //                 DateTime.now().toString());
//   //             print("Updated offline customer stock location repository at " +
//   //                 DateTime.now().toString());
//   //           } else {
//   //             print(res.getError());
//   //             showMessage("Warning", res.getErrorMessage());
//   //           }
//   //         },
//   //       );
//   //     }
//   //   });
//   // }

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       _currentMonth = returnMonth(DateTime.now());
//     });
//     getOdooInstance().then((odoo) {
//       setState(() {
//         _userId = getUID();
//         _firstName = getUserFullName();
//       });
//       print("the user id is " + _userId.toString());
//       print("the fullname is " + _firstName.toString());
//     });
//     // _getCustomerLocation();
//     // _getPatientData(_userId);
//     // _getSalesOfficers();
//     // _getEmployees();
//     // _getRequisitionLines();
//     // _getAllEmployeeStock();
//     // _getContacts();
//     _getPatients();
//     // _getDraftInvoices();
//     // _getInvoices();
//     // _getInvoiceLines();
//     // _getStockMoves();
//     // _getStockMoveLines();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final emptyView = Container(
//       alignment: Alignment.center,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Icon(
//               Icons.person_outline,
//               color: Colors.grey.shade300,
//               size: 100,
//             ),
//             Padding(
//               padding: EdgeInsets.all(1.0),
//               child: Text(
//                 Strings.no_patients,
//                 style: TextStyle(
//                   color: Colors.grey.shade500,
//                   fontSize: 20,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );

//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text(_firstName + " - " + _displaypatientId.toString()),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 _refreshData();
//               },
//               icon: Icon(
//                 Icons.refresh,
//                 color: Colors.white,
//               ))
//         ],
//       ),
//       drawer: Drawer(
//           elevation: 20.0,
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: <Widget>[
//               UserAccountsDrawerHeader(
//                 accountName: Text(userfullname != null ? userfullname : "User"),
//                 accountEmail: Text(email != null ? email : "email"),
//                 currentAccountPicture: Image.network(_imageUrl != null
//                     ? _imageUrl
//                     : "https://image.flaticon.com/icons/png/512/1144/1144760.png"),
//                 decoration: BoxDecoration(color: Colors.blueAccent),
//               ),
//               ListTile(
//                 leading: Icon(Icons.home),
//                 title: Text("Home"),
//                 onTap: () {
//                   print("Home Clicked");
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => Home()),
//                   );
//                 },
//               ),
//               // ListTile(
//               //   leading: Icon(Icons.library_books_sharp),
//               //   title: Text("Accounts"),
//               //   onTap: () {
//               //     print("Accounts Clicked");
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(builder: (context) => Accounts()),
//               //     );
//               //   },
//               // ),
//               // ListTile(
//               //   leading: Icon(Icons.library_books_sharp),
//               //   title: Text("Invoices"),
//               //   onTap: () {
//               //     print("Invoices Clicked");
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(builder: (context) => Invoices()),
//               //     );
//               //   },
//               // ),
//               // ListTile(
//               //   leading: Icon(Icons.person),
//               //   title: Text("Profile"),
//               //   onTap: () {
//               //     print("Profile Clicked");
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(builder: (context) => ProfilePage()),
//               //     );
//               //   },
//               // ),
//               // ListTile(
//               //   leading: Icon(Icons.settings),
//               //   title: Text("Settings"),
//               //   onTap: () {
//               //     print("About Clicked");
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(builder: (context) => Settings()),
//               //     );
//               //   },
//               // ),
//               ListTile(
//                 leading: Icon(Icons.exit_to_app),
//                 title: Text("Logout"),
//                 onTap: () {
//                   print("Logout Clicked");
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (BuildContext ctxt) {
//                       return AlertDialog(
//                         title: Text(
//                           "Log Out?",
//                           style: TextStyle(
//                             fontFamily: "Montserrat",
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         content: Text(
//                           "Are you sure you want to log out?",
//                           style: TextStyle(
//                             fontFamily: "Montserrat",
//                             fontSize: 18,
//                             color: Colors.black,
//                           ),
//                         ),
//                         actions: <Widget>[
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: Text(
//                               "Cancel",
//                               style: TextStyle(
//                                 fontFamily: "Montserrat",
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               _clearPrefs();
//                             },
//                             child: Text(
//                               "Logout",
//                               style: TextStyle(
//                                 fontFamily: "Montserrat",
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           )),
//       body: new Stack(
//         children: <Widget>[
//           new Container(
//             decoration: new BoxDecoration(
//               image: new DecorationImage(
//                 image: new AssetImage("assets/images/background.png"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             child: ListView(
//               // gridDelegate:
//               //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//               children: <Widget>[
//                 Container(
//                   height: _employeeStock.isEmpty ? 110 : 220,
//                   width: double.maxFinite,
//                   child: Card(
//                     child: SingleChildScrollView(
//                       child: DataTable(
//                         showBottomBorder: true,
//                         headingRowColor: MaterialStateColor.resolveWith(
//                           (states) {
//                             return Color(0xff3179ca);
//                           },
//                         ),
//                         dataRowColor: MaterialStateColor.resolveWith(
//                           (states) {
//                             return Color(0xffc4eefd);
//                           },
//                         ),
//                         columnSpacing: 10,
//                         // dataRowHeight: 1,
//                         columns: [
//                           DataColumn(
//                               label: Text('$_currentMonth',
//                                   style: TextStyle(color: Colors.white))),
//                           DataColumn(
//                               label: Text('Stock \nRcvd.',
//                                   style: TextStyle(color: Colors.white))),
//                           DataColumn(
//                               label: Text('Stock \nShpd',
//                                   style: TextStyle(color: Colors.white))),
//                           DataColumn(
//                               label: Text('Stock \nRem.',
//                                   style: TextStyle(color: Colors.white))),
//                         ],
//                         rows: _employeeStock.isEmpty
//                             ? [
//                                 DataRow(
//                                   cells: <DataCell>[
//                                     DataCell(Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.35,
//                                       child: Text(
//                                         "Data Unavailable",
//                                         overflow: TextOverflow.visible,
//                                       ),
//                                     )), //Extracting from Map element the value
//                                     DataCell(Text("")),
//                                     DataCell(Text("")),
//                                     DataCell(Text("")),
//                                   ],
//                                 )
//                               ]
//                             : _employeeStock // Loops through dataColumnText, each iteration assigning the value to element
//                                 .map(
//                                   (element) => DataRow(
//                                     cells: <DataCell>[
//                                       DataCell(Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.35,
//                                         child: Text(
//                                           element.product_id[1].toString(),
//                                           overflow: TextOverflow.visible,
//                                         ),
//                                       )), //Extracting from Map element the value
//                                       DataCell(
//                                           Text(element.quantity_in.toString())),
//                                       DataCell(Text(
//                                           element.quantity_out.toString())),
//                                       DataCell(Text(
//                                           element.quantity_finish.toString())),
//                                     ],
//                                   ),
//                                 )
//                                 .toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     push(ShipToSales());
//                   },
//                   child: Container(
//                     height: 80,
//                     child: Card(
//                       color: Color(0xff00a3d2),
//                       shadowColor: Colors.grey[700],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           FaIcon(
//                             FontAwesomeIcons.truckLoading,
//                             color: Colors.white,
//                           ),
//                           SizedBox(
//                             width: 12,
//                           ),
//                           Text(
//                             "Ship stock to Sales Officer",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     push(ShipToCustomer());
//                   },
//                   child: Container(
//                     height: 80,
//                     child: Card(
//                       color: Color(0xff00a3d2),
//                       shadowColor: Colors.grey[700],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           FaIcon(
//                             FontAwesomeIcons.shippingFast,
//                             color: Colors.white,
//                           ),
//                           SizedBox(
//                             width: 12,
//                           ),
//                           Text(
//                             "Ship stock to Customer",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     push(StockTaking());
//                   },
//                   child: Container(
//                     height: 80,
//                     child: Card(
//                       color: Color(0xff00a3d2),
//                       shadowColor: Colors.grey[700],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           FaIcon(
//                             FontAwesomeIcons.edit,
//                             color: Colors.white,
//                           ),
//                           SizedBox(
//                             width: 12,
//                           ),
//                           Text(
//                             "Record Stock Count",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     push(ViewEmploeeStock());
//                   },
//                   child: Container(
//                     height: 80,
//                     child: Card(
//                       color: Color(0xff00a3d2),
//                       shadowColor: Colors.grey[700],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           FaIcon(
//                             FontAwesomeIcons.search,
//                             color: Colors.white,
//                           ),
//                           SizedBox(
//                             width: 12,
//                           ),
//                           Text(
//                             "Check Staff Stock Balance",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ReconnectingOverlay extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 child: SpinKitCubeGrid(
//                   color: Colors.blue,
//                   size: 50.0,
//                 )),
//             SizedBox(height: 12),
//             Text(
//               'Initializing app...',
//             ),
//           ],
//         ),
//       );
// }
