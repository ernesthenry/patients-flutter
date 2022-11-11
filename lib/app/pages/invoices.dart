import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/delivery.dart';
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

List<Invoice> _invoices = [];
List<InvoiceLine> _invoiceLines = [];
List<StockPicking> _stockPickings = [];
final value = new NumberFormat("#,##0", "en_US");

class Invoices extends StatefulWidget {
  @override
  _InvoicesState createState() => _InvoicesState();
}

class _InvoicesState extends Base<Invoices> {
  //Odoo _odoo;
  String fullname;
  String _result;

  //GET STOCK PICKINGS
  _getStockPickings() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinestockpickings") != null) {
      print(preference.getString("offlinestockpickings"));
      var invoicelist =
          json.decode(preference.getString("offlinestockpickings"));
      setState(() {
        for (var i in invoicelist) {
          _stockPickings.add(
            new StockPicking(
              id: i["id"],
              state: i["state"] is! bool ? i["state"] : "N/A",
              location_id: i["location_id"] is! bool ? i["location_id"] : [],
              date_deadline:
                  i['date_deadline'] is! bool ? i['date_deadline'] : "",
              scheduled_date:
                  i['scheduled_date'] is! bool ? i['scheduled_date'] : "",
              move_ids_without_package: i['move_ids_without_package'] is! bool
                  ? i['move_ids_without_package']
                  : [],
              move_line_ids_without_package:
                  i['move_line_ids_without_package'] is! bool
                      ? i['move_line_ids_without_package']
                      : [],
              origin: i['origin'] is! bool ? i['origin'] : "-",
              partner_id: i["partner_id"],
            ),
          );
        }
      });
    }
  }

  _getInvoices() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      fullname = getUserFullName();
    });
    if (preference.getString("offlineinvoices") != null) {
      print(preference.getString("offlineinvoices"));
      var invoicelist = json.decode(preference.getString("offlineinvoices"));
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
            ['move_type', "=", 'out_invoice'],
            ['invoice_user_id', "ilike", '$fullname']
          ], [
            'id',
            'invoice_date',
            'payment_reference',
            'amount_total',
            'amount_residual',
            'state',
            'move_type',
            'partner_id',
            'payment_state'
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
                          partner_id: i["partner_id"][1],
                          payment_state: i['payment_state'] is! bool
                              ? i['payment_state']
                              : "-"),
                    );
                  }
                });
                var invoicelist = jsonEncode(res.getRecords());
                preference.setString("offlineinvoices", invoicelist);
                preference.setString(
                    "offlineinvoiceslastupdated", DateTime.now().toString());
                print("Updated offline invoice repository at " +
                    DateTime.now().toString());
              } else {
                print(res.getError());
                showMessage("Warning", res.getErrorMessage());
              }
            },
          );
        } else {
          if (preference.getString("offlineinvoices") != null) {
            print(preference.getString("offlineinvoices"));
            var invoicelist =
                json.decode(preference.getString("offlineinvoices"));
            setState(() {
              for (var i in invoicelist) {
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
                      edi_state: i['edi_state'] is! bool ? i['edi_state'] : "",
                      invoice_user_id: i['invoice_user_id'] is! bool
                          ? i['invoice_user_id']
                          : "",
                      picking_type_id: i['picking_type_id'] is! bool
                          ? i['picking_type_id']
                          : "",
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
                      amount_total: i["amount_total"] is! bool
                          ? i["amount_total"]
                          : "N/A",
                      amount_residual: i["amount_residual"] is! bool
                          ? i["amount_residual"]
                          : "N/A",
                      state: i['state'] is! bool ? i['state'] : "-",
                      partner_id: i["partner_id"][1],
                      payment_state: i['payment_state'] is! bool
                          ? i['payment_state']
                          : "-"),
                );
              }
            });
          }
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
          ['move_type', "=", 'out_invoice'],
          ['invoice_user_id', "ilike", '$fullname']
        ], [
          'id',
          'invoice_date',
          'payment_reference',
          'amount_total',
          'amount_residual',
          'state',
          'move_type',
          'partner_id',
          'payment_state'
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
              preference.setString("offlineinvoices", invoicelist);
              preference.setString(
                  "offlineinvoiceslastupdated", DateTime.now().toString());
              print("Updated offline invoice repository at " +
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

  @override
  void initState() {
    super.initState();

    getOdooInstance().then((odoo) {
      _getStockPickings();
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
        title: Text("Ship Stock"),
        actions: <Widget>[
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
                                            _invoices[i].partner_id[1],
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
                                            _invoices[i].invoice_date,
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
                                            (" ${value.format(_invoices[i].amount_total)}"),
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
      listToShow = _invoices
          .where((e) =>
              e.partner_id[1].toLowerCase().contains(query.toLowerCase()))
          .toList();
    // .where((e) => e.contains(query) && e.startsWith(query))
    // .toList();
    else
      listToShow = _invoices;

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
                                  listToShow[i].partner_id[1],
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
