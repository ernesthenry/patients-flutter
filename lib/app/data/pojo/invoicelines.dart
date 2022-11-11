class InvoiceLine {
  int id;
  int product_id;
  String name;
  double quantity;
  List product_uom_id;
  String asset_category_id;
  double price_unit;
  List account_id;
  int tax_ids;
  double price_total;

  InvoiceLine(
      {this.id,
      this.product_id,
      this.name,
      this.quantity,
      this.product_uom_id,
      this.account_id,
      this.asset_category_id,
      this.tax_ids,
      this.price_unit,
      this.price_total});
}
