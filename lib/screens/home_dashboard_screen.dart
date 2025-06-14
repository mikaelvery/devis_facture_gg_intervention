import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devis_facture_gg_intervention/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:devis_facture_gg_intervention/screens/document_screen.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTimeRange? selectedDateRange;
  int notificationCount = 0;
  // Simule des stats en fonction de la plage
  Map<String, String> getStats() {
    if (selectedDateRange == null) {
      // Stats année en cours
      return {
        'Total encaissé': '12 345 €',
        'Devis en attente de signature': '2749,99 €',
        'Facture en attente de paiement': '800,00 €',
        'Facture en retard': '758,20 €',
      };
    } else {
      // Stats mock filtrées sur la plage sélectionnée
      return {
        'Total encaissé': '9 876 €',
        'Devis en attente de signature': '1235,12 €',
        'Facture en attente de paiement': '500,49 €',
        'Facture en retard': '649 €',
      };
    }
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    // peux aussi clear() pour tout supprimer
    // await prefs.clear();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialDateRange =
        selectedDateRange ??
        DateTimeRange(start: DateTime(now.year, 1, 1), end: now);

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

  Stream<int> notificationCountStream() {
    return FirebaseFirestore.instance
        .collection('devis')
        .where('isRead', isEqualTo: false)
        .where('isSigned', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final stats = getStats();

    return Scaffold(
      backgroundColor: midnightBlue,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: AppBar(
            backgroundColor: white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo-gg-devis-appbar.png',
                      height: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ma synthèse',
                      style: TextStyle(
                        color: midnightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _pickDateRange,
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // pour que le bouton prenne juste la taille du contenu
                        children: [
                          Text(
                            _formatDateRange(),
                            style: const TextStyle(color: midnightBlue),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.calendar_month,
                              color: midnightBlue,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              StreamBuilder<int>(
                stream: notificationCountStream(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: midnightBlue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.logout, color: midnightBlue),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Déconnexion',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: midnightBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: midnightBlue,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: midnightBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();

                                      // supprime les données de session ou token
                                      await _logoutUser();

                                      Navigator.of(
                                        // ignore: use_build_context_synchronously
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/screens/splashScreen',
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Se déconnecter'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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
        backgroundColor: orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DocumentScreen()),
          );
        },
        child: const Icon(Icons.add, size: 40, color: white),
      ),
      bottomNavigationBar: Container(
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
        child: BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: midnightBlue),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.description, color: midnightBlue),
                onPressed: () {},
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.people, color: midnightBlue),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: midnightBlue),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 254, 254, 254).withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colonne texte (titre + montant)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: midnightBlue.withAlpha(220),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: midnightBlue.withAlpha(255),
                  ),
                ),
              ],
            ),
          ),

          // Chevron à droite
          Icon(
            Icons.chevron_right,
            color: const Color.fromARGB(255, 0, 0, 0).withAlpha(150),
            size: 28,
          ),
        ],
      ),
    );
  }
}
