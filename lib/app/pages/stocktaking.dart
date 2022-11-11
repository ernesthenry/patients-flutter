import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/employeestock.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/products.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/pages/home.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:intl/intl.dart';

List<Product> _products = [];
List<EmployeeStock> _allEmployeeStock = [];
List<int> _newCountedStock = [];

class StockTaking extends StatefulWidget {
  @override
  _StockTakingState createState() => _StockTakingState();
}

class _StockTakingState extends Base<StockTaking> {
  BuildContext dialogContext;
  final _dateFormat = DateFormat("yyyy-MM-dd");
  List _employeeLocationId = [];
  String _employeeName = "";

  //GET EMPLOYEE NAME AND ID
  _getEmployeeData() async {
    var employeeId;
    SharedPreferences preference = await SharedPreferences.getInstance();
    //GET DASHBOARD TABLE BEFORE GETTING EMPLOYEE DATA
    if (preference.getString("offlineemployeedata") != null) {
      print(preference.getString("offlineemployeedata"));
      var empdata = json.decode(preference.getString("offlineemployeedata"));
      setState(() {
        _employeeLocationId = empdata["location_id"];
        _employeeName = empdata["name"];
        print("+++ THIS IS THE EMPLOYEE NAME " +
            _employeeName.toString() +
            " +++++++++++++++++++");
      });
    }
  }

