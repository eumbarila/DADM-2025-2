import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/company.dart';
import 'company_form_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  List<Company> _companies = [];
  String _searchName = '';
  String _filterClassification = '';

  @override
  void initState() {
    super.initState();
    _refreshCompanies();
  }

  Future<void> _refreshCompanies() async {
    final data = await DatabaseHelper.instance.getCompanies(
      name: _searchName,
      classification: _filterClassification,
    );
    setState(() => _companies = data);
  }

  void _deleteCompany(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Seguro que deseas eliminar esta empresa?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteCompany(id);
      _refreshCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directorio de Empresas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _searchName = value;
                      _refreshCompanies();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterClassification.isEmpty ? null : _filterClassification,
                  hint: const Text('Clasificación'),
                  items: ['Consultoría', 'Desarrollo a la medida', 'Fábrica de software']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    _filterClassification = value ?? '';
                    _refreshCompanies();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _companies.length,
              itemBuilder: (context, index) {
                final company = _companies[index];
                return ListTile(
                  title: Text(company.name),
                  subtitle: Text(company.classification),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CompanyFormScreen(company: company),
                      ),
                    );
                    _refreshCompanies();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCompany(company.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CompanyFormScreen()),
          );
          _refreshCompanies();
        },
      ),
    );
  }
}
