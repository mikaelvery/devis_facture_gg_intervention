import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_line.dart';
import '../models/client.dart';

class DevisService {
  Future<void> saveDevis({
    required String devisId,
    required Client client,
    required DateTime date,
    required List<ItemLine> services,
    required List<ItemLine> materiel,
    required double baseHt,
    required double tva,
    required double totalTtc,
    required bool isSigned,
    DateTime? signedAt,
    String? signatureUrl,        
  }) async {
    final Timestamp timestamp = Timestamp.fromDate(date);
    final Timestamp? signedTimestamp = signedAt != null ? Timestamp.fromDate(signedAt) : null;

    final devisData = {
      'devisId': devisId,
      'date': timestamp,
      'client': client.toMap(),
      'services': services.map((s) => s.toMap()).toList(),
      'materiel': materiel.map((m) => m.toMap()).toList(),
      'baseHt': baseHt,
      'tva': tva,
      'totalTtc': totalTtc,
      'isSigned': isSigned,
      'signedAt': signedTimestamp,        
      'signatureUrl': signatureUrl,   
    };

    await FirebaseFirestore.instance
      .collection('devis')
      .add(devisData);
  }
}
