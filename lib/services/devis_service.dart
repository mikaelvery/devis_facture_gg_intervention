import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_line.dart';
import '../models/client.dart';

class DevisService {
  Future<void> saveDevis({
    required Client client,
    required DateTime date,
    required List<ItemLine> services,
    required List<ItemLine> materiel,
    required double baseHt,
    required double tva,
    required double totalTtc,
  }) async {
    // la date a 2 heure de retard je suis en france
    final Timestamp timestamp = Timestamp.fromDate(date);

    final devisData = {
      'date': timestamp,
      'client': client.toMap(),
      'services': services.map((s) => s.toMap()).toList(),
      'materiel': materiel.map((m) => m.toMap()).toList(),
      'baseHt': baseHt,
      'tva': tva,
      'totalTtc': totalTtc,
    };

    await FirebaseFirestore.instance.collection('devis').add(devisData);
  }
}
