class EmployeeStock {
  int id;
  List product_id;
  List categ_id;
  List report_id;
  double quantity_in;
  double quantity_out;
  double amount_begin;
  double amount_adjust;
  double amount_finish;
  double quantity_begin;
  double quantity_adjust;
  double quantity_finish;
  double amount_in;
  double amount_out;

  EmployeeStock({
    this.id,
    this.product_id,
    this.categ_id,
    this.report_id,
    this.quantity_in,
    this.quantity_out,
    this.quantity_adjust,
    this.quantity_begin,
    this.quantity_finish,
    this.amount_begin,
    this.amount_adjust,
    this.amount_finish,
    this.amount_in,
    this.amount_out,
  });
}
