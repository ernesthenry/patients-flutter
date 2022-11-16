import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:patients/app/data/pojo/currencies.dart';
// import 'package:patients/app/data/pojo/journals.dart';
// import 'package:patients/app/data/pojo/stocklocations.dart';
import 'package:patients/app/data/services/odoo_api.dart';
import 'package:patients/app/data/services/odoo_response.dart';
import 'package:patients/app/utility/constant.dart';
import 'package:patients/app/utility/strings.dart';
import 'package:patients/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends Base<Settings> {
  TextEditingController _urlCtrler = new TextEditingController();
  String odooURL = "";
  // List<Currency> _currencies = [];
  // List<Journal> _journals = [];
  // List<StockLocation> _stockLocations = [];
  // int _currencyId, _journalId, _stockLocationId;
  // List currenciesdata = List();
  SharedPreferences preference;
  // String _journalSelection = "Select Invoice Journal",
  //     _currencySelection = "Select Currency",
  //     _stockLocationSelection = "Select Stock Location";

  @override
  void initState() {
    super.initState();
    getOdooInstance().then((odoo) {
      _checkFirstTime();
    });
    // _getPrefs();
    // _getOne2ManyFields();
  }

  // _getPrefs() async {
  //   preference = await SharedPreferences.getInstance();
  //   setState(() {
  //     if (preference.getString("currencySymbol") != null)
  //       _currencySelection = preference.getString("currencySymbol");
  //     if (preference.getString("currencyId") != null)
  //       _currencyId = preference.getInt("currencyId");
  //     if (preference.getString("journalName") != null)
  //       _journalSelection = preference.getString("journalName");
  //     if (preference.getString("journalId") != null)
  //       _journalId = preference.getInt("journalId");
  //     if (preference.getString("stockLocationName") != null)
  //       _stockLocationSelection = preference.getString("stockLocationName");
  //     if (preference.getString("stockLocationId") != null)
  //       _stockLocationId = preference.getInt("stockLocationId");
  //   });
  // }

  _checkFirstTime() async {
    if (getURL() != null) {
      setState(() {
        _urlCtrler.text = odooURL = getURL();
      });
    }
  }

  // _getOne2ManyFields() async {
  //   isConnected().then((isInternet) {
  //     if (isInternet) {
  //       showLoading();
  //       // odoo.searchRead(Strings.region, [], ['id', 'name']);
  //       //GET CURRENCIES
  //       odoo.searchRead(Strings.res_currency, [], ['id', 'name']).then(
  //         (OdooResponse res) {
  //           if (!res.hasError()) {
  //             setState(() {
  //               hideLoading();
  //               String session = getSession();
  //               session = session.split(",")[0].split(";")[0];
  //               for (var i in res.getRecords()) {
  //                 _currencies.add(
  //                   new Currency(
  //                     id: i["id"],
  //                     name: i["name"].toString(),
  //                     symbol: i["symbol"] is! bool ? i["symbol"] : "N/A",
  //                     rate: i["rate"] is! bool ? i["rate"] : "N/A",
  //                   ),
  //                 );
  //               }
  //             });
  //           } else {
  //             print(res.getError());
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
        //GET JOURNALS
        // odoo.searchRead(
        //     Strings.account_journal, [], ['id', 'display_name']).then(
        //   (OdooResponse res) {
        //     if (!res.hasError()) {
        //       setState(() {
        //         hideLoading();
        //         String session = getSession();
        //         session = session.split(",")[0].split(";")[0];
        //         for (var i in res.getRecords()) {
        //           _journals.add(
        //             new Journal(
        //               id: i["id"],
        //               display_name: i["display_name"].toString(),
        //             ),
        //           );
        //         }
        //       });
        //     } else {
        //       print(res.getError());
        //       showMessage("Warning", res.getErrorMessage());
        //     }
        //   },
        // );
        //GET STOCK LOCATIONS
        // odoo.searchRead(
        //     Strings.stock_location, [], ['id', 'display_name']).then(
        //   (OdooResponse res) {
        //     if (!res.hasError()) {
        //       setState(() {
        //         hideLoading();
        //         String session = getSession();
        //         session = session.split(",")[0].split(";")[0];
        //         for (var i in res.getRecords()) {
        //           _stockLocations.add(
        //             new StockLocation(
        //               id: i["id"],
        //               display_name: i["display_name"].toString(),
        //             ),
        //           );
        //         }
        //       });
        //     } else {
        //       print(res.getError());
        //       showMessage("Warning", res.getErrorMessage());
        //     }
        //   },
        // );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              width: _width * 0.89,
              decoration: customDecoration(),
              child: TextFormField(
                controller: _urlCtrler,
                decoration: InputDecoration(
                  hintText: "Odoo Server URL",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.http_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 15),
          //   child: Container(
          //     margin: EdgeInsets.only(bottom: 15),
          //     width: _width * 0.89,
          //     decoration: customDecoration(),
          //     child: Expanded(
          //       child: Container(
          //         width: double.infinity,
          //         padding: EdgeInsets.symmetric(horizontal: 10),
          //         child: Center(
          //           child: DropdownButton(
          //             isExpanded: true,
          //             hint: Row(
          //               children: [
          //                 Icon(
          //                   Icons.monetization_on_rounded,
          //                   color: Theme.of(context).primaryColor,
          //                 ),
          //                 SizedBox(
          //                   width: 10,
          //                 ),
          //                 Text(
          //                   _currencySelection != null
          //                       ? _currencySelection
          //                       : "-",
          //                   style: TextStyle(
          //                       color: Colors.grey,
          //                       fontSize: 16,
          //                       fontWeight: FontWeight.w400),
          //                 ),
          //               ],
          //             ),
          //             items: _currencies.map((item) {
          //               return new DropdownMenuItem(
          //                 child: Row(
          //                   children: [
          //                     Icon(
          //                       Icons.monetization_on_rounded,
          //                       color: Theme.of(context).primaryColor,
          //                     ),
          //                     SizedBox(
          //                       width: 10,
          //                     ),
          //                     new Text(
          //                       item.name,
          //                       style: TextStyle(
          //                           color: Colors.grey,
          //                           fontSize: 16,
          //                           fontWeight: FontWeight.w400),
          //                     ),
          //                   ],
          //                 ),
          //                 value: item.id,
          //               );
          //             }).toList(),
          //             onChanged: (newVal) {
          //               List itemsList = _currencies.map((item) {
          //                 if (item.id == newVal) {
          //                   setState(() {
          //                     _currencySelection = item.name;
          //                     _currencyId = item.id;
          //                     print(_currencySelection);
          //                     print(_currencyId);
          //                   });
          //                 }
          //               }).toList();
          //             },
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 15),
          //   child: Container(
          //     margin: EdgeInsets.only(bottom: 15),
          //     width: _width * 0.89,
          //     decoration: customDecoration(),
          //     child: Expanded(
          //       child: Container(
          //         width: double.infinity,
          //         padding: EdgeInsets.symmetric(horizontal: 10),
          //         child: Center(
          //           child: DropdownButton(
          //             isExpanded: true,
          //             hint: Row(
          //               children: [
          //                 Icon(
          //                   Icons.account_balance_outlined,
          //                   color: Theme.of(context).primaryColor,
          //                 ),
          //                 SizedBox(
          //                   width: 10,
          //                 ),
          //                 Text(
          //                   _journalSelection != null ? _journalSelection : "-",
          //                   style: TextStyle(
          //                       color: Colors.grey,
          //                       fontSize: 16,
          //                       fontWeight: FontWeight.w400),
          //                 ),
          //               ],
          //             ),
          //             items: _journals.map((item) {
          //               return new DropdownMenuItem(
          //                 child: Row(
          //                   children: [
          //                     Icon(
          //                       Icons.account_balance_outlined,
          //                       color: Theme.of(context).primaryColor,
          //                     ),
          //                     SizedBox(
          //                       width: 10,
          //                     ),
          //                     new Text(
          //                       item.display_name,
          //                       style: TextStyle(
          //                           color: Colors.grey,
          //                           fontSize: 16,
          //                           fontWeight: FontWeight.w400),
          //                     ),
          //                   ],
          //                 ),
          //                 value: item.id,
          //               );
          //             }).toList(),
          //             onChanged: (newVal) {
          //               List itemsList = _journals.map((item) {
          //                 if (item.id == newVal) {
          //                   setState(() {
          //                     _journalSelection = item.display_name;
          //                     _journalId = item.id;
          //                   });
          //                 }
          //               }).toList();
          //             },
          //             // value: _mySelection,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 15),
          //   child: Container(
          //     margin: EdgeInsets.only(bottom: 15),
          //     width: _width * 0.89,
          //     decoration: customDecoration(),
          //     child: Expanded(
          //       child: Container(
          //         width: double.infinity,
          //         padding: EdgeInsets.symmetric(horizontal: 10),
          //         child: Center(
          //           child: DropdownButton(
          //             isExpanded: true,
          //             hint: Row(
          //               children: [
          //                 Icon(
          //                   Icons.location_on,
          //                   color: Theme.of(context).primaryColor,
          //                 ),
          //                 SizedBox(
          //                   width: 10,
          //                 ),
          //                 Text(
          //                   _stockLocationSelection != null
          //                       ? _stockLocationSelection
          //                       : "-",
          //                   style: TextStyle(
          //                       color: Colors.grey,
          //                       fontSize: 16,
          //                       fontWeight: FontWeight.w400),
          //                 ),
          //               ],
          //             ),
          //             items: _stockLocations.map((item) {
          //               return new DropdownMenuItem(
          //                 child: Row(
          //                   children: [
          //                     Icon(
          //                       Icons.location_on,
          //                       color: Theme.of(context).primaryColor,
          //                     ),
          //                     SizedBox(
          //                       width: 10,
          //                     ),
          //                     new Text(
          //                       item.display_name,
          //                       style: TextStyle(
          //                           color: Colors.grey,
          //                           fontSize: 16,
          //                           fontWeight: FontWeight.w400),
          //                     ),
          //                   ],
          //                 ),
          //                 value: item.id,
          //               );
          //             }).toList(),
          //             onChanged: (newVal) {
          //               List itemsList = _stockLocations.map((item) {
          //                 if (item.id == newVal) {
          //                   setState(() {
          //                     _stockLocationSelection = item.display_name;
          //                     _stockLocationId = item.id;
          //                     print(_stockLocationSelection);
          //                     print(_stockLocationId);
          //                   });
          //                 }
          //               }).toList();
          //             },
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: MaterialButton(
              child: Text(
                "Save Settings",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.indigo.shade400,
              onPressed: () {
                // _savePrefs();
                // _saveURL(_urlCtrler.text);
              },
            ),
          )
        ],
      ),
    );
  }

  // _savePrefs() {
  //   saveCurrency(_currencySelection, _currencyId);
  //   saveJournal(_journalSelection, _journalId);
  //   saveStockLocation(_stockLocationSelection, _stockLocationId);
  // }

  _saveURL(String url) async {
    if (!url.toLowerCase().contains("http://") &&
        !url.toLowerCase().contains("https://")) {
      url = "http://" + url;
    }
    if (url.length > 0 && url != " ") {
      isConnected().then((isInternet) {
        if (isInternet) {
          odoo = new Odoo(url: url);
          odoo.getDatabases().then((http.Response res) {
            saveOdooUrl(url);
            _showLogoutMessage(Strings.loginAgainMessage);
          }).catchError((error) {
            _showMessage(Strings.invalidUrlMessage);
          });
        }
      });
    } else {
      _showMessage("Please enter valid URL");
    }
  }

  _showMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Warning",
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
              onPressed: () {
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

  _showLogoutMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Warning",
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
  }

  _clearPrefs() async {
    odoo.destroy();
    preferences.remove(Constants.USER_PREF);
    preferences.remove(Constants.SESSION);
    pushAndRemoveUntil(Login());
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
