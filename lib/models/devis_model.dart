import 'item_line.dart';
import 'client.dart';

class DevisModel {
  Client? client;
  List<ItemLine> items;
  double get total =>
      items.fold(0, (sum, item) => sum + (item.puHt * item.qty));

  DevisModel({
    this.client,
    List<ItemLine>? items,
  }) : items = items ?? [];
}
