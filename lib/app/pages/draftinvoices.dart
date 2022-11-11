import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoicelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoices.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/pages/partner_details.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addinvoice.dart';
import 'invoice_details.dart';
import 'profile.dart';
import 'settings.dart';

class DraftInvoices extends StatefulWidget {
  @override
  _DraftInvoicesState createState() => _DraftInvoicesState();
}

class _DraftInvoicesState extends Base<DraftInvoices> {
  //Odoo _odoo;
  List<Invoice> _invoices = [];
  List<InvoiceLine> _invoiceLines = [];
  String fullname;
  final value = new NumberFormat("#,##0", "en_US");

  _getInvoices() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      fullname = getUserFullName();
    });
    if (preference.getString("offlinedraftinvoices") != null) {
      print(preference.getString("offlinedraftinvoices"));
      var invoicelist =
          json.decode(preference.getString("offlinedraftinvoices"));
      setState(() {
        for (var i in invoicelist) {
          _invoices.add(
            new Invoice(
                id: i["id"],
                invoice_date:
                    i["invoice_date"] is! bool ? i["invoice_date"] : "N/A",
                payment_reference: i["payment_reference"] is! bool
                    ? i["payment_reference"]
                    : "N/A",
                journal_id: i['journal_id'] is! bool ? i['journal_id'] : "",
                currency_id: i['currency_id'] is! bool ? i['currency_id'] : "",
                invoice_payment_term_id: i['invoice_payment_term_id'] is! bool
                    ? i['invoice_payment_term_id']
                    : "",
                edi_state: i['edi_state'] is! bool ? i['edi_state'] : "",
                invoice_user_id:
                    i['invoice_user_id'] is! bool ? i['invoice_user_id'] : "",
                picking_type_id:
                    i['picking_type_id'] is! bool ? i['picking_type_id'] : "",
                team_id: i['team_id'] is! bool ? i['team_id'] : "",
                // ref: i['ref'] is! bool ? i['ref'] : "-",
                // amount_untaxed: i['amount_untaxed'] is! bool
                //     ? i['amount_untaxed'].toString()
                //     : "",
                // amount_tax: i['amount_tax'] is! bool
                //     ? i['amount_tax'].toString()
                //     : "",
                // amount_due: i['amount_residual'] is! bool
                //     ? i['amount_residual'].toString()
                //     : "",
                line_ids: i['line_ids'] is! bool ? i['line_ids'] : [],
                amount_total:
                    i["amount_total"] is! bool ? i["amount_total"] : "N/A",
                amount_residual: i["amount_residual"] is! bool
                    ? i["amount_residual"]
                    : "N/A",
                state: i['state'] is! bool ? i['state'] : "-",
                partner_id: i["partner_id"],
                payment_state:
                    i['payment_state'] is! bool ? i['payment_state'] : "-"),
          );
        }
      });
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          odoo.searchRead(Strings.account_move, [
            ['state', '=', 'draft'],
            ['move_type', "=", 'out_invoice'],
            ['invoice_user_id', "ilike", '$fullname']
          ], [
            'id',
            // 'invoice_date',
            'payment_reference',
            'line_ids',
            // 'amount_total',
            // 'amount_residual',
            // 'state',
            // 'move_type',
            // 'partner_id',
            // 'payment_state'
          ]).then(
            (OdooResponse res) {
              if (!res.hasError()) {
                setState(() {
                  hideLoading();
                  String session = getSession();
                  session = session.split(",")[0].split(";")[0];
                  for (var i in res.getRecords()) {
                    _invoices.add(
                      new Invoice(
                          id: i["id"],
                          invoice_date: i["invoice_date"] is! bool
                              ? i["invoice_date"]
                              : "N/A",
                          payment_reference: i["payment_reference"] is! bool
                              ? i["payment_reference"]
                              : "N/A",
                          journal_id:
                              i['journal_id'] is! bool ? i['journal_id'] : "",
                          currency_id:
                              i['currency_id'] is! bool ? i['currency_id'] : "",
                          invoice_payment_term_id:
                              i['invoice_payment_term_id'] is! bool
                                  ? i['invoice_payment_term_id']
                                  : "",
                          edi_state:
                              i['edi_state'] is! bool ? i['edi_state'] : "",
                          invoice_user_id: i['invoice_user_id'] is! bool
                              ? i['invoice_user_id']
                              : "",
                          amount_tax:
                              i['amount_tax'] is! bool ? i['amount_tax'] : "",
                          amount_untaxed:
                              i['amount_tax'] is! bool ? i['amount_tax'] : "",
                          picking_type_id: i['picking_type_id'] is! bool
                              ? i['picking_type_id']
                              : "",
                          team_id: i['team_id'] is! bool ? i['team_id'] : "",
                          line_ids: i['line_ids'] is! bool ? i['line_ids'] : [],
                          amount_total: i["amount_total"] is! bool
                              ? i["amount_total"]
                              : "N/A",
                          amount_residual: i["amount_residual"] is! bool
                              ? i["amount_residual"]
                              : "N/A",
                          state: i['state'] is! bool ? i['state'] : "-",
                          partner_id: i["partner_id"],
                          payment_state: i['payment_state'] is! bool
                              ? i['payment_state']
                              : "-"),
                    );
                  }
                });
                var invoicelist = jsonEncode(res.getRecords());
                preference.setString("offlinedraftinvoices", invoicelist);
                preference.setString("offlinedraftinvoiceslastupdated",
                    DateTime.now().toString());
                print("Updated offline draft invoice repository at " +
                    DateTime.now().toString());
              } else {
                print(res.getError());
                showMessage("Warning", res.getErrorMessage());
              }
            },
          );
        } else {
          print("No offline draft invoices saved");
        }
      });
    }
  }

  //GET INVOICE LINES
  _getInvoiceLines() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        odoo.searchRead(Strings.account_move_line, [
          ['product_id', "!=", false],
          ['product_uom_id', "!=", false],
        ], [
          'id',
          'price_unit',
          'product_id',
          'price_total',
          'quantity',
          'product_uom_id',
          'account_id'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  _invoiceLines.add(
                    new InvoiceLine(
                      id: i["id"],
                      quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
                      price_total:
                          i["price_total"] is! bool ? i["price_total"] : 0.0,
                      price_unit:
                          i["price_unit"] is! bool ? i["price_unit"] : 0.0,
                      name: i["product_id"] is! bool
                          ? i["product_id"][1]
                          : "Unkown",
                      product_uom_id: i["product_uom_id"] is! bool
                          ? i["product_uom_id"]
                          : "pcs",
                      account_id:
                          i["account_id"] is! bool ? i["account_id"] : [],
                    ),
                  );
                }
              });
              var invoicelineslist = jsonEncode(res.getRecords());
              preference.setString("offlineinvoicelines", invoicelineslist);
              preference.setString(
                  "offlineinvoicelineslastupdated", DateTime.now().toString());
              print("Updated offline invoice lines repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        print("Failed to update offline invoice lines. Device Offline.");
      }
    });
  }

  Future<void> _refreshInvoices() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.account_move, [
          ['state', '=', 'draft'],
          ['move_type', "=", 'out_invoice'],
          ['invoice_user_id', "ilike", '$fullname']
        ], [
          'id',
          // 'invoice_date',
          'payment_reference',
          'line_ids',
          // 'amount_total',
          // 'amount_residual',
          // 'state',
          // 'move_type',
          // 'partner_id',
          // 'payment_state'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  _invoices.add(
                    new Invoice(
                        id: i["id"],
                        invoice_date: i["invoice_date"] is! bool
                            ? i["invoice_date"]
                            : "N/A",
                        payment_reference: i["payment_reference"] is! bool
                            ? i["payment_reference"]
                            : "N/A",
                        journal_id:
                            i['journal_id'] is! bool ? i['journal_id'] : "",
                        currency_id:
                            i['currency_id'] is! bool ? i['currency_id'] : "",
                        invoice_payment_term_id:
                            i['invoice_payment_term_id'] is! bool
                                ? i['invoice_payment_term_id']
                                : "",
                        edi_state:
                            i['edi_state'] is! bool ? i['edi_state'] : "",
                        invoice_user_id: i['invoice_user_id'] is! bool
                            ? i['invoice_user_id']
                            : "",
                        amount_tax:
                            i['amount_tax'] is! bool ? i['amount_tax'] : "",
                        amount_untaxed:
                            i['amount_tax'] is! bool ? i['amount_tax'] : "",
                        picking_type_id: i['picking_type_id'] is! bool
                            ? i['picking_type_id']
                            : "",
                        team_id: i['team_id'] is! bool ? i['team_id'] : "",
                        line_ids: i['line_ids'] is! bool ? i['line_ids'] : [],
                        amount_total: i["amount_total"] is! bool
                            ? i["amount_total"]
                            : "N/A",
                        amount_residual: i["amount_residual"] is! bool
                            ? i["amount_residual"]
                            : "N/A",
                        state: i['state'] is! bool ? i['state'] : "-",
                        partner_id: i["partner_id"],
                        payment_state: i['payment_state'] is! bool
                            ? i['payment_state']
                            : "-"),
                  );
                }
              });
              var invoicelist = jsonEncode(res.getRecords());
              preference.setString("offlinedraftinvoices", invoicelist);
              preference.setString(
                  "offlinedraftinvoiceslastupdated", DateTime.now().toString());
              print("Updated offline draft invoice repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        print("No offline draft invoices saved");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getOdooInstance().then((odoo) {
      _getInvoices();
      _getInvoiceLines();
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
                    Strings.no_orders,
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
        title: Text("Invoices"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_box_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              push(AddInvoice());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _refreshInvoices();
          _getInvoiceLines();
        },
        // label: const Text(''),
        child: const Icon(Icons.replay),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _invoices.length > 0
          ? Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: _invoices.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    push(InvoiceDetails(data: _invoices[i]));
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            _invoices[i].partner_id != null
                                                ? _invoices[i].partner_id[1]
                                                : "/",
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            _invoices[i].invoice_date != null
                                                ? _invoices[i].invoice_date
                                                : "-",
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            _invoices[i].amount_total != null
                                                ? (" ${value.format(_invoices[i].amount_total)}")
                                                : "0",
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.underline),
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
                                        //     _invoices[i].state.toLowerCase() ==
                                        //             "draft"
                                        //         ? Colors.amber
                                        //         : _invoices[i]
                                        //                     .state
                                        //                     .toLowerCase() ==
                                        //                 "cancel"
                                        //             ? Colors.red
                                        //             : Color(0xff00a09d),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0.0),
                                              child: _invoices[i]
                                                          .state
                                                          .toLowerCase() ==
                                                      "draft"
                                                  ? Icon(
                                                      Icons.hourglass_bottom,
                                                      color: Colors.white,
                                                      size: 14,
                                                    )
                                                  : _invoices[i]
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
                                                _invoices[i]
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (_invoices[i]
                                                .payment_state
                                                .toLowerCase() ==
                                            "paid" ||
                                        _invoices[i]
                                                .payment_state
                                                .toLowerCase() ==
                                            "partial")
                                      Container(
                                        height: 25,
                                        width: 90,
                                        child: TextButton(
                                          // textColor: Colors.white,
                                          // height: 60.0,
                                          // color: _invoices[i]
                                          //             .payment_state
                                          //             .toLowerCase() ==
                                          //         "paid"
                                          //     ? Colors.green
                                          //     : Color(0xff00a09d),
                                          onPressed: () {},
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0.0),
                                                child: _invoices[i]
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
                                                  _invoices[i]
                                                      .payment_state
                                                      .toUpperCase(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      TextStyle(fontSize: 10),
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
