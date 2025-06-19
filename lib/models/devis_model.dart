import 'item_line.dart';
import 'client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevisModel {
  String id;
  Client? client;
  List<ItemLine> items;

  double get total =>
      items.fold(0, (sum, item) => sum + (item.puHt * item.qty));

  DevisModel({
    required this.id,
    this.client,
    List<ItemLine>? items,
  }) : items = items ?? [];

  factory DevisModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DevisModel(
      id: doc.id,
      client: null, 
      items: (data['items'] as List<dynamic>?)?.map((item) {
        return ItemLine.fromMap(item);
      }).toList() ?? [],
    );
  }
}
