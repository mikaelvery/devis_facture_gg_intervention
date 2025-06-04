import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../models/item_line.dart';
import '../widgets/client_search.dart';
import '../widgets/item_line_form.dart';
import 'devis_preview_screen.dart';



class DevisFormScreen extends StatefulWidget {
  
  const DevisFormScreen({super.key});

  @override
  State<DevisFormScreen> createState() => _DevisFormScreenState();
}

class _DevisFormScreenState extends State<DevisFormScreen> {
  Client? _selectedClient;
  DateTime devisDate = DateTime.now();

  final _clientIdController = TextEditingController();
  final _clientPrenomController = TextEditingController();
  final _clientNomController = TextEditingController();
  final _clientAdresseController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientTelephoneController = TextEditingController();
  final _clientCodePostalController = TextEditingController();
  final _clientVilleController = TextEditingController();
  final _clientPaysController = TextEditingController();

  List<ItemLine> items = [
    ItemLine(description: '', qty: 1, puHt: 0, type: 'service'),
  ];

  double tvaPercent = 10.0;

  double get baseHt => items.fold(0.0, (sum, item) => sum + item.totalHt);
  double get montantTva => baseHt * (tvaPercent / 100);
  double get totalTtc => baseHt + montantTva;

  // Mise à jour des champs client à partir d’un Client sélectionné
  void _fillClientForm(Client client) {
    _selectedClient = client;
    _clientIdController.text = client.id;
    _clientPrenomController.text = client.prenom;
    _clientNomController.text = client.nom;
    _clientAdresseController.text = client.adresse;
    _clientEmailController.text = client.email;
    _clientTelephoneController.text = client.telephone;
    _clientCodePostalController.text = client.codePostal;
    _clientVilleController.text = client.ville;
    _clientPaysController.text = client.pays;
  }

  bool _areClientFieldsValid() {
  return _clientPrenomController.text.trim().isNotEmpty &&
    _clientNomController.text.trim().isNotEmpty &&
    _clientAdresseController.text.trim().isNotEmpty &&
    _clientEmailController.text.trim().isNotEmpty &&
    _clientTelephoneController.text.trim().isNotEmpty &&
    _clientCodePostalController.text.trim().isNotEmpty &&
    _clientVilleController.text.trim().isNotEmpty &&
    _clientPaysController.text.trim().isNotEmpty;
  }

  void _updateItem(int index, ItemLine newItem) {
    setState(() {
      items[index] = newItem;
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _addItem(String type) {
    setState(() {
      items.add(ItemLine(description: '', qty: 1, puHt: 0, type: type));
    });
  }

  List<ItemLine> _getItemsByType(String type) {
    return items.where((item) => item.type == type).toList();
  }

  Widget _buildItemList(String title, String type) {
    final filteredItems = _getItemsByType(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: bleuNuit,
            ),
          ),
        ),
        ...filteredItems.asMap().entries.map((entry) {
          final filteredIndex = entry.key;
          final item = entry.value;
          final itemIndex = items.indexOf(item);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ItemLineForm(
              key: ValueKey(itemIndex),
              item: item,
              index: filteredIndex,
              onUpdate: (updatedItem) => _updateItem(itemIndex, updatedItem),
              onRemove: () => _removeItem(itemIndex),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: bleuNuit,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _addItem(type),
            icon: const Icon(Icons.add_circle_outline, color: blanc),
            label: Text(
              type == 'service' ? "Ajouter un service" : "Ajouter du matériel",
              style: const TextStyle(color: blanc),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: blanc,
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: blanc,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientPrenomController.dispose();
    _clientNomController.dispose();
    _clientAdresseController.dispose();
    _clientEmailController.dispose();
    _clientTelephoneController.dispose();
    _clientCodePostalController.dispose();
    _clientVilleController.dispose();
    _clientPaysController.dispose();
    super.dispose();
  }

  void _clearClientForm() {   // vide les input du formulaire une fois le changement de client 
    _clientIdController.clear();
    _clientPrenomController.clear();
    _clientNomController.clear();
    _clientAdresseController.clear();
    _clientEmailController.clear();
    _clientTelephoneController.clear();
    _clientCodePostalController.clear();
    _clientVilleController.clear();
    _clientPaysController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bleuNuit,
      appBar: AppBar(
        title: const Text(
          "Nouveau Devis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bleuNuit,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClientSearchWidget(
              onClientSelected: (Client? client) {
                setState(() {
                  _selectedClient = client;
                  if (client != null) {
                    _fillClientForm(client);
                  } else {
                    _clearClientForm();
                  }
                });
              },
            ),

            if (_selectedClient == null) ...[
              SizedBox(height: 24),
              const Text(
                'Informations client',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_clientPrenomController, 'Prénom'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(_clientNomController, 'Nom'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_clientAdresseController, 'Adresse'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _clientEmailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _clientTelephoneController,
                      'Téléphone',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _clientCodePostalController,
                      'Code postal',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(_clientVilleController, 'Ville'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_clientPaysController, 'Pays'),
              const SizedBox(height: 24),
            ],

            const Text(
              'Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _buildItemList('Services', 'service'),

            const SizedBox(height: 12),
            const Text(
              'Matériels',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _buildItemList('Matériels', 'materiel'),

            const SizedBox(height: 16),
            const Text(
              "TVA %",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<double>(
                value: tvaPercent,
                isExpanded: true,
                underline: const SizedBox(),
                items: [0, 5.5, 10, 20].map((e) {
                  return DropdownMenuItem(
                    value: e.toDouble(),
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tvaPercent = value;
                    });
                  }
                },
              ),
            ),

            const Divider(height: 32, thickness: 2, color: Colors.white),

            _buildSummaryRow('Montant HT', baseHt),
            _buildSummaryRow(
              'TVA (${tvaPercent.toStringAsFixed(1)}%)',
              montantTva,
            ),
            _buildSummaryRow('Montant TTC', totalTtc, isBold: true),

            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedClient == null && !_areClientFieldsValid()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Veuillez remplir tous les champs du client."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final client = _selectedClient ??
                        Client(
                          id: _clientIdController.text,
                          prenom: _clientPrenomController.text,
                          nom: _clientNomController.text,
                          adresse: _clientAdresseController.text,
                          email: _clientEmailController.text,
                          telephone: _clientTelephoneController.text,
                          codePostal: _clientCodePostalController.text,
                          ville: _clientVilleController.text,
                          pays: _clientPaysController.text,
                        );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevisPreviewScreen(
                          client: client,
                          items: items,
                          tvaPercent: tvaPercent,
                          devisDate: devisDate,
                        ),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevisPreviewScreen(
                          client: client,
                          items: items,
                          tvaPercent: tvaPercent,
                          devisDate: devisDate,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Visualiser PDF',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
