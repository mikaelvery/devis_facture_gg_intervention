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

    final clients = snapshot.docs
        .map((doc) => Client.fromDocument(doc))
        .toList();

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
      color: midnightBlue,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: midnightBlue),
            decoration: InputDecoration(
              hintText: "Rechercher un client existant",
              hintStyle: TextStyle(color: midnightBlue.withAlpha(150)),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
              filled: true,
              fillColor: white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: midnightBlue.withAlpha(100)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: midnightBlue, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {}); 
              _onSearchChanged(value);
            },
          ),
          const SizedBox(height: 20),

          if (_filteredClients.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                final client = _filteredClients.first;
                setState(() {
                  _selectedClient = client;
                  _filteredClients.clear();
                  _searchController.clear();
                  widget.onClientSelected(client);
                });
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: midnightBlue,
                    child: Text(
                      _filteredClients.first.nom.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _filteredClients.first.nom.toUpperCase(),
                            style: const TextStyle(
                              color: midnightBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: _filteredClients.first.prenom,
                            style: const TextStyle(
                              color: midnightBlue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: midnightBlue),
                ],
              ),
            ),
          ),


          if (_selectedClient != null) ...[
            const SizedBox(height: 20),
            const Text(
              "✅ Client sélectionné",
              style: TextStyle(
                color: white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                        color: midnightBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: midnightBlue),
                        const SizedBox(width: 8),
                        Text(
                          _selectedClient!.telephone,
                          style: const TextStyle(color: midnightBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 18, color: midnightBlue),
                        const SizedBox(width: 8),
                        Text(
                          _selectedClient!.email,
                          style: const TextStyle(color: midnightBlue),
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
                widget.onClientSelected(
                  null,
                ); // on dit au parent qu'il n'y a plus de client
                setState(() {
                  _selectedClient =
                      null; // on remet l’état à zéro dans le widget
                });
              },

              style: TextButton.styleFrom(
                foregroundColor: white,
                backgroundColor: midnightBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: white),
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
