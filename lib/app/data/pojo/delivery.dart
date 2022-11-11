class StockPicking {
  int id;
  String state;
  List location_id;
  List partner_id;
  String origin;
  String date_deadline;
  String scheduled_date;
  String move_type;
  List group_id;
  List move_ids_without_package;
  List move_line_ids_without_package;

  StockPicking(
      {this.id,
      this.location_id,
      this.state,
      this.partner_id,
      this.move_type,
      this.group_id,
      this.origin,
      this.scheduled_date,
      this.date_deadline,
      this.move_ids_without_package,
      this.move_line_ids_without_package});
}
