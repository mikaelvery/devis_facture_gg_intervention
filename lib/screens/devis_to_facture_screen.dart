import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devis_facture_gg_intervention/models/devis_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:devis_facture_gg_intervention/models/facture.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';

class DevisToFactureScreen extends StatefulWidget {
  const DevisToFactureScreen({super.key});

  @override
  State<DevisToFactureScreen> createState() => _DevisToFactureScreenState();
}

class _DevisToFactureScreenState extends State<DevisToFactureScreen> {
  String searchQuery = "";

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
        title: const Text('Mes devis', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search bar
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  setState(() => searchQuery = value.trim().toLowerCase()),
            ),
            const SizedBox(height: 16),

            // Liste filtrée des devis (reste inchangé)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                        'Aucun client trouvé a ce nom  : ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final devisDocs = snapshot.data?.docs ?? [];

                  // Filtrer les devis par recherche client (nom/prénom)
                  final filteredDevis = devisDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final client =
                        data['client'] as Map<String, dynamic>? ?? {};
                    final nom = (client['nom'] ?? '').toString().toLowerCase();
                    final prenom = (client['prenom'] ?? '')
                        .toString()
                        .toLowerCase();
                    final search = searchQuery.toLowerCase();
                    return nom.contains(search) || prenom.contains(search);
                  }).toList();

                  if (filteredDevis.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun devis trouvé',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDevis.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDevis[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final client =
                          data['client'] as Map<String, dynamic>? ?? {};
                      String nom = (client['nom'] ?? 'Nom inconnu')
                          .toString()
                          .toUpperCase();
                      String prenomRaw = (client['prenom'] ?? 'Prénom inconnu')
                          .toString();
                      String prenom = prenomRaw.isNotEmpty
                          ? prenomRaw[0].toUpperCase() +
                                prenomRaw.substring(1).toLowerCase()
                          : prenomRaw;

                      final montantRaw = data['totalTtc'];
                      double montant = 0;
                      if (montantRaw is int) {
                        montant = montantRaw.toDouble();
                      } else if (montantRaw is double) {
                        montant = montantRaw;
                      }
                      final montantFormatted = NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: '€',
                      ).format(montant);

                      final dateTimestamp =
                          (data['date'] as Timestamp?) ??
                          (data['createdAt'] as Timestamp?);
                      final date = dateTimestamp?.toDate();
                      final dateFormatted = date != null
                          ? DateFormat('dd/MM/yyyy').format(date)
                          : 'Date inconnue';

                      final numero = data['devisId'] ?? 'N° inconnu';
                      final isSigned = data['isSigned'] ?? false;

                      return GestureDetector(
                        onTap: () {
                          final devis = DevisModel.fromDocument(doc);
                          // Action
                        },
                        child: Card(
                          elevation: 4,
                          color: midnightBlue.withAlpha(150),
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
                                // Nom + Montant + Œil
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '$prenom $nom',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          montantFormatted,
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              76,
                                              175,
                                              135,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                // Numéro + Date (avec même marge que le montant)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      numero,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 32,
                                      ), // même marge droite que montant
                                      child: Text(
                                        dateFormatted,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                const Divider(
                                  color: Colors.white24,
                                  thickness: 1,
                                  height: 6,
                                ),

                                const SizedBox(height: 8),

                                // Statut + 0.00€ facturés
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSigned
                                            ? const Color.fromARGB(
                                                255,
                                                76,
                                                175,
                                                135,
                                              )
                                            : green,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSigned
                                                ? Icons.check_circle
                                                : Icons.hourglass_empty,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isSigned
                                                ? 'Signé'
                                                : 'En attente de signature',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(right: 32),
                                      child: Text(
                                        '0,00 € facturés',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
