import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/models/client.dart';
import 'package:devis_facture_gg_intervention/models/item_line.dart';
import 'package:devis_facture_gg_intervention/services/pdf_service.dart';
import 'package:devis_facture_gg_intervention/services/email_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> processSignedDevis(DocumentSnapshot doc, BuildContext context) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      final signatureBase64 = data['signature'] as String?;
      final clientData = data['client'] as Map<String, dynamic>;
      final itemsData = List<Map<String, dynamic>>.from(data['items']);
      final devisDate = (data['createdAt'] as Timestamp).toDate();
      final tvaPercent = data['tva']?.toDouble() ?? 20.0;
      final devisId = data['numero'] ?? doc.id;
      final client = Client.fromMap(clientData);
      final items = itemsData.map((e) => ItemLine.fromMap(e)).toList();
      final clientEmail = client.email;
      final clientNom = client.nom;

      if (signatureBase64 == null || clientEmail.isEmpty) {
        throw Exception('Signature ou email manquant.');
      }

      final Uint8List signatureBytes = base64Decode(signatureBase64.split(',').last);

      final pdfFile = await PdfService.generateDevisPdf(
        client: client,
        items: items,
        tvaPercent: tvaPercent,
        devisDate: devisDate,
        signatureBytes: signatureBytes,
        devisId: devisId,
      );

      await sendEmailWithPdf(
        pdfFile: pdfFile,
        clientEmail: clientEmail,
        clientNom: clientNom,
        devisId: devisId,
        isSigned: true,
      );

      await doc.reference.update({'isRead': true});

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Email envoyé à $clientEmail')),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi du devis signé : $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erreur lors de l’envoi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: midnightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Boîte de réception',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('devis')
              .where('isRead', isEqualTo: false)
              .where('isSigned', isEqualTo: true)
              .orderBy('signedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune notification disponible',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final numero = doc['numero'] ?? doc.id;
                final clientNom = doc['client']['nom'] ?? 'Client';
                final date = (doc['signedAt'] as Timestamp?)?.toDate();

                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      'Devis signé : $numero',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Client : $clientNom\n${date != null ? 'Signé le ${date.day}/${date.month}/${date.year}' : ''}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.send, color: Colors.greenAccent),
                      onPressed: () async {
                        await processSignedDevis(doc, context);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
