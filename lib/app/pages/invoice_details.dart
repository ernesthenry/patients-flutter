import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/accounts.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/currencies.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoices.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoicelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/journals.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/partners.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceDetails extends StatefulWidget {
  InvoiceDetails({this.data});

  final data;

  @override
  _InvoiceDetailsState createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends Base<InvoiceDetails>
    with SingleTickerProviderStateMixin {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<InvoiceLine> _invoiceLines = [];
  String name = "";
  String image_URL = "";
  String email = "";
  List partner_id = [];
  var invoice_user_id = "";
  var team_id = "";
  var payment_reference = "";
  var invoice_date = "";
  var invoice_payment_term_id = "";
  var picking_type_id = "";
  var edi_state = "";
  var journal_id = "";
  var account_id = "";
  var currency_id = "";
  var state = "";
  var payment_state = "";
  var country = "";
  var ref = "",
      amount_total = "0",
      amount_residual = "0",
      amount_tax = "0",
      amount_untaxed = "0",
      amount_due = "0",
      line_ids = [],
      parish = "",
      village_name = "";
  var _journalId;
  var _accountId;
  var _currencyId;
  Invoice _invoice;
  List<Journal> journals = [];
  List<Currency> currencies = [];
  List<Account> bankAccounts = [];
  TextEditingController _amountController = new TextEditingController();
  TextEditingController _memoController = new TextEditingController();
  TextEditingController _paymentDateController = new TextEditingController();
  String _bankSelection = "Select Bank Acct",
      _journalSelection = "Select Journal",
      _currencySelection = "Select Currency";
  TabController _controller;
  var _selectedIndex = 0;
  List<Widget> list = [
    Tab(
      text: 'Invoice Lines',
    ),
    Tab(text: 'Other Info'),
  ];
  final List<Map<String, String>> listOfColumns = [
    {"Product": "AAAAAA", "Qty": "1", "Subtotal": "0"},
    {"Product": "BBBBBB", "Qty": "3", "Subtotal": "0"},
    {"Product": "CCCCCC", "Qty": "2", "Subtotal": "0"}
  ];

  @override
  void initState() {
    super.initState();

    _invoice = widget.data;
    _controller = TabController(length: list.length, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });

    getOdooInstance().then((odoo) {
      _getInvoiceData();
    });
  }

  _getInvoiceData() async {
    setState(() {
      _invoiceLines = [];
      name = _invoice.payment_reference;
      state = _invoice.state;
      payment_state = _invoice.payment_state;
      partner_id = _invoice.partner_id;
      invoice_date = _invoice.invoice_date;
      journal_id = _invoice.journal_id;
      currency_id = _invoice.currency_id;
      invoice_payment_term_id = _invoice.invoice_payment_term_id;
      edi_state = _invoice.edi_state;
      invoice_user_id = _invoice.invoice_user_id;
      picking_type_id = _invoice.picking_type_id;
      team_id = _invoice.team_id;
      ref = _invoice.payment_reference;
      amount_untaxed = _invoice.amount_untaxed.toString();
      amount_tax = _invoice.amount_tax.toString();
      amount_total = _invoice.amount_total.toString();
      amount_due = _invoice.amount_residual.toString();
      line_ids = _invoice.line_ids;
      print("========================================");
      print("The line ids are " + _invoice.line_ids.toString());
      print("========================================");
    });

    if (_invoice.line_ids.toString().isNotEmpty) {
      print("The line ids are " + _invoice.line_ids.toString());
      var invoicelines = jsonDecode(jsonEncode(_invoice.line_ids.toString()));
      // var decodedinvoicelines = json.decode(invoicelines);
      print("The invoice line ids are " + invoicelines.toString());
      for (var i in _invoice.line_ids) {
        print("Getting data for line " + i.toString());
        _getInvoiceLineData(i);
      }
    }
    isConnected().then((isInternet) {
      if (isInternet) {
        odoo.searchRead(Strings.account_move, [
          ["id", "=", _invoice.id]
        ], []).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                _invoiceLines = [];
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                final result = res.getResult()['records'][0];
                name = result['name'] is! bool ? result['name'] : "-";
                state = result['state'] is! bool ? result['state'] : "-";
                payment_state = result['payment_state'] is! bool
                    ? result['payment_state']
                    : "-";
                partner_id = result["partner_id"];
                invoice_date = result['invoice_date'] is! bool
                    ? result['invoice_date']
                    : "-";
                journal_id = result['journal_id'] is! bool
                    ? result['journal_id'][1]
                    : "";
                currency_id = result['currency_id'] is! bool
                    ? result['currency_id'][1]
                    : "";
                invoice_payment_term_id =
                    result['invoice_payment_term_id'] is! bool
                        ? result['invoice_payment_term_id'][1]
                        : "";
                edi_state =
                    result['edi_state'] is! bool ? result['edi_state'] : "";
                invoice_user_id = result['invoice_user_id'] is! bool
                    ? result['invoice_user_id'][1]
                    : "";
                picking_type_id = result['picking_type_id'] is! bool
                    ? result['picking_type_id'][1]
                    : "";
                team_id =
                    result['team_id'] is! bool ? result['team_id'][1] : "";
                ref = result['ref'] is! bool ? result['ref'] : "-";
                amount_untaxed = result['amount_untaxed'] is! bool
                    ? result['amount_untaxed'].toString()
                    : "";
                amount_tax = result['amount_tax'] is! bool
                    ? result['amount_tax'].toString()
                    : "";
                amount_total = result['amount_total'] is! bool
                    ? result['amount_total'].toString()
                    : "";
                amount_due = result['amount_residual'] is! bool
                    ? result['amount_residual'].toString()
                    : "";
                line_ids =
                    result['line_ids'] is! bool ? result['line_ids'] : [];
              });
              if (line_ids.isNotEmpty) {
                var invoicelines = jsonDecode(jsonEncode(line_ids));
                // var decodedinvoicelines = json.decode(invoicelines);
                print("The invoice line ids are " + invoicelines.toString());
                for (var i in invoicelines) {
                  print("Getting data for line " + i.toString());
                  _getInvoiceLineData(i);
                }
              }
            }
          },
        );
      } else {
        setState(() {
          _invoiceLines = [];
          name = _invoice.payment_reference;
          state = _invoice.state;
          payment_state = _invoice.payment_state;
          partner_id = _invoice.partner_id;
          invoice_date = _invoice.invoice_date;
          journal_id = _invoice.journal_id;
          currency_id = _invoice.currency_id;
          invoice_payment_term_id = _invoice.invoice_payment_term_id;
          edi_state = _invoice.edi_state;
          invoice_user_id = _invoice.invoice_user_id;
          picking_type_id = _invoice.picking_type_id;
          team_id = _invoice.team_id;
          ref = _invoice.payment_reference;
          amount_untaxed = _invoice.amount_untaxed.toString();
          amount_tax = _invoice.amount_tax.toString();
          amount_total = _invoice.amount_total.toString();
          amount_due = _invoice.amount_residual.toString();
          line_ids = _invoice.line_ids;
        });
      }
    });
  }

  _getInvoiceLineData(int _lineId) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlineinvoicelines") != null) {
      print(preference.getString("offlineinvoicelines"));
      var invoicelinelist =
          json.decode(preference.getString("offlineinvoicelines"));
      setState(() {
        for (var i in invoicelinelist) {
          if (i["id"] == _lineId) {
            _invoiceLines.add(new InvoiceLine(
              id: i["id"],
              quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
              price_total: i["price_total"] is! bool ? i["price_total"] : 0.0,
              price_unit: i["price_unit"] is! bool ? i["price_unit"] : 0.0,
              name: i["product_id"] is! bool ? i["product_id"][1] : "Unkown",
            ));
          }
        }
      });
    }
    // isConnected().then((isInternet) {
    //   if (isInternet) {
    //     showLoading();
    //     odoo.searchRead(Strings.account_move_line, [
    //       ['id', "=", _lineId],
    //       ['product_id', "!=", false],
    //     ], [
    //       'product_id',
    //       'quantity',
    //       'price_subtotal'
    //     ]).then(
    //       (OdooResponse res) {
    //         if (!res.hasError()) {
    //           setState(() {
    //             hideLoading();
    //             String session = getSession();
    //             session = session.split(",")[0].split(";")[0];
    //             final result = res.getResult()['records'][0];
    //             _invoiceLines.add(
    //               new InvoiceLine(
    //                 id: result["id"],
    //                 quantity:
    //                     result["quantity"] is! bool ? result["quantity"] : 1.0,
    //                 price_subtotal: result["price_subtotal"] is! bool
    //                     ? result["price_subtotal"]
    //                     : 0.0,
    //                 price_unit: result["price_unit"] is! bool
    //                     ? result["price_unit"]
    //                     : 0.0,
    //                 name: result["product_id"] is! bool
    //                     ? result["product_id"][1]
    //                     : "Unkown",
    //                 // product_uom_id: result["product_uom_id"] is! bool
    //                 //     ? result["product_uom_id"][1]
    //                 //     : "pcs",
    //               ),
    //             );
    //             // _invoiceLines.add(
    //             //   new InvoiceLine(
    //             //     id: result["id"],
    //             //     quantity:
    //             //         result["quantity"] is! bool ? result["quantity"] : 0,
    //             //     name: result["name"].toString(),
    //             //     product_id: result["product_id"] is! bool
    //             //         ? result["product_id"][1]
    //             //         : "-",
    //             //     tax_ids:
    //             //         result["tax_ids"] is! bool ? result["tax_ids"][1] : "-",
    //             //     product_uom_id: result["product_uom_id"] is! bool
    //             //         ? result["product_uom_id"][1]
    //             //         : "-",
    //             //     price_subtotal: result["price_subtotal"] is! bool
    //             //         ? result["price_subtotal"]
    //             //         : 0,
    //             //     price_unit: result["price_unit"] is! bool
    //             //         ? result["price_unit"]
    //             //         : 0,
    //             //   ),
    //             // );
    //           });
    //         } else {
    //           print(res.getError());
    //           showMessage("Warning", res.getErrorMessage());
    //         }
    //       },
    //     );
    //   } else {
    //     if (preference.getString("offlineinvoicelines") != null) {
    //       print(preference.getString("offlineinvoicelines"));
    //       var invoicelinelist =
    //           json.decode(preference.getString("offlineinvoicelines"));
    //       setState(() {
    //         for (var i in invoicelinelist) {
    //           _invoiceLines.add(new InvoiceLine(
    //             id: i["id"],
    //             quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
    //             price_subtotal:
    //                 i["price_subtotal"] is! bool ? i["price_subtotal"] : 0.0,
    //             price_unit: i["price_unit"] is! bool ? i["price_unit"] : 0.0,
    //             name: i["product_id"] is! bool ? i["product_id"][1] : "Unkown",
    //           ));
    //         }
    //       });
    //     }
    //   }
    // });
  }

  _postInvoice() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.account_move,
          "action_post",
          [_invoice.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("POSTED INVOICE");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) {
                _getInvoiceData();
              });
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _returnInvoiceToDraft() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.account_move,
          "button_draft",
          [_invoice.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("RETURNED INVOICE TO DRAFT");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) {
                _getInvoiceData();
              });
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _cancelInvoice() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.account_move,
          "button_cancel",
          [_invoice.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("CANCELLED INVOICE");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) {
                _getInvoiceData();
              });
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  // _saveInvoice(
  //     // accountName, region, district, parish, subCounty, village, email,
  //     //   phone
  //     ) async {
  //   isConnected().then((isInternet) {
  //     if (isInternet) {
  //       showLoading();
  //       odoo.create(Strings.account_move, {
  //         "partner_id": _partnerId,
  //         "invoice_user_id": _userId,
  //         "invoice_payment_term_id": _termId,
  //         "payment_reference": _paymentRefController.text,
  //         "invoice_date": _invoiceDateController.text,
  //         "invoice_date_due": _dueDateController.text,
  //         "move_type": "out_invoice",
  //         "stock_move_direct": true
  //       }).then(
  //         (OdooResponse res) {
  //           if (!res.hasError()) {
  //             var moveId = jsonDecode(res.getResult().toString());
  //             print("THE MOVE ID IS" + moveId.toString());
  //             for (var i in _invoiceLines) {
  //               int count = 0;
  //               odoo.create(Strings.account_move_line, {
  //                 "invoice_ids": [
  //                   [4, "Invoice Id", 'None']
  //                 ],
  //                 "default_invoice_ids": [
  //                   [4, "Invoice Id", 'None']
  //                 ],
  //                 "amount": 'Amount',
  //                 "payment_date": '2019-05-21 02:55:52',
  //                 "payment_type": 'inbound',
  //                 "has_invoices": true,
  //                 "currency_id": 1,
  //                 "journal_id": 6,
  //                 "payment_method_id": 1,
  //                 "partner_id": 226,
  //                 "partner_type": 'customer',
  //                 "communication": 'INV/2019/0141/44',
  //                 "name": 'INV/2019/0141/44'
  //               }).then(
  //                 (OdooResponse res) {
  //                   if (!res.hasError()) {
  //                     count++;
  //                     print("CREATED INVOICE LINE " + count.toString());
  //                   } else {
  //                     print(res.getError());
  //                     showMessage("Warning", res.getErrorMessage());
  //                   }
  //                 },
  //               );
  //             }
  //             showMessage("Success", "Invoice created successfully");
  //           } else {
  //             print(res.getError());
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
  //     }
  //   });
  // }

  _registerPayment() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        // odoo.callKW(
        //   "account.payment",
        //   "action_validate_invoice_payment",
        //   [
        //     {
        //       'invoice_ids': [
        //         [_invoice.id]
        //       ],
        //       'default_invoice_ids': [
        //         [_invoice.id]
        //       ],
        //       'amount': '50000',
        //       'payment_date': '2021-07-07 02:55:52',
        //       'payment_type': 'inbound',
        //       'has_invoices': true,
        //       'currency_id': 1,
        //       'journal_id': 6,
        //       'payment_method_id': 1,
        //       'partner_id': 226,
        //       'partner_type': 'customer',
        //       'communication': 'INV/2019/0141/44',
        //       'name': 'INV/2019/0141/44'
        //     }
        //     // _journalId,
        //     // _accountId,
        //     // double.tryParse(_amountController.text),
        //     // _currencyId,
        //     // _paymentDateController.text,
        //     // _memoController.text
        //   ],
        // )
        var dict;
        if (_amountController.text == amount_total) {
          dict = {
            "amount_untaxed": amount_untaxed,
            "amount_tax": amount_tax,
            "amount": amount_total,
            "amount_total": amount_total,
            // "amount_residual": amount_due,
            "partner_type": "customer",
            "auto_post": true,
            "payment_type": "inbound",
            "partner_id": partner_id[0],
            "date": "2021-07-25",
            "ref": name,
          };
        } else {
          dict = {
            "amount": _amountController.text,
            "amount_total": _amountController.text,
            "partner_type": "customer",
            "auto_post": true,
            "payment_type": "inbound",
            "partner_id": partner_id[0],
            "date": "2021-07-25",
            "ref": name,
          };
        }
        odoo.create("account.payment", {}).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("REGISTERED PAYMENT");
              print("++++++++++++++++++++++");
              showMessage("Success", "Payment added successfully!");
              getOdooInstance().then((odoo) {
                _getInvoiceData();
              });
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
  Widget build(BuildContext context) {
    final upper_header = Container(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.toString().length > 1)
                    Container(
                      height: 25,
                      width: 90,
                      child: TextButton(
                        // textColor: Colors.white,
                        // height: 60.0,
                        // color: state.toLowerCase() == "draft"
                        //     ? Colors.amber
                        //     : state.toLowerCase() == "cancel"
                        //         ? Colors.red
                        //         : Colors.green,
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 0.0),
                              child: state.toLowerCase() == "draft"
                                  ? Icon(
                                      Icons.hourglass_bottom,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : state.toLowerCase() == "cancel"
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
                                state.toUpperCase(),
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
              SizedBox(
                height: 6,
              ),
              if (payment_state.toLowerCase() == "paid" ||
                  payment_state.toLowerCase() == "partial")
                ClipRRect(
                  child: Banner(
                    message: payment_state.toLowerCase() == "paid"
                        ? "PAID"
                        : "PARTIAL",
                    location: BannerLocation.topEnd,
                    color: Colors.green,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Customer:",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  partner_id[1],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Text(
                                "Payment Ref:",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Text(
                                "Invoice Date:",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                invoice_date,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       "Due Date:",
                          //       style: TextStyle(color: Colors.white),
                          //     ),
                          //     SizedBox(
                          //       width: 5,
                          //     ),
                          //     Text(
                          //       invoice_payment_term_id != null
                          //           ? invoice_payment_term_id
                          //           : "",
                          //       style: TextStyle(
                          //           color: Colors.white,
                          //           fontWeight: FontWeight.bold),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(
                          //   height: 6,
                          // ),
                          Row(
                            children: [
                              Text(
                                "Picking Type:",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  picking_type_id != null
                                      ? picking_type_id
                                      : "",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Text(
                                "Journal:",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                journal_id != null ? journal_id : "",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " in ",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                currency_id != null ? currency_id : "",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Text(
                                "Electronic Invoicing:",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "",
                                // edi_state,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (payment_state.toLowerCase() != "paid")
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Customer:",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              partner_id[1],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            "Payment Ref:",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            name,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            "Invoice Date:",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            invoice_date,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       "Due Date:",
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //     SizedBox(
                      //       width: 5,
                      //     ),
                      //     Text(
                      //       invoice_payment_term_id != null
                      //           ? invoice_payment_term_id
                      //           : "",
                      //       style: TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 6,
                      // ),
                      Row(
                        children: [
                          Text(
                            "Picking Type:",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              picking_type_id != null ? picking_type_id : "",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            "Journal:",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            journal_id != null ? journal_id : "",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            " in ",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            currency_id != null ? currency_id : "",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            "Electronic Invoicing:",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            edi_state != null ? edi_state : "",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final lower = Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            unselectedLabelColor: Colors.grey[700],
            labelColor: Color(0xff00a09d),
            indicatorColor: Color(0xff00a09d),
            tabs: [
              Tab(
                text: "Invoice Lines",
              ),
              Tab(
                text: "Other Info",
              ),
            ],
            controller: _controller,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.42,
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DataTable(
                        showBottomBorder: true,
                        columnSpacing: 10,
                        // dataRowHeight: 1,
                        columns: [
                          DataColumn(label: Text('Product')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Subtotal')),
                          DataColumn(label: Text('More')),
                        ],
                        rows:
                            _invoiceLines // Loops through dataColumnText, each iteration assigning the value to element
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(element.name.toString() +
                                          " " +
                                          element.product_uom_id
                                              .toString())), //Extracting from Map element the value
                                      DataCell(
                                          Text(element.quantity.toString())),
                                      DataCell(
                                          Text(element.price_total.toString())),
                                      DataCell(
                                        new IconButton(
                                            icon: new Icon(
                                              Icons.more,
                                              color: Color(0xff00a09d),
                                              size: 16,
                                            ),
                                            onPressed: null),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Untaxed Amount:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    amount_untaxed,
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Tax:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    amount_tax,
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Divider(
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Total:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    amount_total,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              if (payment_state.toLowerCase() == "partial")
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                              if (payment_state.toLowerCase() == "partial")
                                Row(
                                  children: [
                                    Text(
                                      "Amount Due:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      amount_due,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     if (state.toString().length > 1 &&
                      //         state.toLowerCase() != "draft" &&
                      //         payment_state.toLowerCase() != "paid")
                      //       Container(
                      //         height: 35,
                      //         width: 100,
                      //         child: TextButton(
                      //           textColor: Color(0xff00a09d),
                      //           height: 60.0,
                      //           color: Colors.grey[300],
                      //           onPressed: () {
                      //             _returnInvoiceToDraft();
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceEvenly,
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     vertical: 0.0),
                      //                 child: Icon(
                      //                   Icons.undo,
                      //                   color: Color(0xff00a09d),
                      //                   size: 18,
                      //                 ),
                      //               ),
                      //               SizedBox(
                      //                 width: 5,
                      //               ),
                      //               Container(
                      //                 width: 40,
                      //                 child: Text(
                      //                   "Draft",
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: TextStyle(
                      //                       fontSize: 14,
                      //                       color: Color(0xff00a09d)),
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     if (state.toLowerCase() == "draft")
                      //       Container(
                      //         height: 35,
                      //         width: 120,
                      //         child: TextButton(
                      //           textColor: Colors.white,
                      //           height: 60.0,
                      //           color: Color(0xff00a09d),
                      //           onPressed: () {
                      //             _postInvoice();
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceEvenly,
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     vertical: 0.0),
                      //                 child: Icon(
                      //                   Icons.check_box,
                      //                   color: Colors.white,
                      //                   size: 18,
                      //                 ),
                      //               ),
                      //               SizedBox(
                      //                 width: 5,
                      //               ),
                      //               Container(
                      //                 width: 60,
                      //                 child: Text(
                      //                   "Confirm",
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: TextStyle(fontSize: 14),
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     if (state.toLowerCase() == "posted" &&
                      //         payment_state.toLowerCase() != "paid")
                      //       Container(
                      //         height: 35,
                      //         width: 120,
                      //         child: TextButton(
                      //           textColor: Colors.white,
                      //           height: 60.0,
                      //           color: Color(0xff00a09d),
                      //           onPressed: () {
                      //             _addPayment();
                      //             setState(() {
                      //               _amountController.text = amount_due;
                      //             });
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceEvenly,
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     vertical: 0.0),
                      //                 child: Icon(
                      //                   Icons.add_circle,
                      //                   color: Colors.white,
                      //                   size: 18,
                      //                 ),
                      //               ),
                      //               SizedBox(
                      //                 width: 5,
                      //               ),
                      //               Container(
                      //                 width: 60,
                      //                 child: Text(
                      //                   "Payment",
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: TextStyle(fontSize: 14),
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     if (state.toLowerCase() == "draft")
                      //       Container(
                      //         height: 35,
                      //         width: 100,
                      //         child: TextButton(
                      //           textColor: Colors.red,
                      //           height: 60.0,
                      //           color: Colors.grey[300],
                      //           onPressed: () {
                      //             _cancelInvoice();
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceEvenly,
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     vertical: 0.0),
                      //                 child: Icon(
                      //                   Icons.cancel,
                      //                   color: Colors.red,
                      //                   size: 18,
                      //                 ),
                      //               ),
                      //               SizedBox(
                      //                 width: 5,
                      //               ),
                      //               Container(
                      //                 width: 45,
                      //                 child: Text(
                      //                   "Cancel",
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: TextStyle(
                      //                       fontSize: 14, color: Colors.red),
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer Reference",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Salesperson",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Sales Team",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: VerticalDivider(
                            color: Colors.grey[400],
                            thickness: 1,
                          ),
                          height: 200,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "",
                              // invoice_user_id,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "",
                              // team_id,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.35,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(background: upper_header),
            ),
          ];
        },
        body: lower,
      ),
    );
  }

  _addPayment() async {
    hideLoading();
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            title: Text(
              "Register Payment",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _journalSelection,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              items: journals.map((item) {
                                return new DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      new Text(
                                        item.display_name,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  value: item.id,
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                List itemsList = journals.map((item) {
                                  if (item.id == newVal) {
                                    setState(() {
                                      _journalSelection = item.display_name;
                                      _journalId = item.id;
                                      print(_journalSelection);
                                      print(_journalId);
                                    });
                                  }
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: DropdownButton(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      _bankSelection,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                items: bankAccounts.map((item) {
                                  return new DropdownMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        new Text(
                                          item.name,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    value: item.id,
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  List itemsList = bankAccounts.map((item) {
                                    if (item.id == newVal) {
                                      setState(() {
                                        _bankSelection = item.name;
                                        _accountId = item.id;
                                        print(_bankSelection);
                                        print(_accountId);
                                      });
                                    }
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Amount",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.calculate,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 3),
                    //   child: Container(
                    //     margin: EdgeInsets.only(bottom: 15),
                    //     width: double.infinity,
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
                    //                   Icons.monetization_on,
                    //                   color: Theme.of(context).primaryColor,
                    //                 ),
                    //                 SizedBox(
                    //                   width: 10,
                    //                 ),
                    //                 Text(
                    //                   _currencySelection,
                    //                   style: TextStyle(
                    //                       color: Colors.grey,
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.w400),
                    //                 ),
                    //               ],
                    //             ),
                    //             items: currencies.map((item) {
                    //               return new DropdownMenuItem(
                    //                 child: Row(
                    //                   children: [
                    //                     Icon(
                    //                       Icons.account_balance,
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
                    //               List itemsList = currencies.map((item) {
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
                    //   padding: const EdgeInsets.symmetric(horizontal: 3),
                    //   child: Container(
                    //     margin: EdgeInsets.only(bottom: 15),
                    //     width: double.infinity,
                    //     decoration: customDecoration(),
                    //     child: TextFormField(
                    //       controller: _paymentDateController,
                    //       keyboardType: TextInputType.number,
                    //       decoration: InputDecoration(
                    //         hintText: "Payment Date",
                    //         border: InputBorder.none,
                    //         hintStyle: TextStyle(color: Colors.grey),
                    //         prefixIcon: Icon(
                    //           Icons.date_range,
                    //           color: Theme.of(context).primaryColor,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 3),
                    //   child: Container(
                    //     margin: EdgeInsets.only(bottom: 15),
                    //     width: double.infinity,
                    //     decoration: customDecoration(),
                    //     child: TextFormField(
                    //       controller: _memoController,
                    //       keyboardType: TextInputType.number,
                    //       decoration: InputDecoration(
                    //         hintText: "Memo",
                    //         border: InputBorder.none,
                    //         hintStyle: TextStyle(color: Colors.grey),
                    //         prefixIcon: Icon(
                    //           Icons.edit,
                    //           color: Theme.of(context).primaryColor,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              Container(
                height: 35,
                width: 100,
                child: TextButton(
                  // textColor: Color(0xff00a09d),
                  // height: 60.0,
                  // color: Colors.grey[300],
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          "Cancel",
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff00a09d)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: 35,
                width: 100,
                child: TextButton(
                  // textColor: Colors.white,
                  
                  // height: 60.0,
                  // color: Color(0xff00a09d),
                  onPressed: () {
                    Navigator.pop(context);
                    _registerPayment();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          "Create",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return CupertinoAlertDialog(
            title: Text(
              "Add Invoice Line",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _journalSelection,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              items: journals.map((item) {
                                return new DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      new Text(
                                        item.display_name,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  value: item.id,
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                List itemsList = journals.map((item) {
                                  if (item.id == newVal) {
                                    setState(() {
                                      _journalSelection = item.display_name;
                                      _journalId = item.id;
                                      print(_journalSelection);
                                      print(_journalId);
                                    });
                                  }
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: DropdownButton(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      _bankSelection,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                items: bankAccounts.map((item) {
                                  return new DropdownMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        new Text(
                                          item.name,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    value: item.id,
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  List itemsList = bankAccounts.map((item) {
                                    if (item.id == newVal) {
                                      setState(() {
                                        _bankSelection = item.name;
                                        _accountId = item.id;
                                        print(_bankSelection);
                                        print(_accountId);
                                      });
                                    }
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Amount",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.calculate,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: DropdownButton(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      _currencySelection,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                items: currencies.map((item) {
                                  return new DropdownMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        new Text(
                                          item.name,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    value: item.id,
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  List itemsList = currencies.map((item) {
                                    if (item.id == newVal) {
                                      setState(() {
                                        _currencySelection = item.name;
                                        _currencyId = item.id;
                                        print(_currencySelection);
                                        print(_currencyId);
                                      });
                                    }
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _paymentDateController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Payment Date",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _memoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Memo",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              Container(
                height: 35,
                width: 100,
                child: TextButton(
                  // textColor: Color(0xff00a09d),
                  // height: 60.0,
                  // color: Colors.grey[300],
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          "Cancel",
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff00a09d)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: 35,
                width: 100,
                child: TextButton(
                  // textColor: Colors.white,
                  // height: 60.0,
                  // color: Color(0xff00a09d),
                  onPressed: () {
                    _registerPayment();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          "Create",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
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
