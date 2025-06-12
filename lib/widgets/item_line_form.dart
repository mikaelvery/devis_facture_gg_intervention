import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item_line.dart';

class ItemLineForm extends StatefulWidget {
  final ItemLine item;
  final Function(ItemLine) onUpdate;
  final VoidCallback onRemove;
  final bool isMaterielOnly;
  final int index; // Index pour numéroter le titre (1, 2, 3...)

  const ItemLineForm({
    required this.item,
    required this.onUpdate,
    required this.onRemove,
    this.isMaterielOnly = false,
    required this.index,
    super.key,
  });

  @override
  State<ItemLineForm> createState() => _ItemLineFormState();
}

class _ItemLineFormState extends State<ItemLineForm> {
  late TextEditingController titreController;
  late TextEditingController quantiteController;
  late TextEditingController puHtController;

  late FocusNode puHtFocusNode;

  String? selectedType;

  final List<double> tvaRates = [0, 10, 13];
  double selectedTva = 10;

  String selectedUnite = 'unité';
  final List<String> uniteOptions = ['unité', 'heure', 'mètre', 'kg', 'pièce'];

  final Map<String, Map<String, dynamic>> servicesDetails = {
    'Déplacement': {
      'description': 'Déplacement dans un secteur de 30 KM',
      'prix': 40.0,
    },
    "Main d'oeuvre": {
      'description': 'Frais de main d\'oeuvre horaire',
      'prix': 65.0,
    },
    'Débouchage pompe': {
      'description': 'Débouchage pompe à améliorer, pas le détail',
      'prix': 85.0,
    },
    'Débouchage machine': {
      'description': 'Débouchage machine à améliorer, pas le détail',
      'prix': 95.0,
    },
    'Réparation de fuite n1': {
      'description': 'Réparation de fuite par remplacement de joint',
      'prix': 95.0,
    },
    'Réparation de fuite n2': {
      'description': 'Toute autre réparation de fuite que n1',
      'prix': 190.0,
    },
    'Recherche de fuite n1': {
      'description': 'Recherche de fuite sans destruction / visuel',
      'prix': 265.0,
    },
    'Recherche de fuite n2': {
      'description':
          'Utilisation de caméra thermique / inspection ou avec destruction',
      'prix': 350.0,
    },
    'Mise en sécurité provisoire': {
      'description':
          'Coupure d\'eau, fermeture d\'une ouverture <1m2, pose serrure provisoire',
      'prix': 130.0,
    },
    'Ouverture de porte radio': {
      'description': 'Utilisation radiographie ouverture par by-pass',
      'prix': 80.0,
    },
    'Ouverture de porte n1': {
      'description': 'Ouverture porte cylindre profil européen sans protecteur',
      'prix': 100.0,
    },
    'Ouverture de porte n2': {
      'description': 'Ouverture porte cylindre non européen ou avec protection',
      'prix': 150.0,
    },
  };

  List<String> get serviceSuggestions => servicesDetails.keys.toList();

  @override
  void initState() {
    super.initState();

    titreController = TextEditingController(text: widget.item.description);
    quantiteController = TextEditingController(
      text: widget.item.qty.toString(),
    );
    puHtController = TextEditingController(
      text: widget.item.puHt > 0 ? widget.item.puHt.toStringAsFixed(2) : '',
    );

    selectedType = widget.isMaterielOnly ? 'materiel' : widget.item.type;

    puHtFocusNode = FocusNode();
    puHtFocusNode.addListener(() {
      if (puHtFocusNode.hasFocus) {
        if (puHtController.text == '0.00' ||
            puHtController.text == '00.00' ||
            puHtController.text.isEmpty) {
          puHtController.clear();
        }
      }
    });

    if (selectedType == 'service' &&
        servicesDetails.containsKey(widget.item.description)) {
      selectedTva = 10;
      puHtController.text = servicesDetails[widget.item.description]!['prix']
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    titreController.dispose();
    quantiteController.dispose();
    puHtController.dispose();
    puHtFocusNode.dispose();
    super.dispose();
  }

  void updateItem() {
    final titre = titreController.text.trim();
    final qty = int.tryParse(quantiteController.text) ?? 0;
    final puHt = double.tryParse(puHtController.text) ?? 0.0;

    final updatedItem = ItemLine(
      description: titre,
      qty: qty,
      puHt: puHt,
      type: selectedType ?? 'materiel',
    );

    widget.onUpdate(updatedItem);
  }

  void onServiceSelected(String value) {
    setState(() {
      titreController.text = value;
      if (servicesDetails.containsKey(value)) {
        puHtController.text = servicesDetails[value]!['prix'].toStringAsFixed(
          2,
        );
      } else {
        puHtController.text = '';
      }
      selectedType = 'service';
      selectedTva = 10;
      updateItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefix = selectedType == 'service' ? 'Service' : 'Matériel';
    final cardTitle = '$prefix ${widget.index + 1}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la card
            Text(
              cardTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Champ titre/service avec autocomplete si service
            if (selectedType == 'service')
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return serviceSuggestions.where(
                    (option) => option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: onServiceSelected,
                fieldViewBuilder:
                    (
                      context,
                      fieldTextEditingController,
                      focusNode,
                      onEditingComplete,
                    ) {
                      fieldTextEditingController.text = titreController.text;
                      fieldTextEditingController.selection =
                          titreController.selection;

                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Titre',
                          labelStyle: TextStyle(color: midnightBlue),
                          floatingLabelStyle: TextStyle(color: midnightBlue),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: midnightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: midnightBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          titreController.text = value;
                          updateItem();
                        },
                        onEditingComplete: onEditingComplete,
                      );
                    },
              )
            else
              TextField(
                controller: titreController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  labelStyle: TextStyle(color: midnightBlue),
                  floatingLabelStyle: TextStyle(color: midnightBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: midnightBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: midnightBlue, width: 2),
                  ),
                ),
                onChanged: (_) => updateItem(),
              ),
            const SizedBox(height: 14),

            // Description service + TVA si service
            if (selectedType == 'service' &&
                servicesDetails.containsKey(titreController.text.trim()))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicesDetails[titreController.text
                          .trim()]!['description'],
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Prix HT: ${puHtController.text} €',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 24),
                        const Text(
                          'TVA:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<double>(
                          value: selectedTva,
                          items: tvaRates
                              .map(
                                (rate) => DropdownMenuItem(
                                  value: rate,
                                  child: Text('$rate %'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedTva = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Ligne Quantité, Unité, Prix Unitaire HT
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantiteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      labelStyle: TextStyle(color: midnightBlue),
                      floatingLabelStyle: TextStyle(color: midnightBlue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: midnightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: midnightBlue, width: 2),
                      ),
                    ),
                    onChanged: (_) => updateItem(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUnite,
                    items: uniteOptions
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Unité',
                      labelStyle: TextStyle(color: midnightBlue),
                      floatingLabelStyle: TextStyle(color: midnightBlue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: midnightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: midnightBlue, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnite = value;
                        });
                        updateItem();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: puHtController,
                    focusNode: puHtFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Prix Unitaire HT (€)',
                      labelStyle: TextStyle(color: midnightBlue),
                      floatingLabelStyle: TextStyle(color: midnightBlue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: midnightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: midnightBlue, width: 2),
                      ),
                    ),
                    onChanged: (_) => updateItem(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Bouton Supprimer
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Supprimer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  shadowColor: Colors.orangeAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
