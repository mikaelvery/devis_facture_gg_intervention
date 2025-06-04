import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendEmailWithPdf(File pdfFile, String clientEmail) async {
  final user = dotenv.env['EMAIL_USER']!;
  final pass = dotenv.env['EMAIL_PASS']!;
  final smtpServer = gmail(user, pass);

  final message = Message()
    ..from = Address(user, 'GG Intervention')
    ..recipients.add(clientEmail)
    ..subject = 'Nouveau devis GG Intervention'
    ..text = 'Veuillez trouver ci-joint le devis.'
    ..attachments = [
      FileAttachment(pdfFile)
        ..location = Location.inline
        ..cid = '<devis>'
    ];

  try {
    await send(message, smtpServer);
    if (kDebugMode) {
      print('✅ Email envoyé avec succès à $clientEmail');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Erreur lors de l\'envoi : $e');
    }
  }
}

