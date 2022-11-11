class RequisitionLine {
  int id;
  List product_id;
  double quantity;
  List lot_id;
  List stock_req_id;
  String barcode;

  RequisitionLine({
    this.id,
    this.product_id,
    this.quantity,
    this.lot_id,
    this.stock_req_id,
    this.barcode,
  });
}
