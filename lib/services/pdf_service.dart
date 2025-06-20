import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
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
    required String devisId,
    required double baseHt,
    required bool isSigned,
    String? signatureUrl,
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

    final montantTva = baseHt * (tvaPercent / 100);
    final totalTtc = baseHt + montantTva;

    Uint8List? signatureBytes;
    if (isSigned &&
        signatureUrl != null &&
        signatureUrl.startsWith("data:image")) {
      final base64Data = signatureUrl.split(',').last;
      signatureBytes = base64Decode(base64Data);
    }

    final services = items.where((item) => item.type == 'service').toList();
    final materiel = items.where((item) => item.type == 'materiel').toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) {
          final List<pw.Widget> content = [];

          // Entête avec logo + client
          content.add(
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
                    pw.Text('${client.prenom} ${client.nom}'),
                    pw.Text(
                      '${client.adresse}, ${client.codePostal} ${client.ville}',
                    ),
                    pw.Text(client.pays),
                    pw.Text(client.email),
                    pw.Text(client.telephone),
                    pw.SizedBox(height: 5),
                    pw.Text('Numéro du devis : $devisId'),
                    pw.Text(
                      'Date : ${devisDate.day}/${devisDate.month}/${devisDate.year}',
                    ),
                  ],
                ),
              ],
            ),
          );

          content.add(pw.SizedBox(height: 30));
          content.add(
            pw.Center(
              child: pw.Text(
                'DEVIS',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );
          content.add(pw.SizedBox(height: 20));

          // Table services et matériel côte à côte
          content.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Colonne services
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Services',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      services.isNotEmpty
                      ? pw.TableHelper.fromTextArray(
                          headers: [
                            'Description',
                            'Qté',
                            'PU HT',
                            'Total HT',
                          ],
                          data: services
                              .map(
                                (item) => [
                                  item.description,
                                  item.qty.toString(),
                                  '${item.puHt.toStringAsFixed(2)} €',
                                  '${item.totalHt.toStringAsFixed(2)} €',
                                ],
                              )
                              .toList(),
                          headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                          cellAlignment: pw.Alignment.centerLeft,
                          headerDecoration: pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          border: pw.TableBorder.all(width: 0.5),
                        )
                      : pw.Text('Aucun service'),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),

                // Colonne matériel
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Matériel',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      materiel.isNotEmpty
                          ? pw.Table.fromTextArray(
                              headers: [
                                'Description',
                                'Qté',
                                'PU HT',
                                'Total HT',
                              ],
                              data: materiel
                                  .map(
                                    (item) => [
                                      item.description,
                                      item.qty.toString(),
                                      '${item.puHt.toStringAsFixed(2)} €',
                                      '${item.totalHt.toStringAsFixed(2)} €',
                                    ],
                                  )
                                  .toList(),
                              headerStyle: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                              cellAlignment: pw.Alignment.centerLeft,
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors.grey300,
                              ),
                              border: pw.TableBorder.all(width: 0.5),
                            )
                          : pw.Text('Aucun matériel'),
                    ],
                  ),
                ),
              ],
            ),
          );

          content.add(pw.SizedBox(height: 20));

          // Totaux
          content.add(
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Base HT : ${baseHt.toStringAsFixed(2)} €'),
                  pw.Text(
                    'TVA (${tvaPercent.toStringAsFixed(2)}%) : ${montantTva.toStringAsFixed(2)} €',
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
          );

          content.add(pw.SizedBox(height: 30));
          content.add(
            pw.Text(
              'En signant ce devis, j’accepte les conditions générales de vente de GG Intervention.',
              style: pw.TextStyle(fontSize: 10),
            ),
          );

          if (signatureBytes != null) {
            content.add(pw.SizedBox(height: 12));
            content.add(pw.Text('Signature :'));
            content.add(
              pw.Container(
                height: 50,
                width: 150,
                child: pw.Image(pw.MemoryImage(signatureBytes)),
              ),
            );
          }

          return content;
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/devis_$devisId.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
