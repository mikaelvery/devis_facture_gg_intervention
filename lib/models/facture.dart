// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'item_line.dart';
// import 'client.dart';

// class Facture {
//   final String factureId;
//   final DateTime dateFacture;
//   final Client client;
//   final List<ItemLine> services;
//   final List<ItemLine> materiel;
//   final double baseHt;
//   final double tva;
//   final double totalTtc;

//   Facture({
//     required this.factureId,
//     required this.dateFacture,
//     required this.client,
//     required this.services,
//     required this.materiel,
//     required this.baseHt,
//     required this.tva,
//     required this.totalTtc, required DateTime date,
//   });

//   Map<String, dynamic> toMap() => {
//         'factureId': factureId,
//         'dateFacture': Timestamp.fromDate(dateFacture),
//         'client': client.toMap(),
//         'services': services.map((s) => s.toMap()).toList(),
//         'materiel': materiel.map((m) => m.toMap()).toList(),
//         'baseHt': baseHt,
//         'tva': tva,
//         'totalTtc': totalTtc,
//       };

//   factory Facture.fromMap(Map<String, dynamic> map) {
//     return Facture(
//       factureId: map['factureId'] ?? '',
//       dateFacture: (map['dateFacture'] as Timestamp).toDate(),
//       client: Client.fromMap(map['client'] ?? {}),
//       services: List<ItemLine>.from((map['services'] ?? []).map((x) => ItemLine.fromMap(x))),
//       materiel: List<ItemLine>.from((map['materiel'] ?? []).map((x) => ItemLine.fromMap(x))),
//       baseHt: (map['baseHt'] ?? 0).toDouble(),
//       tva: (map['tva'] ?? 0).toDouble(),
//       totalTtc: (map['totalTtc'] ?? 0).toDouble(),
//     );
//   }
// }
