import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const NotificationCard({required this.doc, super.key});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final clientData = data['client'] as Map<String, dynamic>?;

    final nom = clientData?['nom']?.toString().toUpperCase() ?? 'INCONNU';
    final prenom = clientData?['prenom'] ?? 'Inconnu';
    final devisNum = data['devisId'] ?? '???';
    final dateSignatureTimestamp = data['signedAt'] as Timestamp?;
    final dateSignature = dateSignatureTimestamp?.toDate();

    final formattedDate = dateSignature != null
        ? DateFormat('dd/MM/yyyy à HH:mm').format(dateSignature)
        : 'Date de signature inconnue';

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // action on tap
        },
        child: ListTile(
          leading: const Icon(Icons.description, color: Colors.blueAccent, size: 28),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$nom ',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: prenom,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: ' - $devisNum',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          subtitle: Text(
            'À signer le $formattedDate',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.mark_email_read_outlined, color: Colors.blueAccent),
            tooltip: 'Marquer comme lu',
            onPressed: () async {
              try {
                await doc.reference.update({'isRead': true});
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification marquée comme lue')),
                );
              } catch (e) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur : $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
