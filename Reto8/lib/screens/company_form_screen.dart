import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/company.dart';

class CompanyFormScreen extends StatefulWidget {
  final Company? company;
  const CompanyFormScreen({Key? key, this.company}) : super(key: key);

  @override
  _CompanyFormScreenState createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _productsController;
  String _classification = 'Consultoría';

  @override
  void initState() {
    super.initState();
    final company = widget.company;
    _nameController = TextEditingController(text: company?.name ?? '');
    _websiteController = TextEditingController(text: company?.website ?? '');
    _phoneController = TextEditingController(text: company?.phone ?? '');
    _emailController = TextEditingController(text: company?.email ?? '');
    _productsController = TextEditingController(text: company?.products ?? '');
    _classification = company?.classification ?? 'Consultoría';
  }

  void _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    final company = Company(
      id: widget.company?.id,
      name: _nameController.text,
      website: _websiteController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      products: _productsController.text,
      classification: _classification,
    );

    if (widget.company == null) {
      await DatabaseHelper.instance.createCompany(company);
    } else {
      await DatabaseHelper.instance.updateCompany(company);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.company == null ? 'Agregar Empresa' : 'Editar Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              TextFormField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Página web')),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(controller: _productsController, decoration: const InputDecoration(labelText: 'Productos y servicios')),
              DropdownButtonFormField<String>(
                initialValue: _classification,
                decoration: const InputDecoration(labelText: 'Clasificación'),
                items: ['Consultoría', 'Desarrollo a la medida', 'Fábrica de software']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _classification = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveCompany, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
