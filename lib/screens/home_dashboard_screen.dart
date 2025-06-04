import 'package:devis_facture_gg_intervention/screens/document_screen.dart';
import 'package:flutter/material.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bleuNuit,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: AppBar(
            backgroundColor: blanc,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo-gg.png', height: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Ma Synthèse',
                      style: TextStyle(
                        color: bleuNuit,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today, color: bleuNuit, size: 18),
                      label: const Text('Année en cours', style: TextStyle(color: bleuNuit)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        backgroundColor: blanc,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Action date picker
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: bleuNuit),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: bleuNuit),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CardStat(title: 'Total encaissé'),
            SizedBox(height: 12),
            CardStat(title: 'Devis en attente de signature'),
            SizedBox(height: 12),
            CardStat(title: 'Facture en attente de paiement'),
            SizedBox(height: 12),
            CardStat(title: 'Facture en retard'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DocumentScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32, color: blanc),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: blanc,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: bleuNuit),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.description, color: bleuNuit),
                onPressed: () {},
              ),
              const SizedBox(width: 40), // espace pour le FAB
              IconButton(
                icon: const Icon(Icons.people, color: bleuNuit),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: bleuNuit),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardStat extends StatelessWidget {
  final String title;

  const CardStat({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: bleuNuit,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: bleuNuit),
        ],
      ),
    );
  }
}
