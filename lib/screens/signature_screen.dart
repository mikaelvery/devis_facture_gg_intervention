import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: white,
  );

  bool _hasSigned = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!_hasSigned && _controller.isNotEmpty) {
        setState(() => _hasSigned = true);
      } else if (_hasSigned && _controller.isEmpty) {
        setState(() => _hasSigned = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSignature() {
    _controller.clear();
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final Uint8List? data = await _controller.toPngBytes();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signer le devis'),
        centerTitle: true,
        backgroundColor: midnightBlue,
        foregroundColor: white,
      ),
      body: Stack(
        children: [
          Signature(controller: _controller, backgroundColor: white),
          if (_hasSigned)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveSignature,
                      icon: const Icon(Icons.check),
                      label: const Text("Valider"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearSignature,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Recommencer"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
