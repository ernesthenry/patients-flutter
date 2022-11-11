class PriceListItem {
  int id;
  String name;
  List product_tmpl_id;
  String applied_on;
  double fixed_price;
  List currency;

  PriceListItem(
      {this.id,
      this.name,
      this.product_tmpl_id,
      this.applied_on,
      this.fixed_price,
      this.currency});
}
