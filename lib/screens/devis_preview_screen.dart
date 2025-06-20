import 'dart:convert';
import 'dart:io';
import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';
import 'package:devis_facture_gg_intervention/screens/signature_screen.dart';
import 'package:devis_facture_gg_intervention/services/devis_service.dart';
import 'package:devis_facture_gg_intervention/services/email_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/client.dart';
import '../models/item_line.dart';
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
  double get baseHt => widget.items.fold(0.0, (sum, item) => sum + item.totalHt);
  double get montantTva {
    return widget.items.fold(0.0, (sum, item) => sum + item.totalTva);
  }
  double get totalTtc => baseHt + montantTva;
  late double selectedTva;

  @override
  void initState() {
    super.initState();
    selectedTva = widget.tvaPercent;
    signature = widget.signatureBytes; // Récupérer la signature si déjà fournie
    _initGeneratePdf(); // Générer le PDF dès le lancement de l'écran
  }

  // Par exemple, une fonction pour changer la TVA
  void onTvaChanged(double newTva) async {
    setState(() {
      selectedTva = newTva;
      isLoading = true;
    });
    await _generatePdf(); // Regénérer le PDF avec la nouvelle TVA
    setState(() {
      isLoading = false;
    });
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

    // Génére et stocker le devisId dans la variable d'instance
    devisId = generateDevisId();

    // Charge les polices et logo depuis les assets
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final fontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final logoData = await rootBundle.load('assets/images/logo-gg.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Construction du contenu de la page PDF
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
                  pw.Image(logoImage, width: 70),
                  pw.SizedBox(height: 10),
                  pw.Text('GG Intervention', style: pw.TextStyle(font: fontBold)),
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
                  pw.SizedBox(height: 53),
                  pw.Text('Client :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${widget.client.prenom} ${widget.client.nom}'),
                  pw.Text(widget.client.adresse),
                  pw.Text(widget.client.email),
                  pw.Text(widget.client.telephone),
                  pw.Text('$devisId'),
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
          // tableau pour services
          // Titre Services encadré
          pw.Text(
            'Services',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Description', 'Quantité', 'PU HT', 'Total HT', 'TVA'],
            data: widget.items
                .where((item) => item.type == 'service')
                .map(
                  (item) => [
                    item.description,
                    item.qty.toString(),
                    '${item.puHt.toStringAsFixed(2)} €',
                    '${item.totalHt.toStringAsFixed(2)} €',
                    '${item.tva.toStringAsFixed(0)} %',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xC0D4A017),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 20,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            cellAlignments: {
              0: pw.Alignment.topLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            'Matériel',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Description', 'Quantité', 'PU HT', 'Total HT', 'TVA'],
            data: widget.items
                .where((item) => item.type == 'materiel')
                .map(
                  (item) => [
                    item.description,
                    item.qty.toString(),
                    '${item.puHt.toStringAsFixed(2)} €',
                    '${item.totalHt.toStringAsFixed(2)} €',
                    '${item.tva.toStringAsFixed(0)} %',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xC0D4A017),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 20,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            cellAlignments: {
              0: pw.Alignment.topLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
          ),


          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Total HT : ${NumberFormat.decimalPattern('fr_FR').format(baseHt)} €',
                ),
                pw.Text(
                  'Total TVA : ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(montantTva)}',
                ),
                pw.Text(
                  'Total TTC : ${totalTtc.toStringAsFixed(2)} €',
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
    if (kDebugMode) {
      print('Calcul TVA avec selectedTva = $selectedTva');
    }

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
        baseHt: double.parse(baseHt.toStringAsFixed(2)),
        tva: double.parse(montantTva.toStringAsFixed(2)),
        totalTtc: double.parse(totalTtc.toStringAsFixed(2)),
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

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
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

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signature enregistrée.")),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Signer ce devis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
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