  _getEmployeeStock() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlineemployeestock") != null) {
      print(preference.getString("offlineemployeestock"));
      var stocklist = json.decode(preference.getString("offlineemployeestock"));
      setState(() {
        _allEmployeeStock = [];
        for (var i in stocklist) {
          _allEmployeeStock.add(
            new EmployeeStock(
              id: i["id"],
              report_id: i["report_id"],
              categ_id: i["categ_id"] is! bool ? i["categ_id"] : [],
              product_id: i["product_id"] is! bool ? i["product_id"] : [],
              quantity_in: i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
              quantity_out:
                  i["quantity_out"] is! bool ? i["quantity_out"] : 0.0,
              quantity_adjust:
                  i["quantity_adjust"] is! bool ? i["quantity_adjust"] : 0.0,
              quantity_begin:
                  i["quantity_begin"] is! bool ? i["quantity_begin"] : 0.0,
              quantity_finish:
                  i["quantity_finish"] is! bool ? i["quantity_finish"] : 0.0,
              amount_adjust:
                  i["amount_adjust"] is! bool ? i["amount_adjust"] : 0.0,
              amount_begin:
                  i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
              amount_finish:
                  i["amount_finish"] is! bool ? i["amount_finish"] : 0.0,
              amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
              amount_out: i["amount_out"] is! bool ? i["amount_out"] : 0.0,
            ),
          );
          _newCountedStock.add(0);
        }
      });
    }
  }

  //CHECK FOR UNAPPROVED STOCK TAKING RECORDS
  _checkUnapprovedStockTaking() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet && _employeeLocationId.isNotEmpty) {
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
                  new Text(
                      "Checking for unapproved \nstock taking records....."),
                ],
              ),
            );
          },
        );
        odoo.searchRead(Strings.stock_inventory, [
          ["location_ids", "ilike", _employeeLocationId[1]],
          ['state', "=", "draft"],
        ], [
          'id',
          'location_ids',
          'state',
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                int recordCount = res.getResult()["length"];
                print("THE NUMBER OF DRAFT RECORDS IS $recordCount");
                Navigator.of(dialogContext).pop();
                if (recordCount > 0) {
                  showRecordSuccessMessage(
                      "Alert",
                      "You have prior unapproved stock taking records. \nYou are not able to proceed with this stock taking.",
                      "continue");
                }
              });
            } else {
              print(res.getError());
              Navigator.of(dialogContext).pop();
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        print("Failed to update offline invoice lines. Device Offline.");
      }
    });
  }

  _saveStockTaking(String saveType) async {
    var inventoryId;
    DateTime _now = DateTime.now();
    var formattedInvoiceDate = _dateFormat.format(_now);
    print("++++++++++++++++++++++");
    print("FORMATTED DATE IS " + formattedInvoiceDate.toString());
    print("++++++++++++++++++++++");

    isConnected().then((isInternet) {
      if (isInternet) {
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
                  new Text("Saving stock \n taking record....."),
                ],
              ),
            );
          },
        );
        odoo.create(Strings.stock_inventory, {
          // "activity_user_id": _userId,
          "name": "$_employeeName App Stock Count",
          "date": formattedInvoiceDate.toString(),
          "accounting_date": formattedInvoiceDate.toString(),
          "location_ids": [_employeeLocationId[0]],
          // "product_ids": _taxTotal,
          // "company_ids"
          // "line_ids":
          "exhausted": false
        }).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              inventoryId = jsonDecode(res.getResult().toString());
              print("THE INVENTORY ID IS" + inventoryId.toString());
              int itemCount = 0;
              for (var i in _allEmployeeStock) {
                int count = 0;
                itemCount++;
                print("THE PRODUCT IS - " + i.product_id[1].toString());
                odoo.create(Strings.stock_inventory_line, {
                  "inventory_id": inventoryId,
                  "product_id": i.product_id[0],
                  "product_qty": _newCountedStock[itemCount - 1],
                  "theoretical_qty": i.quantity_finish,
                  "display_name": i.product_id[1],
                  "location_id": _employeeLocationId[0],
                  // "difference_qty": i.quantity,
                }).then(
                  (OdooResponse res) {
                    if (!res.hasError()) {
                      count++;
                      print("CREATED STOCK INVENTORY LINE " +
                          itemCount.toString());
                      if ((itemCount).toString() ==
                          _allEmployeeStock.length.toString()) {
                        Navigator.pop(context);
                        showRecordSuccessMessage("Success",
                            "Stock count saved successfully", saveType);
                      }
                    } else {
                      print(res.getError());
                      showMessage("Warning!!", res.getErrorMessage());
                    }
                  },
                );
              }
            } else {
              print(res.getError());
              Navigator.pop(context);
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  showRecordSuccessMessage(String title, String message, String saveType) {
    hideLoading();
    // if (Platform.isAndroid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            title,
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
                Navigator.pop(context);
                if (saveType == "continue") {
                  pushAndRemoveUntil(Home());
                } else {
                  setState(() {});
                }
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

  @override
  void initState() {
    super.initState();
    getOdooInstance().then((odoo) {
      _getEmployeeData();
      _getEmployeeStock();
      _checkUnapprovedStockTaking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emptyView = Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
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
                    "No Stock",
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
      appBar: AppBar(
        title: Text(
          "Record Stock Count",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _saveStockTaking("continue");
            },
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
          )
        ],
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _allEmployeeStock.length > 0
          ? Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                reverse: false,
                itemCount: _allEmployeeStock.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    // push(RequisitionDetails(
                    //     data: _products[i],
                    //     stockLocation: widget.stockLocation));
                  },
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          height: 120,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _allEmployeeStock[i].product_id[1],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Theoretical Qty",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              _allEmployeeStock[i]
                                                  .quantity_finish
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Qty on hand",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                            Container(
                                              width: 60,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _newCountedStock[i] =
                                                        int.tryParse(value);
                                                  });
                                                  print("++++ " +
                                                      _newCountedStock
                                                          .toString() +
                                                      " ++++++++");
                                                },
                                                // initialValue:
                                                //     _newCountedStock[i]
                                                //         .toString(),
                                              ),
                                            )
                                            // Text(
                                            //   _allEmployeeStock[i]
                                            //       .quantity_finish
                                            //       .toString(),
                                            //   style: TextStyle(
                                            //       fontWeight: FontWeight.w500,
                                            //       fontSize: 16),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
