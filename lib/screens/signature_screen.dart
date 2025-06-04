import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {
        Navigator.of(context).pop(data);  
      }
    } else {
      // Pas de signature, on retourne null
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signer le devis'),
        backgroundColor: const Color(0xFF0B1B3F),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _controller.clear(),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSignature,
          ),
        ],
      ),
      body: Signature(
        controller: _controller,
        backgroundColor: Colors.white,
      ),
    );
  }
}
