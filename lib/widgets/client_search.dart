import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';

class ClientSearchWidget extends StatefulWidget {
  final Function(Client?) onClientSelected;

  const ClientSearchWidget({super.key, required this.onClientSelected});

  @override
  State<ClientSearchWidget> createState() => _ClientSearchWidgetState();
}

class _ClientSearchWidgetState extends State<ClientSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  List<Client> _filteredClients = [];
  Client? _selectedClient;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_selectedClient != null) {
      setState(() {
        _selectedClient = null;
      });
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterClients(query);
    });
  }

  Future<void> _filterClients(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredClients = [];
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('clients')
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .get();

    final clients = snapshot.docs.map((doc) => Client.fromDocument(doc)).toList();

    setState(() {
      _filteredClients = clients;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bleuNuit,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: bleuNuit),
            decoration: InputDecoration(
              hintText: "Rechercher un client existant",
              hintStyle: TextStyle(color: bleuNuit.withAlpha(150)),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              filled: true,
              fillColor: blanc,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: bleuNuit.withAlpha(100)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: bleuNuit, width: 2),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),

          if (_filteredClients.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredClients.length,
              itemBuilder: (context, index) {
                final client = _filteredClients[index];
                return Card(
                  color: blanc,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      "${client.prenom} ${client.nom}",
                      style: const TextStyle(color: bleuNuit, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedClient = client;
                        _filteredClients.clear();
                        _searchController.clear();
                        widget.onClientSelected(client);
                      });
                    },
                  ),
                );
              },
            ),

          if (_selectedClient != null) ...[
            const SizedBox(height: 20),
            const Text(
              "✅ Client sélectionné",
              style: TextStyle(color: blanc, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              color: blanc,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_selectedClient!.prenom} ${_selectedClient!.nom}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: bleuNuit,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: bleuNuit),
                        const SizedBox(width: 8),
                        Text(
                          _selectedClient!.telephone,
                          style: const TextStyle(color: bleuNuit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 18, color: bleuNuit),
                        const SizedBox(width: 8),
                        Text(
                          _selectedClient!.email,
                          style: const TextStyle(color: bleuNuit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                widget.onClientSelected(null); // on dit au parent qu'il n'y a plus de client
                setState(() {
                  _selectedClient = null; // on remet l’état à zéro dans le widget
                });
              },

              style: TextButton.styleFrom(
                foregroundColor: blanc,
                backgroundColor: bleuNuit,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: blanc),
                ),
              ),
              child: const Text(
                "Changer de client",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
