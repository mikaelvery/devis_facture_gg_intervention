import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/screens/view_documents_screen.dart';
import 'package:flutter/material.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';
import 'package:devis_facture_gg_intervention/screens/devis_form_screen.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

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
    double iconSize = 28;
    double fontSize = 15;

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        title: const Text(
          'Générer un nouveau document',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        backgroundColor: midnightBlue,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: white),
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
                        color: white,
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
                                  Icon(
                                    btn.icon,
                                    size: iconSize,
                                    color: midnightBlue,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    btn.label,
                                    style: TextStyle(
                                      color: midnightBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: orange,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 10),
          child: FloatingActionButton(
            backgroundColor: orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentScreen()),
              );
            },
            child: const Icon(Icons.add, size: 40, color: white),
          ),
        ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          height: 60,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    },
                    child: const Center(
                      child: Icon(Icons.home, color: midnightBlue, size: 24),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewDocumentsScreen()),
                      );
                    },
                    child: const Center(
                      child: Icon(Icons.description, color: midnightBlue, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 40), 
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {},
                    child: const Center(
                      child: Icon(Icons.people, color: midnightBlue, size: 24),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {},
                    child: const Center(
                      child: Icon(Icons.settings, color: midnightBlue, size: 24),
                    ),
                  ),
                ),
              ],
            ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Action: $label')));
    }
  }
}

class ButtonInfo {
  final String label;
  final IconData icon;

  const ButtonInfo(this.label, this.icon);
}
