import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendEmailWithPdf({
  required File pdfFile,
  required String clientEmail,
  required String clientNom,
  String? devisId,
  required bool isSigned,
}) async {
  final now = DateTime.now();
  devisId ??=
      'DEVIS-n°${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(now.millisecondsSinceEpoch.toString().length - 5)}';

  final user = dotenv.env['EMAIL_USER']!;
  final pass = dotenv.env['EMAIL_PASS']!;
  final smtpServer = gmail(user, pass);

  final subject = 'Votre devis GG Intervention';
  final lienSignature =
      'https://chary-depannage-website.vercel.app/signature?numero=${Uri.encodeComponent(devisId)}';

  final message = Message()
    ..from = Address(user, 'GG Intervention')
    ..recipients.add(clientEmail)
    ..subject = subject;

  if (!isSigned) {
    message
      ..text =
          '''
Bonjour $clientNom,

Veuillez trouver ci-joint votre devis n°$devisId.

Merci de bien vouloir le signer à l’aide du lien suivant :
$lienSignature

Cordialement,  
GG Dépannage
      '''
      ..html =
          '''
<p>Bonjour $clientNom,</p>
<p>Veuillez trouver ci-joint votre devis <strong>n°$devisId</strong>.</p>
<p>Merci de bien vouloir le signer à l’aide du lien suivant :</p>
<p><a href="$lienSignature">$lienSignature</a></p>
<p>Cordialement,<br>GG Intervention</p>
      '''
      ..attachments = [
        FileAttachment(pdfFile)
          ..location = Location.inline
          ..cid = '<devis>',
      ];
  } else {
    message
      ..text =
          '''
Bonjour $clientNom,

Voici votre devis n°$devisId signé, en pièce jointe.

Merci pour votre confiance.  
GG Dépannage
      '''
      ..html =
          '''
<p>Bonjour $clientNom,</p>
<p>Voici votre devis <strong>n°$devisId</strong> signé, en pièce jointe.</p>
<p>Merci pour votre confiance.<br>GG Dépannage</p>
      '''
      ..attachments = [
        FileAttachment(pdfFile)
          ..location = Location.inline
          ..cid = '<devis>',
      ];
  }

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
