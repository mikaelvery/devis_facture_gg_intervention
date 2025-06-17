import 'dart:convert';
import 'dart:io';
import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';
import 'package:devis_facture_gg_intervention/screens/signature_screen.dart'; // Écran de signature
import 'package:devis_facture_gg_intervention/services/devis_service.dart'; // Service pour sauvegarder les devis
import 'package:devis_facture_gg_intervention/services/email_service.dart'; // Service pour envoyer les email en PDF
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show
        rootBundle,
        Uint8List; // Pour charger assets et gérer les images/signatures
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Pour accéder au stockage temporaire
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'
    as pw; // Bibliothèque PDF pour générer des documents
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Pour afficher le PDF dans l'app
import '../models/client.dart'; // Modèle client
import '../models/item_line.dart'; // Modèle ligne des devis
import '../services/client_service.dart';

class DevisPreviewScreen extends StatefulWidget {
  final Client client;
  final DateTime devisDate;
  final List<ItemLine> items;
  final double tvaPercent;
  final Uint8List? signatureBytes;

  const DevisPreviewScreen({
    super.key,
    required this.client,
    required this.devisDate,
    required this.items,
    required this.tvaPercent,
    this.signatureBytes,
  });

  @override
  State<DevisPreviewScreen> createState() => _DevisPreviewScreenState();
}

class _DevisPreviewScreenState extends State<DevisPreviewScreen> {
  bool get isSigned => signature != null;
  final DevisService _devisService = DevisService();
  final ClientService _clientService = ClientService();

  File? pdfFile; // Le fichier PDF généré
  Uint8List? signature; // Signature sous forme d'image
  bool isLoading = true; // Indicateur de chargement

  String? devisId; // stock le devisId généré ici

  // Calculs pour la facture
  double get baseHt =>
      widget.items.fold(0.0, (sum, item) => sum + item.totalHt);
  double get montantTva => baseHt * (widget.tvaPercent / 100);
  double get totalTtc => baseHt + montantTva;

  @override
  void initState() {
    super.initState();
    signature = widget.signatureBytes; // Récupérer la signature si déjà fournie
    _initGeneratePdf(); // Générer le PDF dès le lancement de l'écran
  }

  // Fonction pour générer un identifiant unique de devis
  String generateDevisId() {
    final now = DateTime.now();
    final datePart =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = now.millisecondsSinceEpoch.toString().substring(
      now.millisecondsSinceEpoch.toString().length - 5,
    );
    return 'Devis n°$datePart-$suffix';
  }

  // Fonction pour générer le PDF avec gestion de l'état loading et erreurs
  Future<void> _initGeneratePdf() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _generatePdf();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la génération du PDF : $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Fonction qui construit le PDF et l'enregistre dans un fichier temporaire
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Générer et stocker le devisId dans la variable d'instance
    devisId = generateDevisId();

    // Charger les polices et logo depuis les assets
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final fontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final logoData = await rootBundle.load('assets/images/logo-gg.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Construire le contenu de la page PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logoImage, width: 80),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'GG Intervention',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.Text('30 rue général de gaulle'),
                  pw.Text('57050 Longeville-Lès-Metz, France'),
                  pw.Text('gg.intervention@gmail.com'),
                  pw.Text('+33 6 45 19 06 94'),
                ],
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Client :',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('${widget.client.prenom} ${widget.client.nom}'),
                  pw.Text(widget.client.adresse),
                  pw.Text(widget.client.email),
                  pw.Text(widget.client.telephone),
                  pw.Text('Numéro du devis : $devisId'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text(
              'DEVIS',
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Description', 'Quantité', 'PU HT', 'Total HT'],
            data: widget.items
                .map(
                  (item) => [
                    item.description,
                    item.qty.toString(),
                    '${item.puHt.toStringAsFixed(2)} €',
                    '${item.totalHt.toStringAsFixed(2)} €',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Base HT : ${NumberFormat.decimalPattern('fr_FR').format(baseHt)} €',
                ),
                pw.Text(
                  'TVA (${widget.tvaPercent.toStringAsFixed(2)}%) : ${NumberFormat.decimalPattern('fr_FR').format(montantTva)} €',
                ),
                pw.Text(
                  'Total TTC : ${NumberFormat.decimalPattern('fr_FR').format(totalTtc)} €',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'En signant ce devis, j’accepte les conditions générales de vente de GG Intervention.',
            style: pw.TextStyle(fontSize: 10),
          ),
          // Affiche la signature si elle existe
          if (signature != null) ...[
            pw.SizedBox(height: 20),
            pw.Text('Signature du client :', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Image(pw.MemoryImage(signature!), width: 120, height: 60),
          ],
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'Micro-entreprise GG Intervention - SIREN 123 456 789\n'
              'Régime de TVA sur les encaissements - Document émis par GG Intervention',
              style: pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    // Enregistre le PDF dans un fichier temporaire
    final output = await getTemporaryDirectory();
    final formattedDate = widget.devisDate.toIso8601String().split('T').first;
    final file = File(
      '${output.path}/devis_${widget.client.nom}_$formattedDate.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    setState(() {
      pdfFile = file;
    });
  }

  // Fonction pour sauvegarder le devis et envoyer le PDF par email
  Future<void> _saveDevis() async {
    if (pdfFile == null) return;

    try {
      final DateTime? signedAt = isSigned ? DateTime.now() : null;

      // Envoi l'email avec le PDF
      await sendEmailWithPdf(
        pdfFile: pdfFile!,
        clientEmail: widget.client.email,
        clientNom: widget.client.nom,
        devisId: devisId ?? '',
        isSigned: isSigned,
      );

      // Sauvegarde le client dans la base
      await _clientService.saveClient(widget.client);

      // Sauvegarde le devis dans firebase
      await _devisService.saveDevis(
        client: widget.client,
        devisId: devisId!,
        date: widget.devisDate,
        services: widget.items.where((i) => i.type == 'service').toList(),
        materiel: widget.items.where((i) => i.type == 'materiel').toList(),
        baseHt: baseHt,
        tva: montantTva,
        totalTtc: totalTtc,
        isSigned: isSigned,
        signedAt: signedAt,
        signatureUrl: signature != null
            ? 'data:image/png;base64,${base64Encode(signature!)}'
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Devis confirmé et envoyé.")),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // Retour vers le Dashboard
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: midnightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Aperçu du Devis",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pdfFile == null
            ? const Center(child: Text('Erreur lors du chargement du PDF'))
            : SfPdfViewer.file(pdfFile!),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignatureScreen()),
                );

                if (result != null && result is Uint8List) {
                  setState(() {
                    signature = result;
                    isLoading = true;
                  });
                  await _generatePdf();
                  setState(() {
                    isLoading = false;
                  });

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signature enregistrée.")),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Signer ce devis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveDevis,
              icon: const Icon(Icons.save),
              label: const Text('Confirmer & envoyer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: midnightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
