import 'dart:async';
import 'dart:typed_data';

import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final List<int> bytes;

  const PdfPreviewScreen({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Aperçu du devis'),
        backgroundColor: midnightBlue,
        foregroundColor: white,
      ),
      body: PdfPreview(
        build: (format) => Future.value(Uint8List.fromList(bytes)),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        useActions: true,
      ),
    );
  }
}
