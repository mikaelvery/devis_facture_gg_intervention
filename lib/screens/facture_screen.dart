import 'package:flutter/material.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/screens/devis_to_facture_screen.dart'; 

class FactureScreen extends StatelessWidget {
  const FactureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: midnightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nouvelle facture',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            _OptionCard(
              title: 'Transformer un devis en facture',
              subtitle: 'Convertis facilement un devis existant en facture détaillée.',
              icon: Icons.transform, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DevisToFactureScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _OptionCard(
              title: 'Créer une facture à partir de zéro',
              subtitle: 'Réalise une facture personnalisée sans partir d’un devis.',
              icon: Icons.note_add,
              onTap: () {
                // Ajoute ici la navigation vers CreateFactureScreen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Color.fromARGB(255, 76, 175, 135)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: midnightBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Color.fromARGB(255, 76, 175, 135)),
            ],
          ),
        ),
      ),
    );
  }
}
