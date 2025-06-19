// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:devis_facture_gg_intervention/models/facture.dart';
// import 'package:flutter/material.dart';

// class CreateFactureScreen extends StatelessWidget {
//   const CreateFactureScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Affiche les infos ou prérempli un formulaire avec initialFacture
//     return Scaffold(
//       appBar: AppBar(title: const Text("Créer une facture")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Client : ${initialFacture.client.nom}"),
//             Text("Date : ${initialFacture.date}"),
//             Text("Montant TTC : ${initialFacture.totalTtc} €"),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 await FirebaseFirestore.instance
//                   .collection('factures')
//                   .add(initialFacture.toMap());

//                 // ignore: use_build_context_synchronously
//                 Navigator.pop(context);
//               },
//               child: const Text("Enregistrer la facture"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
