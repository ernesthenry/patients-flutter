import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/employees.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoicelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoices.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/requisitionlines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/requisitions.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/pages/partner_details.dart';
import 'package:spouts_inventory_odoo/app/pages/requisitiondetails.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addinvoice.dart';
import 'invoice_details.dart';
import 'profile.dart';
import 'settings.dart';

List<Requisition> _requisitions = [];
List<RequisitionLine> _requisitionLines = [];
List<Employees> _salesOfficers = [];
final value = new NumberFormat("#,##0", "en_US");

class ShipToSalesOld extends StatefulWidget {
  @override
  _ShipToSalesOldState createState() => _ShipToSalesOldState();
}

class _ShipToSalesOldState extends Base<ShipToSalesOld> {
  //Odoo _odoo;
  String fullname;
  String _result;
  BuildContext dialogContext;

  _getSalesOfficers() async {
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
              new Text("Getting Sales Officers ....."),
            ],
          ),
        );
      },
    );

    if (preference.getString("offlinesalesofficers") != null) {
      print(preference.getString("offlinesalesofficers"));
      var cutomerlist =
          json.decode(preference.getString("offlinesalesofficers"));
      setState(() {
        for (var i in cutomerlist) {
          if (i["name"].toString().length > 1) {
            _salesOfficers.add(
              new Employees(
                id: i["id"],
                work_email: i["work_email"] is! bool ? i["work_email"] : "N/A",
                name: i["name"].toString(),
                work_phone: i["work_phone"] is! bool ? i["work_phone"] : "N/A",
                mobile_phone:
                    i["mobile_phone"] is! bool ? i["mobile_phone"] : "N/A",
                company_user_code: i["company_user_code"] is! bool
                    ? i["company_user_code"]
                    : "N/A",
                job_title: i["job_title"] is! bool ? i["job_title"] : "N/A",
                location_id: i["location_id"] is! bool ? i["location_id"] : [],
              ),
            );
          }
        }
      });
      _showSalesOfficers();
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          odoo.searchRead(Strings.hr_employee, [
            ['department_id', "ilike", "Sales & Marketing / Sales Department"]
          ], [
            'name',
            'job_title',
            'work_email',
            'work_phone',
            'mobile_phone',
            'company_user_code',
            'location_id'
          ]).then(
            (OdooResponse res) {
              if (!res.hasError()) {
                setState(() {
                  hideLoading();
                  String session = getSession();
                  session = session.split(",")[0].split(";")[0];
                  for (var i in res.getRecords()) {
                    if (i["name"].toString().length > 1) {
                      _salesOfficers.add(
                        new Employees(
                          id: i["id"],
                          work_email: i["work_email"] is! bool
                              ? i["work_email"]
                              : "N/A",
                          name: i["name"].toString(),
                          work_phone: i["work_phone"] is! bool
                              ? i["work_phone"]
                              : "N/A",
                          mobile_phone: i["mobile_phone"] is! bool
                              ? i["mobile_phone"]
                              : "N/A",
                          company_user_code: i["company_user_code"] is! bool
                              ? i["company_user_code"]
                              : "N/A",
                          job_title:
                              i["job_title"] is! bool ? i["job_title"] : "N/A",
                          location_id:
                              i["location_id"] is! bool ? i["location_id"] : [],
                        ),
                      );
                    }
                  }
                  _showSalesOfficers();
                });
                var salesofficerslist = jsonEncode(res.getRecords());
                preference.setString("offlinesalesofficers", salesofficerslist);
                preference.setString("offlinesalesofficerslastupdated",
                    DateTime.now().toString());
                print("Updated offline sales officers repository at " +
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

  _showSalesOfficers() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: Text("Select Sales Officer"),
          content: _salesOfficers.isEmpty
              ? Text("No Sales Officers Available.")
              : Container(
                  // height: 400,
                  width: double.maxFinite,
                  child: new ListView.builder(
                    itemCount: _salesOfficers.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _getRequisitions(_salesOfficers[i]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(width: 1.5, color: Colors.grey[300]),
                          ),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(_salesOfficers[i].name)),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  _getRequisitions(Employees salesOfficer) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      fullname = getUserFullName();
      _requisitions = [];
    });
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
              new Text("Getting \n" +
                  salesOfficer.name +
                  "'s \n Requisitions ....."),
            ],
          ),
        );
      },
    );
    if (preference.getString("offlinerequisitions") != null) {
      print(preference.getString("offlinerequisitions"));
      var invoicelist =
          json.decode(preference.getString("offlinerequisitions"));
      setState(() {
        for (var i in invoicelist) {
          if (i["responsible"] is! bool &&
              i["responsible"][0] == salesOfficer.id) {
            _requisitions.add(
              new Requisition(
                id: i["id"],
                name: i['name'] is! bool ? i['name'] : "",
                requested_by:
                    i["requested_by"] is! bool ? i["requested_by"] : [],
                employee_id: i['employee_id'] is! bool ? i['employee_id'] : [],
                request_date:
                    i['request_date'] is! bool ? i['request_date'] : "",
                state: i['state'] is! bool ? i['state'] : "",
                notes: i['notes'] is! bool ? i['notes'] : "",
                picking_type_id:
                    i['picking_type_id'] is! bool ? i['picking_type_id'] : [],
                location_dest_id:
                    i['location_dest_id'] is! bool ? i['location_dest_id'] : [],
                location_src_id:
                    i['location_src_id'] is! bool ? i['location_src_id'] : [],
                product_lines:
                    i['product_lines'] is! bool ? i['product_lines'] : [],
              ),
            );
          }
        }
      });
      Navigator.of(context).pop();
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          odoo.searchRead(Strings.requisition, [
            ['responsible', "ilike", salesOfficer.name]
          ], [
            'id',
            'location_src_id',
            'location_dest_id',
            'picking_type_id',
            'notes',
            'name',
            'request_date',
            'requested_by',
            'responsible',
            'product_lines',
            'state'
          ]).then(
            (OdooResponse res) {
              if (!res.hasError()) {
                setState(() {
                  hideLoading();
                  String session = getSession();
                  session = session.split(",")[0].split(";")[0];
                  for (var i in res.getRecords()) {
                    _requisitions.add(
                      new Requisition(
                        id: i["id"],
                        name: i['name'] is! bool ? i['name'] : "",
                        requested_by:
                            i["requested_by"] is! bool ? i["requested_by"] : [],
                        employee_id:
                            i['employee_id'] is! bool ? i['employee_id'] : [],
                        request_date:
                            i['request_date'] is! bool ? i['request_date'] : "",
                        state: i['state'] is! bool ? i['state'] : "",
                        notes: i['notes'] is! bool ? i['notes'] : "",
                        picking_type_id: i['picking_type_id'] is! bool
                            ? i['picking_type_id']
                            : [],
                        location_dest_id: i['location_dest_id'] is! bool
                            ? i['location_dest_id']
                            : [],
                        location_src_id: i['location_src_id'] is! bool
                            ? i['location_src_id']
                            : [],
                        product_lines: i['product_lines'] is! bool
                            ? i['product_lines']
                            : [],
                      ),
                    );
                  }
                });
                Navigator.of(context).pop();
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
      _getSalesOfficers();
      // _getRequisitions();
      // _getRequisitionLines();
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
          width: 180,
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
                    Strings.no_requisitions,
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
        title: Text("Ship Stock to Sales Officer"),
        // actions: <Widget>[
        //   IconButton(
        //       onPressed: () async {
        //         var result = await showSearch<String>(
        //           context: context,
        //           delegate: CustomDelegate(),
        //         );
        //         setState(() => _result = result);
        //       },
        //       icon: Icon(Icons.search)),
        // ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _refreshInvoices();
      //     _getRequisitionLines();
      //   },
      //   // label: const Text(''),
      //   child: const Icon(Icons.replay),
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: _requisitions.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                itemCount: _requisitions.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    push(RequisitionDetails(data: _requisitions[i]));
                  },
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          height: 100,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.library_books,
                                          color: Color(0xff00a09d),
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            _requisitions[i].name,
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Color(0xff00a09d),
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            _requisitions[i].request_date,
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 90,
                                      child: TextButton(
                                        // textColor: Colors.white,
                                        // height: 60.0,
                                        // color: _requisitions[i]
                                        //             .state
                                        //             .toLowerCase() ==
                                        //         "draft"
                                        //     ? Colors.amber
                                        //     : _requisitions[i]
                                        //                 .state
                                        //                 .toLowerCase() ==
                                        //             "cancel"
                                        //         ? Colors.red
                                        //         : Color(0xff00a09d),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0.0),
                                              child: _requisitions[i]
                                                          .state
                                                          .toLowerCase() ==
                                                      "draft"
                                                  ? Icon(
                                                      Icons.hourglass_bottom,
                                                      color: Colors.white,
                                                      size: 14,
                                                    )
                                                  : _requisitions[i]
                                                              .state
                                                              .toLowerCase() ==
                                                          "cancel"
                                                      ? Icon(
                                                          Icons.cancel,
                                                          color: Colors.white,
                                                          size: 14,
                                                        )
                                                      : Icon(
                                                          Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              width: 38,
                                              child: Text(
                                                _requisitions[i]
                                                    .state
                                                    .toUpperCase(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
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
      listToShow = _requisitions
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    // .where((e) => e.contains(query) && e.startsWith(query))
    // .toList();
    else
      listToShow = _requisitions;

    return ListView.builder(
      itemCount: listToShow.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, i) => InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      InvoiceDetails(data: listToShow[i])));
        },
        child: Card(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                height: 130,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Color(0xff00a09d),
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  listToShow[i].name,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Color(0xff00a09d),
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  listToShow[i].invoice_date,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Color(0xff00a09d),
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  (" ${value.format(listToShow[i].amount_total)}"),
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 25,
                            width: 90,
                            child: TextButton(
                              // textColor: Colors.white,
                              // height: 60.0,
                              // color:
                              //     listToShow[i].state.toLowerCase() == "draft"
                              //         ? Colors.amber
                              //         : listToShow[i].state.toLowerCase() ==
                              //                 "cancel"
                              //             ? Colors.red
                              //             : Color(0xff00a09d),
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0.0),
                                    child: listToShow[i].state.toLowerCase() ==
                                            "draft"
                                        ? Icon(
                                            Icons.hourglass_bottom,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : listToShow[i].state.toLowerCase() ==
                                                "cancel"
                                            ? Icon(
                                                Icons.cancel,
                                                color: Colors.white,
                                                size: 14,
                                              )
                                            : Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 38,
                                    child: Text(
                                      listToShow[i].state.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (listToShow[i].payment_state.toLowerCase() ==
                                  "paid" ||
                              listToShow[i].payment_state.toLowerCase() ==
                                  "partial")
                            Container(
                              height: 25,
                              width: 90,
                              child: TextButton(
                                // textColor: Colors.white,
                                // height: 60.0,
                                // color:
                                //     listToShow[i].payment_state.toLowerCase() ==
                                //             "paid"
                                //         ? Colors.green
                                //         : Color(0xff00a09d),
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0),
                                      child: listToShow[i]
                                                  .payment_state
                                                  .toLowerCase() ==
                                              "paid"
                                          ? Icon(
                                              Icons
                                                  .check_circle_outline_outlined,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : Icon(
                                              Icons.hourglass_empty,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 38,
                                      child: Text(
                                        listToShow[i]
                                            .payment_state
                                            .toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
