import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/client.dart';
import '../models/item_line.dart';

class PdfService {
  static Future<File> generateDevisPdf({
    required Client client,
    required List<ItemLine> items,
    required double tvaPercent,
    required DateTime devisDate,
    Uint8List? signatureBytes,
    required String devisId,
  }) async {
    final pdf = pw.Document();

    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final fontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final logoData = await rootBundle.load('assets/images/logo-gg.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final baseHt = items.fold(0.0, (sum, item) => sum + item.totalHt);
    final montantTva = baseHt * (tvaPercent / 100);
    final totalTtc = baseHt + montantTva;

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
                  pw.Text('GG Intervention', style: pw.TextStyle(font: fontBold)),
                  pw.Text('59 rue de Verdansk'),
                  pw.Text('57000 Metz, France'),
                  pw.Text('gg.intervention@gmail.com'),
                  pw.Text('+33 6 45 19 06 94'),
                ],
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Client :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${client.prenom} ${client.nom}'),
                  pw.Text(client.adresse),
                  pw.Text(client.email),
                  pw.Text(client.telephone),
                  pw.Text('Numéro du devis : $devisId'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text('DEVIS', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Description', 'Quantité', 'PU HT', 'Total HT'],
            data: items
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
                pw.Text('Base HT : ${baseHt.toStringAsFixed(2)} €'),
                pw.Text('TVA (${tvaPercent.toStringAsFixed(2)}%) : ${montantTva.toStringAsFixed(2)} €'),
                pw.Text(
                  'Total TTC : ${totalTtc.toStringAsFixed(2)} €',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
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

    final output = await getTemporaryDirectory();
    final formattedDate = devisDate.toIso8601String().split('T').first;
    final file = File('${output.path}/devis_${client.nom}_$formattedDate.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
