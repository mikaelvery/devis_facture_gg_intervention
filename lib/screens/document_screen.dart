import 'package:flutter/material.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';
import 'package:devis_facture_gg_intervention/screens/devis_form_screen.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  static const Color bleuNuit = Color(0xFF0B1B3F);
  static const Color blanc = Colors.white;
  static const Color orange = Colors.orange;

  static const List<ButtonInfo> boutons = [
    ButtonInfo('Nouveau devis', Icons.description),
    ButtonInfo('Nouvelle facture', Icons.receipt_long),
    ButtonInfo('Facture acquittée', Icons.check_circle),
    ButtonInfo('Rapport de fuite', Icons.search),
    ButtonInfo('Rapport intervention', Icons.build),
    ButtonInfo('Historique', Icons.history),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final double spacing = 12.0;

    // Cards plus petites, on réduit iconSize & fontSize
    double iconSize = 28;
    double fontSize = 15;

    return Scaffold(
      backgroundColor: bleuNuit,
      appBar: AppBar(
        title: const Text(
          'Générer un nouveau document',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: DocumentScreen.blanc,
          ),
        ),
        backgroundColor: bleuNuit,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: blanc),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 4, // plus allongé horizontalement
                  ),
                  itemCount: boutons.length,
                  itemBuilder: (context, i) {
                    final btn = boutons[i];
                    return GestureDetector(
                      onTap: () => _handleButtonPress(context, btn.label),
                      child: Card(
                        color: blanc,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(btn.icon, size: iconSize, color: bleuNuit),
                                  const SizedBox(width: 14),
                                  Text(
                                    btn.label,
                                    style: TextStyle(
                                      color: bleuNuit,
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios, color: orange, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '© 2025 GG Intervention',
                  style: TextStyle(
                    color: blanc.withAlpha(128),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DevisFormScreen()),
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
                tooltip: 'Accueil',
              ),
              IconButton(
                icon: const Icon(Icons.description, color: bleuNuit),
                onPressed: () {
                  // On est déjà ici
                },
                tooltip: 'Documents',
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.people, color: bleuNuit),
                onPressed: () {
                  //  Navigation vers Clients
                },
                tooltip: 'Clients',
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: bleuNuit),
                onPressed: () {
                  //  Navigation vers Paramètres
                },
                tooltip: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleButtonPress(BuildContext context, String label) {
    switch (label) {
      case 'Nouveau devis':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DevisFormScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: $label')),
        );
    }
  }
}

class ButtonInfo {
  final String label;
  final IconData icon;

  const ButtonInfo(this.label, this.icon);
}
