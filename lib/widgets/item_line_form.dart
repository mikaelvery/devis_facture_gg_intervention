import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item_line.dart';
import 'package:diacritic/diacritic.dart';

class ItemLineForm extends StatefulWidget {
  final ItemLine item;
  final Function(ItemLine) onUpdate;
  final VoidCallback onRemove;
  final bool isMaterielOnly;
  final int index;

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

  final List<double> tvaRates = [0, 5.5, 8.5, 10, 13, 20];
  double selectedTva = 10;

  String selectedUnite = 'unité';
  final List<String> uniteOptions = ['unité', 'heure', 'mètre', 'kg', 'pièce'];

  final Map<String, Map<String, dynamic>> servicesDetails = {
    'Déplacement': {
      'description': 'Déplacement dans un secteur de 50 KM',
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Item: ${widget.item.description}, '
        'Qty: ${widget.item.qty}, '
        'PUHT: ${widget.item.puHt}, '
        'Type: ${widget.item.type}, '
        'TVA: $selectedTva';
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
      tva: selectedTva,
    );
    if (kDebugMode) {
      print("ItemLine mis à jour : $updatedItem");
    }
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

  InputDecoration customInputDecoration(String label, {Color? color}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: green, width: 2),
      ),
      labelStyle: TextStyle(color: color ?? Colors.grey),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    Color? cursorColor,
    Color? color,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: customInputDecoration(label, color: color),
      onChanged: onChanged,
      cursorColor: green,

    );
  }

  @override
  Widget build(BuildContext context) {
    final prefix = selectedType == 'service' ? 'Service' : 'Matériel';
    final cardTitle = '$prefix ${widget.index + 1}';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cardTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Champ titre, avec autocomplete pour service
            if (selectedType == 'service')
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();

                  final query = removeDiacritics(textEditingValue.text.toLowerCase());

                  final startsWith = serviceSuggestions.where((option) {
                    final normalized = removeDiacritics(option.toLowerCase());
                    return normalized.startsWith(query);
                  }).toList();

                  final contains = serviceSuggestions.where((option) {
                    final normalized = removeDiacritics(option.toLowerCase());
                    return !normalized.startsWith(query) && normalized.contains(query);
                  }).toList();

                  return [...startsWith, ...contains];
                },
                onSelected: onServiceSelected,
                fieldViewBuilder: (context, textController, focusNode, onEditingComplete) {
                  // ici on utilise textController fourni par Autocomplete
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: customInputDecoration('Titre'),
                    cursorColor: green,
                    style: const TextStyle(color: Colors.black87),
                    onChanged: (_) => setState(() {}),
                    onEditingComplete: onEditingComplete,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  );
                },
              )
            else
              buildTextField(
                controller: titreController,
                label: 'Titre',
                onChanged: (_) => updateItem(),
              ),

            const SizedBox(height: 14),

            // Description & TVA si service connu
            if (selectedType == 'service' &&
                servicesDetails.containsKey(titreController.text.trim()))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  servicesDetails[titreController.text.trim()]!['description'],
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Ligne Quantité, Unité, Prix Unitaire HT
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    controller: quantiteController,
                    label: 'Quantité',
                    color: midnightBlue,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => updateItem(),
                    cursorColor: green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUnite,
                    decoration: customInputDecoration('Unité', color: midnightBlue,),
                    dropdownColor: Colors.white,
                    items: uniteOptions
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnite = value;
                          updateItem();
                        });
                      }
                    },
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: buildTextField(
                    controller: puHtController,
                    focusNode: puHtFocusNode,
                    label: 'Prix Unitaire HT (€)',
                    color: midnightBlue,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => updateItem(),
                    cursorColor: green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            // TVA
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<double>(
                value: selectedTva,
                decoration: customInputDecoration(''),
                dropdownColor: Colors.white,
                items: tvaRates.map((rate) {
                  final rateText = rate % 1 == 0
                      ? rate.toStringAsFixed(0)
                      : rate.toString();
                  return DropdownMenuItem(
                    value: rate,
                    child: Text(
                      'TVA $rateText %',
                      style: const TextStyle(
                        fontSize: 14,
                        color: midnightBlue,
                      ),
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) => tvaRates.map((rate) {
                  final rateText = rate % 1 == 0
                      ? rate.toStringAsFixed(0)
                      : rate.toString();
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'TVA $rateText %',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: midnightBlue,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTva = value;
                      updateItem();
                    });
                  }
                },
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),

            const SizedBox(height: 14),
            // Bouton supprimer
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Supprimer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  shadowColor: Colors.greenAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
