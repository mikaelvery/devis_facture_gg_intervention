import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:devis_facture_gg_intervention/screens/document_screen.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTimeRange? selectedDateRange;

  // Simule des stats en fonction de la plage
  Map<String, String> getStats() {
    if (selectedDateRange == null) {
      // Stats par défaut (année en cours)
      return {
        'Total encaissé': '12 345 €',
        'Devis en attente de signature': '2749,99',
        'Facture en attente de paiement': '800,00',
        'Facture en retard': '758,20',
      };
    } else {
      // Stats mock filtrées sur la plage sélectionnée (à remplacer par ta BDD)
      return {
        'Total encaissé': '9 876 €',
        'Devis en attente de signature': '1235,12',
        'Facture en attente de paiement': '500,49 €',
        'Facture en retard': '649 €',
      };
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialDateRange = selectedDateRange ??
        DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initialDateRange,
      helpText: 'Sélectionnez une plage de dates',
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  String _formatDateRange() {
    if (selectedDateRange == null) {
      return 'Année en cours';
    }
    final f = DateFormat('dd/MM/yyyy');
    return '${f.format(selectedDateRange!.start)} - ${f.format(selectedDateRange!.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final stats = getStats();

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
                        fontSize: 32,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today, color: bleuNuit, size: 18),
                      label: Text(_formatDateRange(),
                          style: const TextStyle(color: bleuNuit)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        backgroundColor: blanc,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _pickDateRange,
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
            children: stats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CardStat(title: entry.key, value: entry.value),
              );
            }).toList(),
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
        child: const Icon(Icons.add, size: 40, color: blanc),
      ),
      bottomNavigationBar: Container(
        height: 60,
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
  final String value;

  const CardStat({super.key, required this.title, this.value = ''});

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
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: bleuNuit,
            ),
          ),
        ],
      ),
    );
  }
}
