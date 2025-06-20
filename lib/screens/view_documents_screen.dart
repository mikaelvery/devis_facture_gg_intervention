import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/models/client.dart';
import 'package:devis_facture_gg_intervention/models/item_line.dart';
import 'package:devis_facture_gg_intervention/screens/document_screen.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';
import 'package:devis_facture_gg_intervention/screens/pdf_preview_screen.dart';
import 'package:devis_facture_gg_intervention/services/email_service.dart';
import 'package:devis_facture_gg_intervention/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewDocumentsScreen extends StatelessWidget {
  const ViewDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: midnightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Documents',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 10),
        child: FloatingActionButton(
          backgroundColor: green,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DocumentScreen()),
            );
          },
          child: const Icon(Icons.add, size: 40, color: white),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          height: 60,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Icon(Icons.home, color: midnightBlue, size: 24),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewDocumentsScreen(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        Icons.description,
                        color: midnightBlue,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {},
                    child: const Center(
                      child: Icon(Icons.people, color: midnightBlue, size: 24),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {},
                    child: const Center(
                      child: Icon(
                        Icons.settings,
                        color: midnightBlue,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devis')
            .orderBy('date', descending: true)
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

          final devisList = snapshot.data?.docs ?? [];
          if (devisList.isEmpty) {
            return const Center(
              child: Text(
                'Aucun devis trouvé',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: devisList.length,
            itemBuilder: (context, index) {
              var doc = devisList[index];
              final data = doc.data() as Map<String, dynamic>;

              // Récupération des données client
              final clientData = data['client'] as Map<String, dynamic>? ?? {};
              final nom = clientData['nom'] ?? 'Nom inconnu';
              final prenom = clientData['prenom'] ?? 'Prénom inconnu';

              // Conversion et formatage du montant TTC
              final montantTtcRaw = data['totalTtc'];
              double montantTtc = 0;
              if (montantTtcRaw is int) {
                montantTtc = montantTtcRaw.toDouble();
              } else if (montantTtcRaw is double) {
                montantTtc = montantTtcRaw;
              }
              final montantFormatted = NumberFormat.currency(
                locale: 'fr_FR',
                symbol: '€',
              ).format(montantTtc);
              // Numéro du devis
              final numero = data['devisId'] ?? doc.id;
              // Statut signé
              final isSigned = data['isSigned'] ?? false;
              // Gestion de la date
              final Timestamp? timestamp =
                  (data['createdAt'] as Timestamp?) ??
                  (data['date'] as Timestamp?);
              final DateTime? date = timestamp?.toDate();
              final dateFormatted = date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Date inconnue';

              // modal apercu
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Détails du devis',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: midnightBlue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Client : $prenom $nom',
                              style: TextStyle(color: midnightBlue),
                            ),
                            Text(
                              'Numéro devis : $numero',
                              style: TextStyle(color: midnightBlue),
                            ),
                            Text(
                              'Montant TTC : $montantFormatted',
                              style: TextStyle(color: midnightBlue),
                            ),
                            Text(
                              'Date : $dateFormatted',
                              style: TextStyle(color: midnightBlue),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSigned ? green : orange,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSigned
                                            ? Icons.check_circle
                                            : Icons.hourglass_empty,
                                        color: white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isSigned ? 'Signé' : 'En attente',
                                        style: const TextStyle(
                                          color: white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final clientMap =
                                    data['client'] as Map<String, dynamic>? ??
                                    {};
                                final client = Client.fromMap(clientMap);
                                final servicesList =
                                    (data['services'] as List<dynamic>?)
                                        ?.map(
                                          (e) => ItemLine.fromMap(
                                            e as Map<String, dynamic>,
                                          ),
                                        )
                                        .toList() ??
                                    [];
                                final materielList =
                                    (data['materiel'] as List<dynamic>?)
                                        ?.map(
                                          (e) => ItemLine.fromMap(
                                            e as Map<String, dynamic>,
                                          ),
                                        )
                                        .toList() ??
                                    [];
                              
                                final devisDate = date ?? DateTime.now();
                                final devisId = data['devisId'] ?? '';
                                final isSigned = data['isSigned'] ?? false;
                                final signatureUrl = data['signatureUrl'] ?? '';
                                final double baseHt = (data['baseHt'] as num?)?.toDouble() ?? 0.0;
                                final double tvaMontant = (data['tva'] as num?)?.toDouble() ?? 0.0;

                                // Passe bien tvaMontant tel quel, c’est la TVA en euros
                                final pdfFile = await PdfService.generateDevisPdf(
                                  client: client,
                                  serviceItems: servicesList,
                                  materielItems: materielList,
                                  tvaMontant: tvaMontant,
                                  devisDate: devisDate,
                                  devisId: devisId,
                                  isSigned: isSigned,
                                  baseHt: baseHt,
                                  signatureUrl: signatureUrl,
                                );


                                if (!context.mounted) return;
                                final bytes = await pdfFile.readAsBytes();
                                if (!context.mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PdfPreviewScreen(bytes: bytes),
                                  ),
                                );
                              },

                              icon: SizedBox(
                                width: 24,
                                child: const Icon(Icons.picture_as_pdf),
                              ),
                              label: const Text('Aperçu du devis'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: midnightBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: midnightBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: Row(
                                      children: const [
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Confirmer la suppression',
                                            style: TextStyle(color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      'Êtes-vous sûr de vouloir supprimer ce devis ?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Annuler'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: orange,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text(
                                            'Supprimer',
                                            style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await FirebaseFirestore.instance.collection('devis').doc(doc.id).delete();
                                  if (!context.mounted) return; 
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Devis supprimé')),
                                  );
                                }
                              },
                              icon: SizedBox(width: 24, child: const Icon(Icons.delete)),
                              label: const Text('Supprimer le devis'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: midnightBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),


                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final clientMap = data['client'] as Map<String, dynamic>? ?? {};
                                final clientEmail = clientMap['email'] ?? '';
                                final clientNom = clientMap['nom'] ?? 'Client';

                                if (clientEmail.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Adresse mail du client introuvable')),
                                  );
                                  return;
                                }

                                // Récupère les infos pour générer le PDF
                                final client = Client.fromMap(clientMap);
                                final servicesList = (data['services'] as List<dynamic>? ?? [])
                                    .map((e) => ItemLine.fromMap(e as Map<String, dynamic>))
                                    .toList();
                                final materielList = (data['materiel'] as List<dynamic>? ?? [])
                                    .map((e) => ItemLine.fromMap(e as Map<String, dynamic>))
                                    .toList();

                                final Timestamp? timestamp = (data['createdAt'] as Timestamp?) ?? (data['date'] as Timestamp?);
                                final devisDate = timestamp?.toDate() ?? DateTime.now();
                                final devisId = data['devisId'] ?? '';
                                final isSigned = data['isSigned'] ?? false;
                                final signatureUrl = data['signatureUrl'] ?? '';
                                final baseHt = (data['baseHt'] as num?)?.toDouble() ?? 0.0;
                                final tvaMontant = (data['tva'] as num?)?.toDouble() ?? 0.0;

                                // Génère le PDF du devis
                                final pdfFile = await PdfService.generateDevisPdf(
                                  client: client,
                                  serviceItems: servicesList,
                                  materielItems: materielList,
                                  tvaMontant: tvaMontant,
                                  devisDate: devisDate,
                                  devisId: devisId,
                                  isSigned: isSigned,
                                  baseHt: baseHt,
                                  signatureUrl: signatureUrl,
                                );

                                // Envoie le mail avec le PDF attaché
                                await sendEmailWithPdf(
                                  pdfFile: pdfFile,
                                  clientEmail: clientEmail,
                                  clientNom: clientNom,
                                  devisId: devisId,
                                  isSigned: isSigned,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Email envoyé à $clientEmail')),
                                  );
                                }
                              },
                               icon: SizedBox(
                                width: 24,
                                child: const Icon(Icons.mail),
                              ),
                              label: const Text('Envoyer par mail'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: midnightBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Card(
                  elevation: 4,
                  color: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$prenom ${nom.toUpperCase()}',
                              style: const TextStyle(
                                color: midnightBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              montantFormatted,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 76, 175, 135),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              numero,
                              style: const TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              dateFormatted,
                              style: const TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSigned ? green : orange,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSigned
                                    ? Icons.check_circle
                                    : Icons.hourglass_empty,
                                color: white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isSigned ? 'Signé' : 'En attente de signature',
                                style: const TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
