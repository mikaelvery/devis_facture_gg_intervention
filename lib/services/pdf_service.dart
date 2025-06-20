import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../models/client.dart';
import '../models/item_line.dart';

class PdfService {
  static Future<File> generateDevisPdf({
    required Client client,
    required double tvaMontant,   
    required DateTime devisDate,
    required String devisId,
    required double baseHt,
    required bool isSigned,
    required List<ItemLine> serviceItems,
    required List<ItemLine> materielItems,
    String? signatureUrl,
  }) async {
    final pdf = pw.Document();

    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final logoData = await rootBundle.load('assets/images/logo-gg.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final tvaPercent = baseHt > 0 ? (tvaMontant / baseHt) * 100 : 0;
    final totalTtc = baseHt + tvaMontant;

    Uint8List? signatureBytes;
    if (isSigned && signatureUrl != null && signatureUrl.startsWith("data:image")) {
      final base64Data = signatureUrl.split(',').last;
      signatureBytes = base64Decode(base64Data);
    }

    final services = serviceItems;
    final materiel = materielItems;

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
                  pw.Text('${client.prenom} ${client.nom}'),
                  pw.Text(client.adresse),
                  pw.Text(client.email),
                  pw.Text(client.telephone),
                  pw.Text(devisId),
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

          // SERVICES
          if (services.isNotEmpty) ...[
            pw.Text('Services', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Description', 'Quantité', 'PU HT', 'Total HT'],
              data: services.map((item) => [
                item.description,
                item.qty.toString(),
                '${item.puHt.toStringAsFixed(2)} €',
                '${item.totalHt.toStringAsFixed(2)} €',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xC0D4A017)),
              cellAlignment: pw.Alignment.centerLeft,
              cellHeight: 20,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
              },
              cellAlignments: {
                0: pw.Alignment.topLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 10),
          ],

          // MATERIEL
          if (materiel.isNotEmpty) ...[
            pw.Text('Matériel', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Description', 'Quantité', 'PU HT', 'Total HT'],
              data: materiel.map((item) => [
                item.description,
                item.qty.toString(),
                '${item.puHt.toStringAsFixed(2)} €',
                '${item.totalHt.toStringAsFixed(2)} €',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xC0D4A017)),
              cellAlignment: pw.Alignment.centerLeft,
              cellHeight: 20,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
              },
              cellAlignments: {
                0: pw.Alignment.topLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 20),
          ],

          // TOTAL
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Total HT : ${NumberFormat.decimalPattern('fr_FR').format(baseHt)} €'),
                pw.Text('Total TVA : ${NumberFormat.decimalPattern('fr_FR').format(tvaMontant)} €'),
                pw.Text(
                  'Total TTC : ${NumberFormat.decimalPattern('fr_FR').format(totalTtc)} €',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Signature
          pw.Text(
            'En signant ce devis, j’accepte les conditions générales de vente de GG Intervention.',
            style: pw.TextStyle(fontSize: 10),
          ),
          if (signatureBytes != null) ...[
            pw.SizedBox(height: 20),
            pw.Text('Signature du client :', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Image(pw.MemoryImage(signatureBytes), width: 120, height: 60),
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

    // Sauvegarde dans un fichier temporaire
    final output = await getTemporaryDirectory();
    final formattedDate = devisDate.toIso8601String().split('T').first;
    final file = File('${output.path}/devis_${client.nom}_$formattedDate.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
