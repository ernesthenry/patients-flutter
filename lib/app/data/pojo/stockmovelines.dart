class StockMoveLines {
  int id;
  List location_id;
  List location_dest_id;
  List move_id;
  List product_id;
  List lot_id;
  List product_uom_id;
  double product_qty;
  double product_uom_qty;
  double qty_done;

  StockMoveLines(
      {this.id,
      this.location_dest_id,
      this.location_id,
      this.move_id,
      this.lot_id,
      this.product_id,
      this.product_uom_id,
      this.product_qty,
      this.product_uom_qty,
      this.qty_done});
}
